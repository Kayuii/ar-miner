FROM alpine:3.12 as builder

ARG VER=v1.0.7.5
ENV PATH=$PATH:/opt
ENV TZ=Asia/Shanghai

RUN apk --no-cache add bash tzdata \
 && mkdir -p /tmp/miner /tmp/xproxy /opt/miner /opt/xproxy  \
 && echo "https://github.com/hpool-dev/arweave-miner/releases/download/${VER}/arweave-miner-${VER}.zip" \
 && wget -q --no-check-certificate https://github.com/hpool-dev/arweave-miner/releases/download/${VER}/arweave-miner-${VER}.zip -O /tmp/ar-miner.zip \
 && unzip -j /tmp/ar-miner.zip -d /tmp/miner \
 && mv /tmp/miner/* /opt/miner/ \
 && echo "https://github.com/hpool-dev/arweave-miner/releases/download/${VER}/x-proxy-1.2.9.0.zip" \
 && wget -q --no-check-certificate https://github.com/hpool-dev/arweave-miner/releases/download/${VER}/x-proxy-1.2.9.0.zip -O /tmp/ar-xproxy.zip \
 && unzip -j /tmp/ar-xproxy.zip -d /tmp/xproxy \
 && mv /tmp/xproxy/* /opt/xproxy/ \
 && cp /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && cat /etc/timezone \
 && rm -rf /tmp/* \
 && apk del tzdata

FROM ubuntu:20.04 as xproxy

ENV PATH=$PATH:/opt
WORKDIR /opt

COPY --from=builder /etc/localtime /etc
COPY --from=builder /etc/timezone /etc
COPY --from=builder /opt/xproxy/x-proxy-linux-* /opt

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates curl gosu tini \
    && cd /opt/ \
    && mv x-proxy-* x-proxy \
    && ls -al /opt/

COPY docker-xproxy-entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["tini", "--", "entrypoint.sh"]

CMD ["x-proxy"]


FROM ubuntu:20.04 as miner

ENV PATH=$PATH:/opt
WORKDIR /opt

COPY --from=builder /etc/localtime /etc
COPY --from=builder /etc/timezone /etc
COPY --from=builder /opt/miner/arweave-miner-linux-* /opt

RUN apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends ca-certificates curl gosu tini \
    && cd /opt/ \
    && mv arweave-miner-* hpool-ar-miner \
    && ls -al /opt/

COPY docker-entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["tini", "--", "entrypoint.sh"]

CMD ["hpool-ar-miner"]
