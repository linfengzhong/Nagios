#!/usr/bin/env bash

sudo
cd /tmp
wget --no-check-certificate https://github.com/linfengzhong/Nagios/archive/refs/tags/0.03.zip
unzip 0.03.zip
chmod 777 /tmp/Nagios-0.03/Libexec/check_*
cp -p -f /tmp/Nagios-0.03/Libexec/check_* /usr/local/nagios/libexec
cp -p -f /tmp/Nagios-0.03/Remote/nrpe.cfg /usr/local/nagios/etc/
cp -p -f /tmp/Nagios-0.03/Host/windthroughwall.ml.cfg /usr/local/nagios/etc/objects

systemctl status nrpe
systemctl restart nrpe

systemctl status nagios 
systemctl restart nagios
