# ebpf-ping

根据topo.json，创建frr容器(路由器)和docker网络，实现互联。

1. 生成 net.sh 和 clean.sh：

`python3 build_sh.py`

2. 创建容器，建立网络：

`bash net.sh`

3. (清除创建的所有容器：)

`bash clean.sh`
