#!/usr/bin/env bash

#
# Based on:
# https://extremeshok.com/2012/07/22/raspberry-pi-raspbian-tuning-optimising-optimizing-for-reduced-memory-usage/
#
# This can be executed by calling:
# \curl -L https://raw.github.com/versionzero/fntpi/master/setup.sh | bash -x
#

sudo su

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y autoclean

apt-get -y install libreoffice vim vim-nox screen unzip zip python-software-properties aptitude curl ntp ntpdate git-core wget ca-certificates binutils raspi-config emacs23-nox 

# Remove the extra tty / getty’s | Save: +3.5 MB RAM
sed -i '/[2-6]:23:respawn:\/sbin\/getty 38400 tty[2-6]/s%^%#%g' /etc/inittab
sed -i '/T0:23:respawn:\/sbin\/getty -L ttyAMA0 115200 vt100/s%^%#%g' /etc/inittab

# Enable a 512MB swapfile
echo "CONF_SWAPSIZE=512" > /etc/dphys-swapfile
dphys-swapfile setup
dphys-swapfile swapon

# Enable better usage of the swap
sed -i 's/vm.swappiness=1/vm.swappiness=10/g' /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf

# Enable Preload to speed up load times (Optional)
apt-get install -y preload
sed -i 's/sortstrategy = 3/sortstrategy = 0/g' /etc/preload.conf

# Optimize / mount
sed -i 's/defaults,noatime/defaults,noatime,nodiratime/g' /etc/fstab

# Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6=1" > /etc/sysctl.d/disableipv6.conf
echo 'blacklist ipv6' >> /etc/modprobe.d/blacklist
sed -i '/::/s%^%#%g' /etc/hosts

# Replace Deadline Scheduler with NOOP Scheduler
sed -i 's/deadline/noop/g' /boot/cmdline.txt

# Replace rsyslogd with inetutils-syslogd and remove useless logs
apt-get -y remove --purge rsyslog
apt-get -y install inetutils-syslogd
service inetutils-syslogd stop
for file in /var/log/*.log /var/log/mail.* /var/log/debug /var/log/syslog; do [ -f "$file" ] && rm -f "$file"; done
for dir in fsck news; do [ -d "/var/log/$dir" ] && rm -rf "/var/log/$dir"; done
echo -e "*.*;mail.none;cron.none\t -/var/log/messages\ncron.*\t -/var/log/cron\nmail.*\t -/var/log/mail" > /etc/syslog.conf
mkdir -p /etc/logrotate.d
echo -e "/var/log/cron\n/var/log/mail\n/var/log/messages {\n\trotate 4\n\tweekly\n\tmissingok\n\tnotifempty\n\tcompress\n\tsharedscripts\n\tpostrotate\n\t/etc/init.d/inetutils-syslogd reload >/dev/null\n\tendscript\n}" > /etc/logrotate.d/inetutils-syslogd
service inetutils-syslogd start

# Reboot
shutdown -r now

