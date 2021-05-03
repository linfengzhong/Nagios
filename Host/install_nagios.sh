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

list() {
    case $1 in
    tls_modify)
        tls_type
        ;;
    uninstall)
        uninstall_all
        ;;
    crontab_modify)
        acme_cron_update
        ;;
    boost)
        bbr_boost_sh
        ;;
    *)
        menu
        ;;
    esac
}

menu() {
    update_sh
    echo -e "\t V2ray 安装管理脚本 ${Red}[${shell_version}]${Font}"
    echo -e "\t---authored by wulabing---"
    echo -e "\thttps://github.com/wulabing\n"
    echo -e "当前已安装版本:${shell_mode}\n"

    echo -e "—————————————— 安装向导 ——————————————"""
    echo -e "${Green}0.${Font}  升级 脚本"
    echo -e "${Green}1.${Font}  安装 V2Ray (Nginx+ws+tls)"
    echo -e "${Green}2.${Font}  安装 V2Ray (http/2)"
    echo -e "${Green}3.${Font}  升级 V2Ray core"
    echo -e "—————————————— 配置变更 ——————————————"
    echo -e "${Green}4.${Font}  变更 UUID"
    echo -e "${Green}5.${Font}  变更 alterid"
    echo -e "${Green}6.${Font}  变更 port"
    echo -e "${Green}7.${Font}  变更 TLS 版本(仅ws+tls有效)"
    echo -e "—————————————— 查看信息 ——————————————"
    echo -e "${Green}8.${Font}  查看 实时访问日志"
    echo -e "${Green}9.${Font}  查看 实时错误日志"
    echo -e "${Green}10.${Font} 查看 V2Ray 配置信息"
    echo -e "—————————————— 其他选项 ——————————————"
    echo -e "${Green}11.${Font} 安装 4合1 bbr 锐速安装脚本"
    echo -e "${Green}12.${Font} 安装 MTproxy(支持TLS混淆)"
    echo -e "${Green}13.${Font} 证书 有效期更新"
    echo -e "${Green}14.${Font} 卸载 V2Ray"
    echo -e "${Green}15.${Font} 更新 证书crontab计划任务"
    echo -e "${Green}16.${Font} 清空 证书遗留文件"
    echo -e "${Green}17.${Font} 退出 \n"

    read -rp "请输入数字：" menu_num
    case $menu_num in
    0)
        update_sh
        ;;
    1)
        shell_mode="ws"
        install_v2ray_ws_tls
        ;;
    2)
        shell_mode="h2"
        install_v2_h2
        ;;
    3)
        bash <(curl -L -s https://raw.githubusercontent.com/wulabing/V2Ray_ws-tls_bash_onekey/${github_branch}/v2ray.sh)
        ;;
    4)
        read -rp "请输入UUID:" UUID
        modify_UUID
        start_process_systemd
        ;;
    5)
        read -rp "请输入alterID:" alterID
        modify_alterid
        start_process_systemd
        ;;
    6)
        read -rp "请输入连接端口:" port
        if grep -q "ws" $v2ray_qr_config_file; then
            modify_nginx_port
        elif grep -q "h2" $v2ray_qr_config_file; then
            modify_inbound_port
        fi
        start_process_systemd
        ;;
    7)
        tls_type
        ;;
    8)
        show_access_log
        ;;
    9)
        show_error_log
        ;;
    10)
        basic_information
        if [[ $shell_mode == "ws" ]]; then
            vmess_link_image_choice
        else
            vmess_qr_link_image
        fi
        show_information
        ;;
    11)
        bbr_boost_sh
        ;;
    12)
        mtproxy_sh
        ;;
    13)
        stop_process_systemd
        ssl_update_manuel
        start_process_systemd
        ;;
    14)
        uninstall_all
        ;;
    15)
        acme_cron_update
        ;;
    16)
        delete_tls_key_and_crt
        ;;
    17)
        exit 0
        ;;
    *)
        echo -e "${RedBG}请输入正确的数字${Font}"
        ;;
    esac
}
judge_mode() {
    if [ -f $v2ray_bin_dir/v2ray ]; then
        if grep -q "ws" $v2ray_qr_config_file; then
            shell_mode="ws"
        elif grep -q "h2" $v2ray_qr_config_file; then
            shell_mode="h2"
        fi
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
