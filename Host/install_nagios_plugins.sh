#!/bin/sh
#
# Author: Linfeng Zhong (Fred)
# 2021-April-06 [Initial Version] - Shell Script for Nagios Plugins installing
# Nagios Plugins - Installing Nagios Plugins From Source
#-----------------------------------------------------------------------------
#===== RHEL 7/8 | CentOS 7/8 | Oracle Linux 7/8 =====
#-----------------------------------------------------------------------------
# Security-Enhanced Linux
# This guide is based on SELinux being disabled or in permissive mode. 
# Steps to do this are as follows.
echo "开始安装Nagios Core"
echo "Step1: Security-Enhanced Linux"
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
if ! command; then echo "Step1 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Prerequisites
# Perform these steps to install the pre-requisite packages.
echo "Step2: Prerequisites"
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
yum install -y perl-Net-SNMP
if ! command; then echo "Step2 failed"; exit 1; fi
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Downloading the Source
#-----------------------------------------------------------------------------
#===== RHEL 5/6/7 | CentOS 5/6/7 | Oracle Linux 5/6/7 =========
#===== Debian =================================================
echo "Step3: 下载Nagios Plugins 2.2.3 到tmp文件夹"
cd /tmp
wget --no-check-certificate https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.3.3/nagios-plugins-2.3.3.tar.gz
tar xzf nagios-plugins-2.3.3.tar.gz
cd nagios-plugins-2.3.3
if ! command; then echo "Step3 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Nagios Plugins Installation
echo "Step4: 安装nagios plugins, 并重新启动nrpe服务"
./tools/setup
./configure
make
make install
systemctl restart nrpe
if ! command; then echo "Step4 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# 这里是判断上条命令是否执行成功的语句块
if [ $? -eq 0 ]; then
   echo "Nagios Plugins 安装成功！"
else
   echo "Nagios Plugins 安装失败！"
fi
# Plugin Installation Location
# The plugins will now be located in /usr/local/nagios/libexec/.