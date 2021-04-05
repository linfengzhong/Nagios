#!/usr/bin/env bash
#
#-rw------- (600)    只有拥有者有读写权限。
#-rw-r--r-- (644)    只有拥有者有读写权限；而属组用户和其他用户只有读权限。
#-rwx------ (700)    只有拥有者有读、写、执行权限。
#-rwxr-xr-x (755)    拥有者有读、写、执行权限；而属组用户和其他用户只有读、执行权限。
#-rwx--x--x (711)    拥有者有读、写、执行权限；而属组用户和其他用户只有执行权限。
#-rw-rw-rw- (666)    所有用户都有文件读、写权限。
#-rwxrwxrwx (777)    所有用户都有读、写、执行权限。
#检测配置文件是否 OK 的命令
#/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg 

sudo
cd /tmp
wget --no-check-certificate https://github.com/linfengzhong/Nagios/archive/refs/tags/0.06.zip
unzip 0.06.zip
chmod 777 /tmp/Nagios-0.06/Libexec/check_*
mkdir /usr/local/nagios/etc/objects/myservers
chmod 666 /usr/local/nagios/etc/objects/myservers
chmod 666 /usr/local/nagios/etc/objects/myservers/*

cp -p -f /tmp/Nagios-0.06/Libexec/check_* /usr/local/nagios/libexec
cp -p -f /tmp/Nagios-0.06/Remote/nrpe.cfg /usr/local/nagios/etc/
cp -p -f /tmp/Nagios-0.06/Host/nagios.cfg /usr/local/nagios/etc/
cp -p -f /tmp/Nagios-0.06/Host/myservers/* /usr/local/nagios/etc/objects/myservers

systemctl status nrpe
systemctl restart nrpe

/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

systemctl status nagios 
systemctl restart nagios
