sed s/_ID_/${HOSTNAME}/g -i /usr/share/nginx/html/index.html
nginx -g "daemon off;"
