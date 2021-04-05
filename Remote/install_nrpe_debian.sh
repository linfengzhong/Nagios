#!/usr/bin/env bash
# 安装Nagios NRPE
# -------------------------------------------------------------
###################################################################
#Security-Enhanced Linux
#This guide is based on SELinux being disabled or in permissive mode. Steps to do this are as follows.
echo "开始安装 Nagios NRPE"
echo "Step1: SELINUX Disable"
dpkg -l selinux*
if ! command; then echo "Step1 failed"; exit 1; fi
###################################################################
#Prerequisites
#Perform these steps to install the pre-requisite packages.
#===== Debian =================================================#
echo "安装必须要的软件和库"
echo "Step2: 开始安装 gcc、libc6、libssl-dev"
apt-get update
apt-get install -y autoconf gcc libc6 libssl-dev
if ! command; then echo "Step2 failed"; exit 1; fi
#===== RHEL 5/6/7 | CentOS 5/6/7 | Oracle Linux 5/6/7 =========
#===== Debian =================================================
echo "Step3: 下载nrpe-4.0.3到tmp文件夹"
cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.3/nrpe-4.0.3.tar.gz
tar xzf nrpe-4.0.3.tar.gz
cd nrpe-4.0.3
if ! command; then echo "Step3 failed"; exit 1; fi
# -------------------------------------------------------------
#NPRE Installation
echo "Step4: 安装nrpe，设置用户和用户组、并初始化和启动nrpe服务"
./configure
make all
make install-groups-users
make install
make install-config
make install-init
systemctl enable nrpe 
systemctl start nrpe
if ! command; then echo "Step4 failed"; exit 1; fi
# -------------------------------------------------------------
#firewall enable port 5666
#===== Debian =================================================
echo "Step5: 设置防火墙开启端口5666"
iptables -I INPUT -p tcp --destination-port 5666 -j ACCEPT
apt-get install -y iptables-persistent
if ! command; then echo "Step5 failed"; exit 1; fi

# 这里是判断上条命令是否执行成功的语句块
if [ $? -eq 0 ]; then
   echo "nrpe 安装成功！"
else
   echo "nrpe 安装失败！"
fi
