FROM debian:bullseye-slim


LABEL maintainer="gyb1314<gyb_1314@126.com>"

#ENV http_proxy=http://192.168.3.16:7078
#ENV https_proxy=http://192.168.3.16:7078

COPY sources.list /etc/apt/sources.list

RUN apt-get -y update && \
	apt-get install -y \
		libavutil-dev \
		libavformat-dev \
		libavcodec-dev \
		libmicrohttpd-dev \
		libjansson-dev \
		libssl-dev \
		libsofia-sip-ua-dev \
		libglib2.0-dev \
		libopus-dev \
		libogg-dev \
		libcurl4-openssl-dev \
		liblua5.3-dev \
		libconfig-dev \
		libusrsctp-dev \
		libwebsockets-dev \
		libnanomsg-dev \
		librabbitmq-dev \
		pkg-config \
		gengetopt \
		libtool \
		automake \
		build-essential \
		wget \
		git \
		cmake \
		gtk-doc-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#copy thirdLibs
ENV THIRDLIBS_HOME /thirdLibs

RUN mkdir -p $THIRDLIBS_HOME

COPY thirdLibs/libsrtp-2.4.2.tar.gz $THIRDLIBS_HOME 

RUN cd $THIRDLIBS_HOME && \
	tar xfv libsrtp-2.4.2.tar.gz && \
	cd libsrtp-2.4.2 && \
	./configure --prefix=/usr --enable-openssl && \
	make shared_library && \
	make install

COPY thirdLibs/libnice-0.1.17.tar.gz $THIRDLIBS_HOME

RUN cd $THIRDLIBS_HOME && \
	tar xfv libnice-0.1.17.tar.gz && \
	cd libnice-0.1.17 && \
	./autogen.sh && \
	./configure --prefix=/usr && \
	make && \
	make install

COPY thirdLibs/libwebsockets-v3.2-stable.tar.gz $THIRDLIBS_HOME

RUN cd $THIRDLIBS_HOME && \
       tar xfv libwebsockets-v3.2-stable.tar.gz && \
       cd libwebsockets && \
       mkdir build && cd build && \
       cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
       make && make install

COPY thirdLibs/paho.mqtt.c-v1.3.11.tar.gz $THIRDLIBS_HOME

RUN cd $THIRDLIBS_HOME && \
       tar xfv paho.mqtt.c-v1.3.11.tar.gz && \
       cd paho.mqtt.c && \
       make && make install

RUN mkdir -p /usr/local/janus/src

COPY thirdLibs/janus-gateway-1.1.0.tar.gz $THIRDLIBS_HOME

#COPY . /usr/local/src/janus-gateway

RUN cd $THIRDLIBS_HOME && \
        tar xfv janus-gateway-1.1.0.tar.gz -C /usr/local/janus/src && \
	cd /usr/local/janus/src/janus-gateway-1.1.0 && \
	sh autogen.sh && \
	./configure --enable-post-processing --prefix=/usr/local/janus && \
	make && \
	make install && \
	make configs

FROM debian:bullseye-slim

#ENV http_proxy=http://192.168.3.16:7078
#ENV https_proxy=http://192.168.3.16:7078

ARG BUILD_DATE="undefined"
ARG GIT_BRANCH="undefined"
ARG GIT_COMMIT="undefined"
ARG VERSION="undefined"

LABEL build_date=${BUILD_DATE}
LABEL git_branch=${GIT_BRANCH}
LABEL git_commit=${GIT_COMMIT}
LABEL version=${VERSION}

RUN apt-get -y update && \
	apt-get install -y \
		libmicrohttpd12 \
		libavutil-dev \
		libavformat-dev \
		libavcodec-dev \
		libjansson4 \
		libssl1.1 \
		libsofia-sip-ua0 \
		libglib2.0-0 \
		libopus0 \
		libogg0 \
		libcurl4 \
		liblua5.3-0 \
		libconfig9 \
		libusrsctp1 \
		libwebsockets16 \
		libnanomsg5 \
		librabbitmq4 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/lib/libsrtp2.so.1 /usr/lib/libsrtp2.so.1
RUN ln -s /usr/lib/libsrtp2.so.1 /usr/lib/libsrtp2.so

COPY --from=0 /usr/lib/libnice.la /usr/lib/libnice.la
COPY --from=0 /usr/lib/libnice.so.10.10.0 /usr/lib/libnice.so.10.10.0
RUN ln -s /usr/lib/libnice.so.10.10.0 /usr/lib/libnice.so.10
RUN ln -s /usr/lib/libnice.so.10.10.0 /usr/lib/libnice.so

#COPY --from=0 /usr/lib/libwebsockets.so /usr/lib/libwebsockets.so
COPY --from=0 /usr/lib/libwebsockets.so.15 /usr/lib/libwebsockets.so.15
RUN ln -s /usr/lib/libwebsockets.so.15 /usr/lib/libwebsockets.so

#COPY --from=0 /usr/local/lib/libpaho-mqtt3a.so /usr/local/lib/libpaho-mqtt3a.so
#COPY --from=0 /usr/local/lib/libpaho-mqtt3a.so.1 /usr/local/lib/libpaho-mqtt3a.so.1
COPY --from=0 /usr/local/lib/libpaho-mqtt3a.so.1.3 /usr/local/lib/libpaho-mqtt3a.so.1.3
RUN ln -s /usr/local/lib/libpaho-mqtt3a.so.1 /usr/local/lib/libpaho-mqtt3a.so
RUN ln -s /usr/local/lib/libpaho-mqtt3a.so.1.3 /usr/local/lib/libpaho-mqtt3a.so.1

#COPY --from=0 /usr/local/lib/libpaho-mqtt3as.so /usr/local/lib/libpaho-mqtt3as.so
#COPY --from=0 /usr/local/lib/libpaho-mqtt3as.so.1 /usr/local/lib/libpaho-mqtt3as.so.1
COPY --from=0 /usr/local/lib/libpaho-mqtt3as.so.1.3 /usr/local/lib/libpaho-mqtt3as.so.1.3
RUN ln -s /usr/local/lib/libpaho-mqtt3as.so.1 /usr/local/lib/libpaho-mqtt3as.so
RUN ln -s /usr/local/lib/libpaho-mqtt3as.so.1.3 /usr/local/lib/libpaho-mqtt3as.so.1

#COPY --from=0 /usr/local/lib/libpaho-mqtt3c.so /usr/local/lib/libpaho-mqtt3c.so
#COPY --from=0 /usr/local/lib/libpaho-mqtt3c.so.1 /usr/local/lib/libpaho-mqtt3c.so.1
COPY --from=0 /usr/local/lib/libpaho-mqtt3c.so.1.3 /usr/local/lib/libpaho-mqtt3c.so.1.3
RUN ln -s /usr/local/lib/libpaho-mqtt3c.so.1 /usr/local/lib/libpaho-mqtt3c.so
RUN ln -s /usr/local/lib/libpaho-mqtt3c.so.1.3 /usr/local/lib/libpaho-mqtt3c.so.1

#COPY --from=0 /usr/local/lib/libpaho-mqtt3cs.so /usr/local/lib/libpaho-mqtt3cs.so
#COPY --from=0 /usr/local/lib/libpaho-mqtt3cs.so.1 /usr/local/lib/libpaho-mqtt3cs.so.1
COPY --from=0 /usr/local/lib/libpaho-mqtt3cs.so.1.3 /usr/local/lib/libpaho-mqtt3cs.so.1.3
RUN ln -s /usr/local/lib/libpaho-mqtt3cs.so.1 /usr/local/lib/libpaho-mqtt3cs.so
RUN ln -s /usr/local/lib/libpaho-mqtt3cs.so.1.3 /usr/local/lib/libpaho-mqtt3cs.so.1

COPY --from=0 /usr/local/janus/bin/janus /usr/local/janus/bin/janus
COPY --from=0 /usr/local/janus/bin/janus-pp-rec /usr/local/janus/bin/janus-pp-rec
COPY --from=0 /usr/local/janus/bin/janus-cfgconv /usr/local/janus/bin/janus-cfgconv
COPY --from=0 /usr/local/janus/etc/janus /usr/local/janus/etc/janus
COPY --from=0 /usr/local/janus/lib/janus /usr/local/janus/lib/janus
COPY --from=0 /usr/local/janus/share/janus /usr/local/janus/share/janus

ENV BUILD_DATE=${BUILD_DATE}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV GIT_COMMIT=${GIT_COMMIT}
ENV VERSION=${VERSION}

EXPOSE 10000-10200/udp
EXPOSE 8188
EXPOSE 8088
EXPOSE 8089
EXPOSE 8889
EXPOSE 8000
EXPOSE 7088
EXPOSE 7089

CMD ["/usr/local/janus/bin/janus"]
