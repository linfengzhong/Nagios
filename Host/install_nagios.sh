#!/bin/sh
#
# Author: Linfeng Zhong (Fred)
# 2021-April-06 [Initial Version] - Shell Script for Nagios Core installing
# Nagios Core - Installing Nagios Core From Source
#
#
#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#notification information
Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

#从VERSION中提取发行版系统的英文名称，为了在debian/ubuntu下添加相对应的Nginx apt源
VERSION=$(echo "${VERSION}" | awk -F "[()]" '{print $2}')

check_system() {
    if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}"
        INS="yum"
    elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
        INS="apt"
        $INS update
        ## 添加 Nginx apt源
    elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
        echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME} ${Font}"
        INS="apt"
        $INS update
    else
        echo -e "${Error} ${RedBG} 当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，安装中断 ${Font}"
        exit 1
    fi

# Install dbus --> D-Bus是一个为应用程序间通信的消息总线系统, 用于进程之间的通信
    $INS install dbus

    systemctl stop firewalld
    systemctl disable firewalld
    echo -e "${OK} ${GreenBG} firewalld 已关闭 ${Font}"

    systemctl stop ufw
    systemctl disable ufw
    echo -e "${OK} ${GreenBG} ufw 已关闭 ${Font}"
}

is_root() {
    if [ 0 == $UID ]; then
        echo -e "${OK} ${GreenBG} 当前用户是root用户，进入安装流程 ${Font}"
        sleep 3
    else
        echo -e "${Error} ${RedBG} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}"
        exit 1
    fi
}
judge() {
    if [[ 0 -eq $? ]]; then
        echo -e "${OK} ${GreenBG} $1 完成 ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 失败${Font}"
        exit 1
    fi
}
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
# httpd -> Apache Web Server
echo "Step2: Prerequisites"
yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix
if ! command; then echo "Step2 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Downloading the Source
echo "Step3: Downloading the Source"
echo "nagios-4.4.5."
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
tar xzf nagioscore.tar.gz
if ! command; then echo "Step3 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Compile
echo "Step4: Compile"
cd /tmp/nagioscore-nagios-4.4.5/
./configure
make all
if ! command; then echo "Step4 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Create User And Group
# This creates the nagios user and group. 
# The apache user is also added to the nagios group.
echo "Step5: Create User And Group"
make install-groups-users
usermod -a -G nagios apache
if ! command; then echo "Step5 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Install Binaries
# This step installs the binary files, CGIs, and HTML files.
echo "Step6: Install Binaries"
make install
if ! command; then echo "Step6 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Install Service / Daemon
# This installs the service or daemon files and also configures them to start on boot. 
# The Apache httpd service is also configured at this point.
echo "Step7: Install Service / Daemon"
make install-daemoninit
systemctl enable httpd.service
if ! command; then echo "Step7 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Install Command Mode
# This installs and configures the external command file.
echo "Step8: Install Command Mode"
make install-commandmode
if ! command; then echo "Step8 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Install Configuration Files
# This installs the *SAMPLE* configuration files. 
# These are required as Nagios needs some configuration files to allow it to start.
echo "Step9: Install Configuration Files"
make install-config
if ! command; then echo "Step9 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Install Apache Config Files
# This installs the Apache web server configuration files. 
# Also configure Apache settings if required.
echo "Step10: Install Apache Config Files"
make install-webconf
if ! command; then echo "Step10 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Configure Firewall
# You need to allow port 80 inbound traffic on the local firewall 
# so you can reach the Nagios Core web interface.
echo "Step11: Configure Firewall"
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=80/tcp --permanent
if ! command; then echo "Step11 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Create nagiosadmin User Account
# You'll need to create an Apache user account to be able to log into Nagios.
# The following command will create a user account called nagiosadmin and 
# you will be prompted to provide a password for the account.
echo "Step12: Create nagiosadmin User Account"
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
if ! command; then echo "Step12 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Start Apache Web Server
echo "Step13: Start Apache Web Server"
systemctl start httpd.service
if ! command; then echo "Step13 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# Start Service / Daemon
# This command starts Nagios Core.
echo "Step14: Start Service / Daemon for Nagios Core"
systemctl start nagios.service
if ! command; then echo "Step14 failed"; exit 1; fi
#-----------------------------------------------------------------------------
# 
# Test Nagios
# Nagios is now running, to confirm this you need to log into the Nagios Web Interface.
# Point your web browser to the ip address or FQDN of your Nagios Core server, 
# for example:
# http://10.25.5.143/nagios
# http://core-013.domain.local/nagios
#-----------------------------------------------------------------------------
# 
