FROM python:2

MAINTAINER David Kwast <david@kwast.net>

# Nginx install
ADD nginx_signing.key /
RUN apt-key add /nginx_signing.key
RUN echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list
RUN apt-get update && apt-get -y install nginx && apt-get clean

# uWSGI, Supervisord, Django, pytz install
RUN pip install --upgrade pip && \
    pip install "Django<1.9" && \
    pip install pytz && \
    pip install supervisor --pre && \
    pip install uwsgi

# CONFIG
# forward request and error logs to docker log collector
#RUN ln -sf /dev/stdout /var/log/nginx/access.log
#RUN ln -sf /dev/stderr /var/log/nginx/error.log
# config files
RUN rm -r /etc/nginx/conf.d/*
ADD nginx.conf /etc/nginx/
ADD nginx_mysite.conf /etc/nginx/conf.d/
ADD supervisord.conf /usr/local/etc/supervisord.conf

# django test
RUN django-admin.py startproject mysite

# Nginx START
EXPOSE 80

ENTRYPOINT ["supervisord"]
