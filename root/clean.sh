cd $(dirname $0)
service apache2 stop
service dnsmasq stop
rm -f /etc/dnsmasq.conf
rm -f /srv/tftp/pxe_ubuntu2204/pxelinux.cfg/default
rm -f /srv/tftp/pxe_ubuntu2204/grub/grub.cfg
rm -f /srv/tftp/ipxe_ubuntu2204/ubuntu2204.cfg
rm -f /var/www/html/jammy/user-data
rm -f /var/www/html/jammy/vmlinuz
rm -f /var/www/html/jammy/initrd
rm .viminfo
rm /var/log/apache2/access.log
rm /var/log/apache2/other_vhosts_access.log
rm /var/log/apache2/error.log
rm /var/www/html/workspace/log/error.log
rm /var/www/html/workspace/log/other_vhosts_access.log
rm /var/www/html/workspace/log/access.log
rm /var/www/html/workspace/log/dnsmasq.log
cat /dev/null > ~/.bash_history
rm -f /var/log/dpkg.log
rm -f /var/log/apt/eipp.log.xz
rm -f /var/log/apt/history.log
rm -f /var/log/apt/term.log
ps aux | grep podsys-monitor