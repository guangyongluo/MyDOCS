### Tomcat配置
>tomcat 8.0实测

##### 1. 设置虚拟子目录
* 使用server.xml中的<Context>元素，例如：
`<Context path="/web" docBase="d:/tomcat-web" debug="0" />`
其中path属性为虚拟的web服务路径，docBase属性为文件实际存放在系统中的位置

* 在Tomcat安装目录下的conf\Catalina\localhost目录中新建一个XML文件，内容就是上例中的context元素。虚拟出一个以该XML文件名为虚拟路径的Web服务路径。

##### 2.Tomcat的体系结构
Tomcat的体系结构可以查看server.xml文件中的嵌套关系，一个service元素代表了Tomcat的服务，其中可以有多个Connector代表了请求连接器，主要功能是监听客户端发来的请求。每个Connectoer请求监听器都对应到一个Engine，Engine代表Tomcat的处理引擎，主要处理客户端的请求再将结果资源返回给客户端。一个Engine中又可以有多个Host虚拟主机，每个虚拟主机代表了底层用于处理请求的资源。
Tomcat的体系结构可以参看*Tomcat体系图* ![图2-1][Tomcat_architect]

##### 3.虚拟主机及实现原理
* 在一台计算机上创建多个Web站点，并为每个Web站点设置不同的主目录和虚拟子目录，每个Web站点作为各自独立的网站分配给不同的公司或部门。

* 多个公司或部门的网站可以共用同一台计算机，而用户感觉每个公司和部门都有各自独立的网站。多个没有实力在Internet上架设自己专用服务器的中小公司可以联合租用一台Web服务器，对外提供各自的WEB服务而互不影响。

* 为每个虚拟主机设置不同的标识信息，同时浏览器发出请求时要包含这些标识信息，标识信息主要有三要素：IP地址、端口号、主机名。

* 虚拟主机对应着server.xml中的Host元素，每个Host元素对应着一个站点，用于处理对应Host头字段的客户端请求。

* server文件中的connector元素用于配置一个对外连接器，对于每个Web服务器上的每一个监听端口都有一个connector元素与之对应，对于每一个connector元素监听到的请求都有一个Engine元素对其进行处理，一个Engine元素可以处理多个Connector元素的请求，将Engine和Connector元素关联的方式就是将其放置在同一个service元素下。新建Connector的方式来建立虚拟主机实际上就是使用了不同的端口号来区分不同的虚拟主机。

* 对于对个IP地址的映射需要在客户端或者DNS服务器中配置IP地址和主机名的映射关系后，就可以在Host元素中设置IP的访问方式了。

###### 4.Web应用程序目录结构
一个Web应用程序是由一组Servlet、HTML页面、类，以及其他的资源组成的运行在Web服务器上的完整的应用程序，以一种结构化的由层次的目录形式存在。组成Web应用程序的这些资源文件要部署在相应的目录层次中，根目录代表了整个Web应用程序的根。表4-1 Web应用程序的目录层次结构

|目录|描述|
|:--------:|:--------:|
|\myweb|Web应用程序的根目录，属于此Web应用程序的所有文件都存放在这个目录下|
|\myweb\WEB-INF|存放Web应用程序的部署描述符文件web.xml|
|\myweb\WEB-INF\classes|存放Servlet和其他有用的类文件|
|\myweb\WEB-INF\lib|存放Web应用程序需要用到的JAR文件，这些JAR文件中可以包含Servlet、Bean和其他有用的类文件|
|\myweb\WEV-INF\web.xml|web.xml文件包含Web应用程序的配置和部署信息|

从表中可以看出，WEB-INF目录下的classes和lib目录都可以存放Java的类文件，在Servlet容器运行时，Web应用程序的类加载器将首先加载classes目录下的类文件。如果这两个目录下存在同名的类，起作用的将是classes目录下的类文件。
WEB-INF是个特殊的目录，其名称必须全部大写，而且这个目录不属于Web应用程序可以访问的上下文路径的一部分，对客户端来说，这个目录是不可见的。但是对servlet代码来说是可见的。
Web应用程序的配置和部署都是通过web.xml文件来完成的。web.xml被称为Web应用程序的部署描述符，它可以包含如下的配置和部署信息:
* ServletContext的初始化参数
* Session的配置
* Servlet/JSP的定义
* Servlet/JSP的映射
* MIME类型映射
* 欢迎文件列表
* 错误页面
* 安全
* 地区和编码映射
* JSP配置


[Tomcat_architect]: ../image/Tomcat_architect.png "图2-1"