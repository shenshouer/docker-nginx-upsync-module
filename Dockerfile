FROM alpine:3.3

MAINTAINER Sope Shen <shenshouer51@gmail.com>

ENV NGINX_VERSION nginx-1.8.0

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
    		gcc \
    		git \ 
    		openssl-dev \
    		pcre-dev \
    		zlib-dev \
    		wget \
    		build-base \
    && mkdir -p /tmp/src \
    && cd /tmp/src \
    && git clone https://github.com/weibocom/nginx-upsync-module.git \
    && wget http://nginx.org/download/${NGINX_VERSION}.tar.gz \
    && tar -zxvf ${NGINX_VERSION}.tar.gz \
    && cd /tmp/src/${NGINX_VERSION} \
    && ./configure \
        --add-module=/tmp/src/nginx-upsync-module \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx \
    && make \
    && make install \
    && apk del build-base wget git .build-deps \
    && rm -rf /tmp/src \
    && rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

WORKDIR /etc/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
