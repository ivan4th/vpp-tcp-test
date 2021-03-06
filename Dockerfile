ARG BASE
FROM $BASE

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y build-essential libssl-dev git curl wget iproute2 dumb-init gdb \
    nginx gnupg apt-transport-https
RUN git clone https://github.com/wg/wrk.git wrk
RUN cd wrk && \
    make -j && \
    cp wrk /usr/local/bin

COPY start.sh /
COPY test.sh /

ENTRYPOINT ["dumb-init", "--"]
CMD ["/start.sh"]
