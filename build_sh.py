import json

def parse_json(topo_json: str) -> dict:
    with open(topo_json) as file:
        topo = json.loads(file.read())
    return topo

def create_net(topo: dict, out):
    # create network(bridge)
    for i in range(topo["link_num"]):
        out.write("docker network create br-%d --subnet=%s\n" % (i, topo["link_state"][i]["IP"]))

def make_container(topo: dict, out):
    # create container and connect to network(bridge)
    n = topo["point_num"]
    links = topo["link_state"]
    nets = dict()
    for li in range(topo["link_num"]):
        if links[li]["link"][0] in nets:
            nets[links[li]["link"][0]].append(li)
        else:
            nets[links[li]["link"][0]] = [li]
        if links[li]["link"][1] in nets:
            nets[links[li]["link"][1]].append(li)
        else:
            nets[links[li]["link"][1]] = [li]
    for pi in range(n):
        out.write("docker run -d --privileged --net=br-%d --name frr-%d quay.io/frrouting/frr:10.2.1\n" % (nets[pi][0], pi))
        if len(nets[pi]) > 1:
            for li in nets[pi][1:]:
                out.write("docker network connect br-%d frr-%d\n" % (li, pi))

def open_config(topo: dict, out):
    # open ospf, bgp, isis, bfd.
    for i in range(topo["point_num"]):
        out.write("docker exec frr-%d sed -i 's/bgpd=no/bgpd=yes/g' /etc/frr/daemons\n" % i)
        out.write("docker exec frr-%d sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons\n" % i)
        out.write("docker exec frr-%d sed -i 's/ospf6d=no/ospf6d=yes/g' /etc/frr/daemons\n" % i)
        out.write("docker exec frr-%d sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons\n" % i)
        out.write("docker exec frr-%d sed -i 's/bfdd=no/bfdd=yes/g' /etc/frr/daemons\n" % i)
        out.write("docker restart frr-%d\n" % i)

def ospf_config(topo: dict, out):
    # configure ospf
    for link in topo["link_state"]:
        out.write("docker exec frr-%d vtysh -c 'conf t' -c 'router ospf' -c 'network %s area 0'\n" % (link["link"][0], link["IP"]))
        out.write("docker exec frr-%d vtysh -c 'conf t' -c 'router ospf' -c 'network %s area 0'\n" % (link["link"][1], link["IP"]))

def make_clean(clean_file: str, topo: dict):
    # clean container and network
    with open(clean_file, "w") as clean:
        for i in range(topo["point_num"]):
            clean.write("docker kill frr-%d\n" % i)
            clean.write("docker rm frr-%d\n" % i)
        for i in range(topo["link_num"]):
            clean.write("docker network rm br-%d\n" % i)

if __name__ == '__main__':
    output_file = "net.sh"
    topo_json = "topo.json"
    topo = parse_json(topo_json)

    with open(output_file, "w") as out:
        create_net(topo, out)
        make_container(topo, out)

        out.write("\n")
        open_config(topo, out)
        out.write("sleep 5\n")

        out.write("\n")
        ospf_config(topo, out)

    clean_file = "clean.sh"
    make_clean(clean_file, topo)
