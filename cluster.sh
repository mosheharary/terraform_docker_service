#!/bin/bash
kernel=$(uname -r | cut -d. -f1-2)

function random_unused_port {
    local port=$(shuf -i 8000-10000 -n 1)
    netstat -lat | grep $port > /dev/null
    if [[ $? == 1 ]] ; then
        export RANDOM_PORT=$port
    else
        random_unused_port
    fi
}

get_full_path() {
    # Absolute path to this script, e.g. /home/user/bin/foo.sh
    SCRIPT=$(readlink -f $0)

    if [ ! -d ${SCRIPT} ]; then
        # Absolute path this script is in, thus /home/user/bin
        SCRIPT=`dirname $SCRIPT`
    fi

    ( cd "${SCRIPT}" ; pwd )
}

SCRIPT_PATH="$(get_full_path ./)"

status ()
{
    if [ ! -d ${SCRIPT_PATH}/${CLUSTER_NAME} ];then
        echo "Can not find ${SCRIPT_PATH}/${CLUSTER_NAME}"
        exit 1
    fi
    cd ${SCRIPT_PATH}/${CLUSTER_NAME}
    port=$(terraform show  |grep published_port | awk '{print $NF}')
    while(true);do
        sts=$(curl -XGET http://127.0.0.1:${port}/index.html 2>&1 | grep Hello | awk -F">" '{print $2}' | awk -F"<" '{print $1}')
        echo "http://127.0.0.1:${port}/index.html -> ${sts}"
        sleep 5
    done
}


usage ()
{
	echo $"Usage: $0 {start|stop|status <cluster name>" 1>&2
	RETVAL=2
}

start ()
{
    if [ ! -d ${SCRIPT_PATH}/${CLUSTER_NAME} ];then
        cp -rf ${SCRIPT_PATH}/cluster ${SCRIPT_PATH}/${CLUSTER_NAME}
        sed s/web_cluster/${CLUSTER_NAME}/ -i ${SCRIPT_PATH}/${CLUSTER_NAME}/main.tf
    fi
    random_unused_port
    cd ${SCRIPT_PATH}/${CLUSTER_NAME}
    terraform init && terraform plan && terraform apply -auto-approve -var "cluster_port=${RANDOM_PORT}" -var "ghost_public_network=${CLUSTER_NAME}_network" -var "cluster_name=${CLUSTER_NAME}" && docker service ls | grep ${CLUSTER_NAME} && docker network ls | grep ${CLUSTER_NAME}

}

stop ()
{
    if [ ! -d ${SCRIPT_PATH}/${CLUSTER_NAME} ];then
        echo "Can not find ${SCRIPT_PATH}/${CLUSTER_NAME}"
        exit 1
    fi
    cd ${SCRIPT_PATH}/${CLUSTER_NAME}
    terraform destroy -auto-approve
}


CLUSTER_NAME=$2
test -z "${CLUSTER_NAME}" && exit 1

case "$1" in
    stop) stop ;;
    start) start ;;
    status) status ;;
    *) usage ;;
esac

exit $RETVAL
