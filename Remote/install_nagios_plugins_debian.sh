#!/usr/bin/env bash
# 安装Nagios plugins
# -------------------------------------------------------------
###################################################################
#Security-Enhanced Linux
#This guide is based on SELinux being disabled or in permissive mode. Steps to do this are as follows.
echo "开始安装 Nagios plugins"
echo "Step1: SELINUX Disable"
dpkg -l selinux*
if ! command; then echo "Step1 failed"; exit 1; fi
###################################################################
#Prerequisites
#Perform these steps to install the pre-requisite packages.
#===== RHEL 5/6/7 | CentOS 5/6/7 | Oracle Linux 5/6/7 =========
#===== Debian =================================================
echo "Step3: 下载nagios-plugins 2.2.3 到tmp文件夹"
cd /tmp
wget --no-check-certificate https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.3.3/nagios-plugins-2.3.3.tar.gz
tar xzf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
if ! command; then echo "Step3 failed"; exit 1; fi
# -------------------------------------------------------------
#NPRE Installation
echo "Step4: 安装nagios plugins, 并重新启动nrpe服务"
./tools/setup
./configure
make
make install
systemctl restart nrpe
if ! command; then echo "Step4 failed"; exit 1; fi

# 这里是判断上条命令是否执行成功的语句块
if [ $? -eq 0 ]; then
   echo "nrpe 安装成功！"
else
   echo "nrpe 安装失败！"
fi
