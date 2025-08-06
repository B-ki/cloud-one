FROM debian:bullseye

RUN apt update && apt install -y nginx openssl 
        
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=CA/L=San Francisco/O=My Org/OU=My Unit/CN=rmorel.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
RUN rm -f /etc/nginx/sites-enabled/default

EXPOSE 443

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
