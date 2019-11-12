yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install tftp-server dnsmasq syslinux-tftpboot tree python36 jq oniguruma haproxy httpd bind bind-utils vim

systemctl enable httpd
systemctl enable tftp
systemctl enable dnsmasq
systemctl enable haproxy
systemctl enable named


systemctl start httpd
systemctl start tftp
systemctl start dnsmasq
systemctl start haproxy
systemctl start named
