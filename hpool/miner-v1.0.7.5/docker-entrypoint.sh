#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
    echo "$0: assuming arguments for hpool-ar-miner"
    set -- hpool-ar-miner "$@"
fi

if [ ! -f config.yml ]; then
cat <<-EOF > "/opt/config.yml"
url: "http://0.0.0.0:9090"
threadNum: 0
minerName: ""
disableDirectIo: false
logger:
  level: "info"
  outputs: "Console"
paths: ["/mnt/dst"]
# 0表示从第0线程开始绑，12表示从第12个。-1 不绑定
cpuIndex: -1
EOF
fi

if [ "$1" = "hpool-ar-miner" ] ; then
    if [ -n "$THREAD" ]; then
        echo "$(sed "/threadNum: 0$/c threadNum: $THREAD" config.yml)" > config.yml
    fi
    if [ -n "$HOSTNAME" ]; then
        echo "$(sed "/minerName:$/c minerName: $HOSTNAME" config.yml)" > config.yml
    fi
    if [ -n "$PROXY" ]; then
        echo "$(sed "s!url: \"http://0.0.0.0:9090\"!url: \"$PROXY\"!g" config.yml)" > config.yml
    fi
    if [ -n "$DIR" ]; then
        dirlist=$(find $DIR -name "*.ar" -type f |awk -F'/' 'OFS="/"{$NF="";print $0}'|sort|uniq|awk '{ORS="\",";print "\""$0 }')
        echo "$(sed "/paths: \[\"\/mnt\/dst\"\]/cpaths: \[${dirlist%?}\]" config.yml)" > config.yml
    fi
    if [ -n "$CPUID" ]; then
        echo "$(sed "/cpuIndex: -1$/c cpuIndex: $CPUID" config.yml)" > config.yml
    fi
    # chown -hR nobody .
    # chown -hR nobody $DIR
    cat config.yml
    echo "run : $@ "
    # exec gosu nobody "$@"
    exec "$@"
fi

echo "run some: $@"
exec "$@"
