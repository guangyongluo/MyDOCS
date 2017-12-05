### Java命名和目录服务（JNDI）

###### 1.概述  
JNDI(Java Naming and Directory Interface)既java命名和服务接口。JNDI是Java平台的一个标准扩展，提供了一组关于接口、类和命名空间的概念。在分布式系统中JNDI通常被用来获取共享的组件和资源，它使用命名和目录服务将名称与位置、服务、信息、资源关联起来。其中的命名服务提供名称-对象的映射，目录服务提供有关对象的信息，并提供定位这些对象所需的搜索工具。

###### 2.原理  
JNDI 的主要功能可以这样描述，它使用一张哈希表存储对象（大多数的J2EE容器也的确是这样做的），然后，开发人员可以使用键值——也就是一个字符串来获 取这个对象。这里就包括取JNDI的两个最主要操作，bind和lookup。bind操作负责往哈希表里存对象，存对象的时候要定义好对象的键值字符 串，lookup则根据这个键值字符串往外取对象。  
JNDI的命称可能会让人产生混淆，似乎觉得这是一个用来操作目录的，事实上，我更愿意把这个目录理解成为JNDI存放对象时使用的格式，也就是说，JNDI以目录的方式存储对象的属性。例如，用户通过JNDI存储一个汽车对象，那么，汽 车就是根目录，汽车的轮子、引擎之类的子对象就算是子目录，而属性，比如说汽车的牌子、重量之类，就算是汽车目录下的文件。  

###### JNDI在Java EE中的应用  
JNDI技术是Java EE规范中的一个重要“幕后”角色，它为Java EE容器、组件提供者和应用程序之间提供了桥梁作用：Java EE容器同时扮演JNDI提供者角色，组件提供者将某个服务的具体实现部署到容器上，应用程序通过标准的JNDI接口就可以从容器上发现并使用服务，而不用关心服务的具体实现是什么，它的具体位置在哪里。  
下面以一个常见的J2EE应用场景来看四种角色（组件接口、容器、组件提供者、应用程序）是如何围绕JNDI来发挥作用的：  
* 组件接口 : 数据源DataSource是一种很常见的服务。我们通常将组件接口绑定到容器的Context上供客户调用。  
* Java EE容器 : Tomcat是一种常见的Java EE容器，其他的还有JBoss,WebLogic，它们同时也实现了JNDI提供者规范。容器通常提供一个JNDI注入场所供加入组件的具体实现，比如 Tomcat中的Server.xml配置文件。
* 组件提供者: 众多数据库厂商提供了DataSource的实现，比如OracleDataSource，MySQLDataSource，XXXDataSource 等。我们将该实现的部署到容器中：将一系列jar加入classpath中，在Server.xml中配置DataSource实现，如：
`<Resource name="jdbc/MyDB" auth="Container" type="javax.sql.DataSource" ..../>`
* 应用程序: 一个JSP/Servlet应用程序。通过JNDI接口使用 DataSource服务，如：
```
Context initContext = new InitialContext();
Context envContext  = (Context)initContext.lookup("java:/comp/env");
DataSource ds = (DataSource)envContext.lookup("jdbc/MyDB");
```