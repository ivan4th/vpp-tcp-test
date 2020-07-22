FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y build-essential libssl-dev git curl wget iproute2 dumb-init gdb \
    nginx gnupg apt-transport-https
RUN curl -L https://packagecloud.io/fdio/master/gpgkey | apt-key add - && \
    echo 'deb https://packagecloud.io/fdio/master/ubuntu/ bionic main' \
      > /etc/apt/sources.list.d/fdio_master.list && \
    apt-get update && \
    apt-get install -y vpp vpp-plugin-core vpp-dbg vpp-dev vpp-ext-deps
RUN git clone https://github.com/wg/wrk.git wrk
RUN cd wrk && \
    make -j && \
    cp wrk /usr/local/bin

COPY start.sh /
COPY test.sh /

ENTRYPOINT ["dumb-init", "--"]
CMD ["/start.sh"]
