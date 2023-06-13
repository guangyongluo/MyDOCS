# Amazon Virtual Private CLoud(Amazon VPC)学习手册

### 1.Amazon Virtual Private CLoud(Amazon VPC)基础概念
Amazon Virtual Private CLoud(Amazon VPC)可以让你预制一个逻辑上相互隔离的虚拟网络，你可以在这些虚拟网络上运行AWS的资源。你可以配置你的虚拟网络环境，包括：选择IP地址范围，创建子网，配置路由表和网关。你也可以使用IPv4或者IPv6的地址来访问你的资源与应用。在AWS Region中拥有多个可用区(Availability Zone)，一个VPC可以跨越多个可用区。internet gateway(IGW)是一个横向扩展的，冗余的，高可用的VPC组件，VPC中的实例可以通过IGW来与internet进行通信，

### 2. VPC对等连接
一个VPC对等连接是指两个VPC之间通过私网IPv4地址或者IPv6地址进行的流量路由的一种网络连接。需要注意的是所有需要建立VPC对等连接的VPC的CIDRS都不能有重叠的IP地址。对等连接的缺点是只能打通两两VPC之间的连通性，但是这种连通性不能传递，如果VPC的数量很多需要重复创建两两之间的对等连接保证所有VPC之间的连通性。

### 3. 传输网关

AWS传输网关通过中央集线器连接Amazon VPC和你的本地网络。这个连接简化你的网络中复杂的对等关系，传输网关相当于高度可扩展的云路由器，每个新连接只创建一次。

