FROM debian:jessie

RUN apt-get update \
  && apt-get install -y wget git gcc g++ make libc6-dev libpcre++-dev libssl-dev libxslt-dev libgd2-xpm-dev libgeoip-dev perl libssl1.0.0 libxslt1.1 libgd3 libxpm4 libgeoip1 libav-tools \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/luajit && wget http://luajit.org/download/LuaJIT-2.0.4.tar.gz -O /opt/luajit.tar.gz && tar xfz /opt/luajit.tar.gz -C /opt/luajit && rm -f /opt/luajit.tar.gz
RUN cd /opt/luajit/LuaJIT-2.0.4 && make install

ENV LUAJIT_LIB /usr/local/lib 
ENV LUAJIT_INC /usr/local/include/luajit-2.0

ENV MODULE_GIT_URL https://github.com/openresty/lua-nginx-module.git
ENV NGINX_VERSION 1.8.0

RUN mkdir /opt/nginx && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O /opt/nginx.tar.gz && tar xfz /opt/nginx.tar.gz -C /opt/nginx && rm -f /opt/nginx.tar.gz

RUN mkdir /opt/module && git clone --depth 1 --single-branch ${MODULE_GIT_URL} /opt/module

RUN useradd --system --no-create-home --user-group nginx && mkdir -p /var/cache/nginx/ && \
    cd /opt/nginx/nginx-${NGINX_VERSION} && ./configure --prefix=/etc/nginx \
	--sbin-path=/usr/sbin/nginx \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/var/run/nginx.pid \
	--lock-path=/var/run/nginx.lock \
	--http-client-body-temp-path=/var/cache/nginx/client_temp \
	--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
	--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
	--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
	--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
	--user=nginx \
	--group=nginx \
	--with-http_ssl_module \
	--with-http_realip_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_dav_module \
	--with-http_flv_module \
	--with-http_mp4_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-mail \
	--with-mail_ssl_module \
	--with-file-aio \
	--with-http_spdy_module \
	--with-ipv6 \
	--with-threads \
	--add-module=/opt/module \
	&& make && make install

RUN ln -s /usr/local/lib/libluajit-5.1.so.2.0.4 /usr/lib/libluajit-5.1.so.2
CMD ["nginx", "-g", "daemon off;"]

