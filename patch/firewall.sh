setenforce 0
echo "net.ipv4.conf.default.rp_filter = 2" >> /etc/sysctl.conf 
echo "net.ipv4.conf.all.rp_filter = 2" >> /etc/sysctl.conf 

echo 2 > /proc/sys/net/ipv4/conf/default/rp_filter
echo 2 > /proc/sys/net/ipv4/conf/all/rp_filter

firewall-cmd --zone=public   --change-interface=enp0s3 --permanent
firewall-cmd --zone=internal --change-interface=enp0s8 --permanent

firewall-cmd --get-active-zones

firewall-cmd --zone=public   --permanent --add-port=6443/tcp 
firewall-cmd --zone=public   --permanent --add-port=22623/tcp 
firewall-cmd --zone=public   --permanent --add-service=http
firewall-cmd --zone=public   --permanent --add-service=https
firewall-cmd --zone=public   --permanent --add-service=dns
firewall-cmd --zone=public   --permanent --add-service=ssh

firewall-cmd --zone=internal --permanent --add-port=6443/tcp
firewall-cmd --zone=internal --permanent --add-port=22623/tcp
firewall-cmd --zone=internal --permanent --add-service=http
firewall-cmd --zone=internal --permanent --add-service=https
firewall-cmd --zone=internal --permanent --add-port=69/udp
firewall-cmd --zone=internal --permanent --add-port=8000/tcp
firewall-cmd --zone=internal --permanent --add-port=9000/tcp
firewall-cmd --zone=internal --permanent --add-service=dns
firewall-cmd --zone=public   --permanent --add-service=ssh
firewall-cmd --zone=internal --permanent --add-service=dhcp
firewall-cmd --zone=public --permanent --add-masquerade --permanent
firewall-cmd --reload

firewall-cmd --zone=internal  --list-services
firewall-cmd --zone=internal  --list-ports
