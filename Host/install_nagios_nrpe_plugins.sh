#!/usr/bin/env bash
# 安装Nagios NRPE
# -------------------------------------------------------------
###################################################################
#Security-Enhanced Linux
#This guide is based on SELinux being disabled or in permissive mode. Steps to do this are as follows.
echo "开始安装Nagios NRPE"
echo "Step1: SELINUX Disable"
sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
###################################################################
#Prerequisites
#Perform these steps to install the pre-requisite packages.
#===== RHEL 5/6/7 | CentOS 5/6/7 | Oracle Linux 5/6/7 =====
echo "Step2: 安装gcc、glibc、glibc-common、wget、unzip、httpd、php、gd、gd-devel、perl、postfix"
yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix



# 这里是判断上条命令是否执行成功的语句块
if [ $? -eq 0 ]; then
   echo "succeed"
else
   echo "failed"
fi
