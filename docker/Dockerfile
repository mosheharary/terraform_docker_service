FROM nginx
RUN apt-get update && apt-get install -y curl
COPY index.html /usr/share/nginx/html/index.html
COPY run.sh /run.sh
RUN chmod +x run.sh
CMD /bin/sh -c "/run.sh"
