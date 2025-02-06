docker network create br-0 --subnet=192.168.10.0/24
docker network create br-1 --subnet=192.168.20.0/24
docker run -d --privileged --net=br-1 --name frr-0 quay.io/frrouting/frr:10.2.1
docker run -d --privileged --net=br-0 --name frr-1 quay.io/frrouting/frr:10.2.1
docker network connect br-1 frr-1
docker run -d --privileged --net=br-0 --name frr-2 quay.io/frrouting/frr:10.2.1

docker exec frr-0 sed -i 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons
docker exec frr-0 sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
docker exec frr-0 sed -i 's/ospf6d=no/ospf6d=yes/g' /etc/frr/daemons
docker exec frr-0 sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons
docker exec frr-0 sed -i 's/bfdd=no/bfdd=yes/g' /etc/frr/daemons
docker restart frr-0
docker exec frr-1 sed -i 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons
docker exec frr-1 sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
docker exec frr-1 sed -i 's/ospf6d=no/ospf6d=yes/g' /etc/frr/daemons
docker exec frr-1 sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons
docker exec frr-1 sed -i 's/bfdd=no/bfdd=yes/g' /etc/frr/daemons
docker restart frr-1
docker exec frr-2 sed -i 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons
docker exec frr-2 sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
docker exec frr-2 sed -i 's/ospf6d=no/ospf6d=yes/g' /etc/frr/daemons
docker exec frr-2 sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons
docker exec frr-2 sed -i 's/bfdd=no/bfdd=yes/g' /etc/frr/daemons
docker restart frr-2
sleep 5

# docker exec frr-1 vtysh -c 'conf t' -c 'router ospf' -c 'network 192.168.10.0/24 area 0'
# docker exec frr-2 vtysh -c 'conf t' -c 'router ospf' -c 'network 192.168.10.0/24 area 0'
# docker exec frr-0 vtysh -c 'conf t' -c 'router ospf' -c 'network 192.168.20.0/24 area 0'
# docker exec frr-1 vtysh -c 'conf t' -c 'router ospf' -c 'network 192.168.20.0/24 area 0'

docker exec frr-0 vtysh -c 'conf t' -c 'router isis t0' -c 'is-type level-1' -c 'net 49.0001.0000.0000.0001.00'
docker exec frr-0 vtysh -c 'conf t' -c 'interface eth0' -c 'ip router isis t0'
docker exec frr-1 vtysh -c 'conf t' -c 'router isis t1' -c 'is-type level-1' -c 'net 49.0001.0000.0000.0002.00'
docker exec frr-1 vtysh -c 'conf t' -c 'interface eth0' -c 'ip router isis t1'
docker exec frr-1 vtysh -c 'conf t' -c 'interface eth1' -c 'ip router isis t1'
docker exec frr-2 vtysh -c 'conf t' -c 'router isis t2' -c 'is-type level-1' -c 'net 49.0001.0000.0000.0003.00'
docker exec frr-2 vtysh -c 'conf t' -c 'interface eth0' -c 'ip router isis t2'