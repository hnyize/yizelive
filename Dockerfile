FROM hnyize/alpinebuilder:latest as builder
MAINTAINER hnyize <hainanyize@qq.com>

ARG NGINX_VERSION=1.15.8
ARG NGINX_RTMP_VERSION=1.2.1

RUN	cd /tmp/									&&	\
	curl --remote-name http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz			&&	\
	git clone https://github.com/arut/nginx-rtmp-module.git -b v${NGINX_RTMP_VERSION}

RUN	cd /tmp										&&	\
	tar xzf nginx-${NGINX_VERSION}.tar.gz						&&	\
	cd nginx-${NGINX_VERSION}							&&	\
	./configure										\
		--prefix=/opt/nginx								\
		--with-http_ssl_module								\
		--add-module=../nginx-rtmp-module					&&	\
	make										&&	\
	make install

FROM alpine:latest
RUN	echo '' > /etc/apk/repositories &&	\
	echo 'http://mirrors.aliyun.com/alpine/v3.8/main/' > /etc/apk/repositories  && \
	echo 'http://mirrors.aliyun.com/alpine/v3.8/community/' >> /etc/apk/repositories
RUN apk update		&& \
	apk add			   \
		openssl		   \
		libstdc++	   \
		ca-certificates	   \
		pcre

COPY --from=0 /opt/nginx /opt/nginx
COPY --from=0 /tmp/nginx-rtmp-module/stat.xsl /opt/nginx/conf/stat.xsl
RUN rm /opt/nginx/conf/nginx.conf
ADD run.sh /
ADD live /opt/live/
VOLUME /video
RUN chmod +x /run.sh

EXPOSE 1935
EXPOSE 8080

CMD /run.sh
