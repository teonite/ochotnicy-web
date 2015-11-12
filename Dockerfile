FROM phusion/baseimage:latest
MAINTAINER Robert Olejnik "robert@teonite.com"

# requirements for django
RUN apt-get update
RUN apt-get -y install --no-install-recommends nginx procps vim openssh-server && apt-get clean

# nginx config - do not run as a daemon
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# == SERVICES ===

RUN mkdir /etc/service/nginx
ADD deployment/bin/nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/logs
ADD deployment/bin/logs.sh /etc/service/logs/run

# WebApp files
RUN mkdir /web/
ADD dist /web/
RUN chown -R www-data:www-data /web/

# Landing Page
RUN mkdir /landing/
ADD design/css /langing/css
ADD design/fonts /langing/fonts
ADD design/img /langing/img
ADD design/js /langing/js
ADD design/landing_page.html /langing/index.html

WORKDIR /web/

COPY app_conf/nginx_prod.conf /etc/nginx/sites-available/wolontariat.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/wolontariat.conf /etc/nginx/sites-enabled/wolontariat.conf

# ssh
EXPOSE 22
# nginx
EXPOSE 80
EXPOSE 443

VOLUME ["/web/", "/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx/"]

# Use baseimage-docker's init system.

CMD ["/sbin/my_init"]