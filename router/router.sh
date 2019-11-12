echo "net.ipv4.conf.default.rp_filter = 2" >> /etc/sysctl.conf 
echo "net.ipv4.conf.all.rp_filter = 2" >> /etc/sysctl.conf 

echo 2 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 2 > /proc/sys/net/ipv4/conf/all/rp_filter
sysctl -w net.ipv4.ip_forward=1