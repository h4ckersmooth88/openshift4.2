# Installation Openshift 4.2 with Storage Rook-Ceph for POC



#### CHAPTER 1. Requirement for POC Openshift 4.2 + Rook-Ceph (VirtualBox or KVM)

> **WARNING :** Please make sure the spec is same and size memory is very important.. Don't set Memory under 12 GB for Cluster Openshift 4.2

1. Master = 1 ( vCPU = 4, Memory = 12 GB, Harddisk = 100 GB )
2. Worker = 4 (vCPU = 4, Memory = 12 GB, Harddisk 1 = 100 GB, Harddisk 2 = 200 GB )
   * for Worker and Storage Node ( Rook-Ceph )
3. Bootstrap = 1 (vCPU = 4, Memory = 12 GB, Harddisk = 100 GB )
4. Helper = 1 ( vCPU = 4 , Memory = 6 GB, Harddisk = 100 GB )

==============================================================================

Network Requirement :

1. Master, Worker and Bootstrap : 1 NIC ( Host-only ), Please make sure not DHCP Server in this Connection.
- Host-only ( 10.10.10.0/24 ) - PLEASE CLEAR NOT DHCP SERVER IN THIS NETWORK

  

2. Helper : 2 NIC (1 NIC for External, 1 NIC for Host-only)
* Helper for DNS Server, HAProxy Load Balancer, DNSMasq, TFTP Server and Router

  - External ( 192.168.1.0/24 ) - INTERNET ACCESS
  - Host-only ( 10.10.10.0/24 ) - PLEASE CLEAR NOT DHCP SERVER IN THIS NETWORK
  

Helper : 10.10.10.1 /24

Bootstrap : 10.10.10.10 /24

Master : 10.10.10.11 /24

Worker : 10.10.10.12 - 10.10.10.17 /24

==============================================================================

 ![OCP_4x_bootstrap.png](https://github.com/openshift-telco/openshift4x-poc/blob/master/static/OCP_4x_bootstrap.png?raw=true) 



#### CHAPTER 2. Set DNS and PTR

Setting A Record in bind :

`root@helper# git clone https://github.com/h4ckersmooth88/openshift4.2`

`root@helper# yum -y install bind bind-utils`

`root@helper# setenforce 0`

`root@helper# cp openshift4.2/dns/named.conf /etc/named.conf`

Setting for PTR :

`root@helper# cp openshift4.2/dns/10.10.10.in-addr.arpa /var/named/`

Setting for A and SRV Record :

`root@helper# cp openshift4.2/dns/ocp4poc.example.com /var/named/`

Please restart the service :

`root@helper# systemctl restart named`

`root@helper# systemctl enable named`



Please make sure DNS can reply your Query, Detail IP you can check /var/named/ocp4poc.example.com :

`root@helper# dig @localhost -t srv _etcd-server-ssl._tcp.ocp4poc.example.com.`

`root@helper# dig @localhost bootstrap.ocp4poc.example.com`

`root@helper# dig -x 10.10.10.10`



Add line nameserver to localhost

```
root@helper# cat /etc/resolv.conf

nameserver 127.0.0.1
nameserver 8.8.8.8
```

NOTE: Update `/var/named/ocp4poc.example.com and 10.10.10.in-addr.arpa` to match environment

#### CHAPTER 3. Set HAProxy for Load Balancer

`root@helper# yum -y install haproxy`

`root@helper# cp openshift4.2/haproxy/haproxy.cfg /etc/haproxy/`

Please edit IP Address for Bootstrap , master and worker.. Please double check in Your DNS Setting

You can inspect **/etc/haproxy/haproxy.cfg** : 

```
Port 6443 : bootstrap and master ( API)
Port 22623 : bootstrap and master ( machine config)
Port 80 : worker ( ingress http)
Port 443 : worker ( ingress https)
Port 9000 : GUI for HAProxy
```



#### CHAPTER 4. Preparation Installation Core OS

Please download in cloud.redhat.com and choose Red Hat Openshift Cluster Manager :

![image-20191121164418499](D:\LinkedIn\image-20191121164418499.png)

Choose Bare Metal :

![image-20191121164524796](D:\LinkedIn\image-20191121164524796.png)



![image-20191121164655226](D:\LinkedIn\image-20191121164655226.png)

Download RHCOS :

https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.2/latest/

Download Command-Line Interface :

https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/



#### CHAPTER 5. Set Web Server

`root@helper# yum -y install httpd`

change the port Listen to Port 8000

`root@helper# cp openshift4.2/httpd/httpd.conf /etc/httpd/conf/httpd.conf`

`root@helper# mkdir -p /var/www/html/metal/`



Please check location your download installer RHCOS :

`root@helper# cp rhcos-4.2.0-x86_64-metal-bios.raw.gz /var/www/html/metal`

Start the services :

`root@helper# systemctl start httpd`

`root@helper# systemctl enable httpd`



#### CHAPTER 6. Set Tftpd Server and DNSMasq

`root@helper# yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

`
root@helper# yum -y install tftp-server dnsmasq syslinux-tftpboot tree python36 jq oniguruma`



Disable DNS in DNSmasq by setting `port=0` 

```
vi /etc/dnsmasq.conf
...
port=0
...
```

`root@helper# cp openshift.4.2/dnsmasq/dnsmasq-pxe.conf /etc/dnsmasq.d/dnsmasq-pxe.conf`

NOTE: Update `/etc/dnsmasq.d/dnsmasq-pxe.conf` to match environment

`root@helper# mkdir -pv /var/lib/tftpboot/pxelinux.cfg/`

`root@helper# cp openshift4.2/pxelinux.cfg/default /var/lib/tftpboot/pxelinux.cfg/default`



You can inspect the file /var/lib/tftpboot/pxelinux.cfg/default

Please check make sure your environment :

1. coreos.inst.install_dev=sda or vda 
2. coreos.inst.ignition_url and coreos.inst.image_url



`root@helper# systemctl restart tftp`

`root@helper# systemctl enable fftp`

`root@helper# systemctl restart dnsmasq`

`root@helper# systemctl enable dnsmasq`



#### CHAPTER 7. Prepare Router and Firewall

`root@helper# chmod 777 openshift4.2/patch/firewall.sh`

Please edit interface NIC with your environment firewall.sh

`root@helper# ./firewall.sh`



#### CHAPTER 7. Prepare Ignition File

Extract tools openshift

`root@helper# tar -xvf openshift-client-linux-4.2.2.tar.gz`

`root@helper# tar -xvf openshift-install-linux-4.2.2.tar.gz`

`root@helper# mv oc kubectl openshift-install /usr/bin/`



create the installation manifests

root@helper# openshift-install create manifests

Prevent Pods from being scheduled on the control plane machines

2. sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' manifests/cluster-scheduler-02-config.yml

Generate ignition configs
3.openshift-install create ignition-configs

Monitoring Bootstrap

4. openshift-install wait-for bootstrap-complete --log-level debug

#### CHAPTER 7. Monitoring Installation Master and Worker Openshift 4.2

#### CHAPTER 8. Installation Rook-Ceph

#### CHAPTER 9. Deploy Application using Ceph RBD Volume

#### CHAPTER 10. Deploy Application using CephFS Volume

#### CHAPTER 11. Configuration Object Storage Ceph




5. export KUBECONFIG=/<PATH INSTALL IGNITION>/auth/kubeconfig

Setup Storage -> not use PV
6. oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"emptyDir":{}}}}'

See the request certification
7.watch oc get csr

Approve with one shot
8. oc get csr --no-headers | awk '{print $1}' | xargs oc adm certificate approve

Checking installation is complete
9. openshift-install wait-for install-complete

If you want upgrade the latest version in Openshift 4.2.X

10. oc adm upgrade --to-latest=true
