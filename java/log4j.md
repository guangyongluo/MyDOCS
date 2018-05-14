### Log4j简介
日志管理提供以下几点好处：首先，记录程序运行时的出错信息，便于开发人员分析错误原因，修正Bug；
其次，充当集成开发环境中的调试器的作用，向文件或控制台打印代码的调试信息。最后，监控程序运行
的情况，周期性的记录到文件中或数据库中，以便日后进行统计分析。也正是因为日志信息记录的普遍性，
所以Apache组织推出了日志管理工具包——Log4j。Log4j是Apache的一个开源项目，通过使用Log4j，我们
可以控制日志信息输送的目的地是控制台、文件、GUI组件，甚至是套接口服务器、NT的事件记录器、UNIX
 Syslog守护进程等；我们也可以控制每一条日志的输出格式；通过定义每一条日志信息的级别，我们能够
 更加细致地控制日志的生成过程。最令人感兴趣的就是，这些可以通过一个配置文件来灵活地进行配置，
 而不需要修改应用的代码。要下载和了解更详细的内容，还是访问其官方网站吧:http://jakarta.apache.org/log4j.md

###### log4j主要由三种主要组件构成
1. Logger组件：记录器负责产生日志，并能够对日志信息进行分类筛选，控制什么样的日志应该被输出，
什么样的日志应该被忽略。Log4j允许程序员定义多个记录器，每个记录器有自己的名字，记录器之间通过
名字来表明隶属关系。记录器还有一个重要的属性——日志级别。一共有5种可能的级别，这些级别有高低
之分，从低到高依次是DEBUG，INFO，WARN，ERROR和FATAL，它们在org.apache.log4j.Level类中定义。不
同的记录器可以有不同的级别，如果一个记录器没有指定日志级别，那么它将从最近的一个指定了级别的祖
先继承级别；如果一个记录器已经指定了日志级别，那么它将不会从它的祖先继承日志级别。为了确保所有
的记录器最终都可以继承日志级别，根记录器总是有级别。在Log4j中，记录器还有两个特点。一是当我们
用相同的名字调用getLogger()方法，将总是返回同一个记录器对象的引用，这有利于我们在不同的代码或
类中用同一个记录器记录日志信息。另一个是与自然界中祖先先于后代出现不同，一个记录器的祖先可以
比后代记录器出现的晚，但会自动根据名字之间的关系建立这种家族关系。
2. Appender组件：在Log4j中，信息通过Appender组件输出到目的地，一个Appender实例就表示一个输出的
目的地。一个记录器可以有过个Appender，通过调用Logger类的addAppender()方法来增加Appender。记录器
所处理的每一个日志请求，都会被送往它所拥有的每一个Appender。**需要注意的是，对于Appender的继承，
是一种叠加性继承，而且后代记录器只继承其父记录器的Appender，而不考虑更远的祖先的情况。**

|Appender|描述|
|:--------:|:--------:|
|org.apache.log4j.ConsoleAppender|输出目的地为控制台|
|org.apache.log4j.FileAppender|输出目的地为文件|
|org.apache.log4j.DailyRollingFileAppender|按照用户指定的时间或日期频率滚动产生日志文件|
|org.apache.log4j.RollingFileAppender|当文件到达一定的尺寸时，备份日志文件|
3. Layout组件：Layout组件负责格式化输出的日志信息，一个Appender只能有一个Layout。

|Layout|描述|
|:--------:|:--------:|
|org.apache.log4j.SimpleLayout|输出日志级别-日志消息组成|
|org.apache.log4j.HTMLLayout|以HTML表格方式输出日志消息|
|org.apache.log4j.xml.XMLLayout|输出是由一系列在log4j.dtd中定义的<log4j:event>元素组成的
|org.apache.log4j.TTCCLayout|输出是由时间、线程、类别和嵌套的诊断上下文信息组成。|
|org.apache.log4j.PatternLayout|提供了和C语言一样的灵活性，让程序员可以按照一定的转换模式指定日志信息的输出格式。|

###### 使用log4j
1. 得到日志记录器调用Logger类的静态方法getLogger(String name)来得到。
2. 读取配置文件：目前，配置文件可以使用两种形式，一种是key=value的Java属性格式文件，一种是XML文件。
3. 编写记录日志的语句。

###### 设置log4j三种方法
* BasicConfigurator.configure()：创建一个简单的Log4j设置。这个方法为根记录器添加一个ConsoleAppender的实例，输出的
信息将使用PatternLayout来格式化，格式化语句为“%r [%t] %p %c %x - %m%n”。在默认情况下，根记录器的日志级别设置为
level.DEBUG，也就是最低一级。
* PropertyConfiguration.configure(String configFileName)：读取使用key=value方式编写的配置文件来设置Log4j运行环境。
* DOMConfiguration.configure(String filename)：读取XML格式的配置文件来设置Log4j的运行环境。