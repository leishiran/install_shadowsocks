#!/bin/bash

WORK_SPACE='/root/shadowsocks'

yum -y install vim gcc wget python-devel libffi-devel openssl-devel  python-setuptools 
easy_install pip
pip install --upgrade pip
pip install --upgrade pyopenssl ndg-httpsclient pyasn1 shadowsocks

mkdir -p $WORK_SPACE  >/dev/null 2>&1

# create file config
cat > ${WORK_SPACE}/config << EOF
{
    "server_port":8000,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"1234qwer",
    "timeout":300,
    "method":"rc4-md5"
}
EOF

# create file start.sh
cat > ${WORK_SPACE}/start.sh << EOF
ulimit -HSn 51200
/usr/local/bin/ssserver -c ${WORK_SPACE}/config -d start --log-file /var/log/shadowsocks/run.log
EOF

# create file stop.sh
cat > ${WORK_SPACE}/stop.sh << EOF
/usr/local/bin/ssserver -c ${WORK_SPACE}/config -d stop
EOF

chmod +x ${WORK_SPACE}/start.sh 
chmod +x ${WORK_SPACE}/stop.sh 
mkdir -p /var/log/shadowsocks >/dev/null 2>&1

# optimization for shadowsocks
write_file='/etc/security/limits.conf'
egrep 'optimization for shadowsocks' $write_file ||  cat >> $write_file << EOF
# optimization for shadowsocks
* soft nofile 51200
* hard nofile 51200
EOF

write_file='/etc/sysctl.conf'
egrep 'optimization for shadowsocks' $write_file ||  cat >> $write_file << EOF
# optimization for shadowsocks
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
EOF
sysctl -p
egrep shadowsocks /etc/rc.local || echo "bash ${WORK_SPACE}/start.sh" >> /etc/rc.local

# start the service
echo "Stop the service..."
bash ${WORK_SPACE}/stop.sh > /dev/null 2>&1
sleep 3

echo "Start the service..."
bash ${WORK_SPACE}/start.sh
echo ""
echo ""
echo "Service has been installed and is running now!"
echo "Enjoy yourself!"

