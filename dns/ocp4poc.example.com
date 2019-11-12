$TTL 1D
@   IN SOA  bastion.ocp4poc.example.com.  root.ocp4poc.example.com. (
            2019052001  ; serial
            1D          ; refresh
            2H          ; retry
            1W          ; expiry
            2D )        ; minimum

@           IN NS       bastion.ocp4poc.example.com.
@           IN A        10.10.10.1

; Ancillary services
lb          IN A        10.10.10.1
lb-ext      IN A        10.10.10.1

; Bastion or Jumphost
bastion     IN A        10.10.10.1

; OCP Cluster
bootstrap   IN A        10.10.10.10

master-0    IN A        10.10.10.11

worker-0    IN A        10.10.10.12

etcd-0      IN A        10.10.10.11

_etcd-server-ssl._tcp.ocp4poc.example.com.  IN SRV  0   0   2380    etcd-0.ocp4poc.example.com.

api         IN CNAME    lb-ext  ; external LB interface
api-int     IN CNAME    lb      ; internal LB interface

apps        IN CNAME    lb-ext
*.apps      IN CNAME    lb-ext 

