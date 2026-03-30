#!/bin/bash

echo "=== 系统更新 ==="
apt update && apt full-upgrade -y && apt autoremove -y

echo "=== 启用 BBR 模块 ==="
modprobe tcp_bbr
echo "tcp_bbr" | tee -a /etc/modules-load.d/modules.conf

echo "=== 写入 sysctl 网络优化参数 ==="
tee /etc/sysctl.conf <<EOF
# 网络优化参数

# 使用 FQ 队列算法（UDP/Hy2 加速关键）
net.core.default_qdisc=fq

# 启用 BBR 拥塞控制
net.ipv4.tcp_congestion_control=bbr

# 启用 TCP Fast Open（减少握手延迟）
net.ipv4.tcp_fastopen=3

# 增加最大连接队列长度
net.core.somaxconn=65535

# 允许重用 TIME-WAIT sockets
net.ipv4.tcp_tw_reuse=1

# 调整本地端口范围
net.ipv4.ip_local_port_range=1024 65535

# 缩短 FIN-WAIT 超时时间
net.ipv4.tcp_fin_timeout=30

# TCP Keepalive 时间
net.ipv4.tcp_keepalive_time=1200

# Swap 使用策略（降低 Swap 使用频率）
vm.swappiness=10
EOF

sysctl -p

echo "=== 创建 1G Swap ==="
if [ ! -f /swapfile ]; then
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
else
    echo "Swapfile 已存在，跳过创建。"
fi

echo "=== 设置文件描述符限制 ==="
tee /etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
EOF

echo "=== 关闭不必要服务 ==="
systemctl disable --now apport.service
systemctl disable --now multipathd.service
systemctl disable --now multipathd.socket
systemctl disable --now snapd.service
systemctl disable --now snapd.socket

echo "=== 优化完成，请重启系统 ==="