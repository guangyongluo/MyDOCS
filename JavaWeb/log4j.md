### 使用log4j进行日志操作
日志管理提供以下几点好处：首先，记录程序运行时的出错信息，便于开发人员分析错误原因，修正Bug；其次，充当集成开发环境中的调试器的作用，向文件或控制台打印代码的调试信息。最后，监控程序运行的情况，周期性的记录到文件中或数据库中，以便日后进行统计分析。
也正是因为日志信息记录的普遍性，所以Apache组织推出了日志管理工具包——Log4j。

###### Log4j介绍
Log4j是Apache的一个开源项目，通过使用Log4j，我们可以控制日志信息输送的目的地是控制台、文件、GUI组件，甚至是套接口服务器、NT的事件记录器、UNIX Syslog守护进程等；我们也可以控制每一条日志的输出格式；通过定义每一条日志信息的级别，我们能够更加细致地控制日志的生成过程。最令人感兴趣的就是，这些可以通过一个配置文件来灵活地进行配置，而不需要修改应用的代码。要下载和了解更详细的内容，还是访问其官方网站吧:http://jakarta.apache.org/log4j

###### Log4j的三大组件：
Log4j主要由三种主要的组件组成：日志记录器(Loggers)，输出端(Appenders)和日志格式化器(Layout)。
1. Logger：控制要启用或禁用哪些日志记录语句，并对日志信息进行级别限制Logger：控制要启用或禁用哪些日志记录语句，并对日志信息进行级别限制；
2. Appenders : 指定了日志将打印到控制台还是文件中；
3. Layout : 控制日志信息的显示格式。

###### Logger组件
在Log4j中，有一个根记录器(org.apache.log4j.Logger类)，位于记录器层次中的顶部，它永远存在，且不能通过名字索引或引用，可以通过调用org.apache.log4j.Logger类的静态方法gerRootLogger()方法来得到它，而其他的记录器则通过静态方法getLogger(String name)来实例化。
记录器还有一个重要的属性——日志级别，在Log4j中将要输出的Log信息定义了5种级别，依次为DEBUG、INFO、WARN、ERROR和FATAL，当输出时，只有级别高过配置中规定的信息才能真正的输出，这样就很方便的来配置不同情况下要输出的内容，而不需要更改代码，这点实在是方便啊。如果一个记录器没有指定日志级别，那么它将从最近的一个指定了级别的祖先继承级别；已经指定了日志级别，那么它将不会从它的祖先继承日志级别。在Logger类中，定义了生成日志信息的打印方法：debug(),info(),warn(),error(),fatal()和log()。这些打印方法在生成日志信息之前，会先检查日志请求级别。
在Log4j中，记录器还有两个特点。一是当我们用同样的名字调用getLogger()方法，将总是返回同一个记录器对象的引用，这有利于我们在不同的代码或类中用同一个记录器记录日志信息。另一个是与自然界中祖先先于后代出现不同，一个记录器的祖先可以比后代记录器出现的晚，但会自动根据名字之间的关系建立这种家族关系。

###### Appender组件
在Log4j中，信息通过Appender组件输出到目的地，一个Appender实例就表示了一个输出目的地。目前，Appender组件支持将日志信息输出到控制台、文件、GUI组件、远程套接字服务器、JMS、NT事件记录器以及远程UNIX Syslog守护进程。每个Logger都可以拥有一个或多个Appender，每个Appender表示一个日志的输出目的地。可以使用Logger.addAppender(Appender app)为Logger增加一个Appender，也可以使用Logger.removeAppender(Appender app)为Logger删除一个Appender。
以下为Log4j几种常用的输出目的地：
* org.apache.log4j.ConsoleAppender：将日志信息输出到控制台。
* org.apache.log4j.FileAppender：将日志信息输出到一个文件。
* org.apache.log4j.DailyRollingFileAppender：将日志信息输出到一个日志文件，并且每天输出到一个新的日志文件。
* org.apache.log4j.RollingFileAppender：将日志信息输出到一个日志文件，并且指定文件的尺寸，当文件大小达到指定尺寸时，会自动把文件改名，同时产生一个新的文件。
* org.apache.log4j.WriteAppender：将日志信息以流格式发送到任意指定地方。
* org.apache.log4j.jdbc.JDBCAppender：通过JDBC把日志信息输出到数据库中。

###### Layout组件
Layout组件负责格式化输出日期信息，一个Appender只能有一个Layout。主要有以下几种Layout。
* org.apache.log4j.SimpleLayout：输出由日志的级别+"-"+日志消息组成。
* org.apache.log4j.HTMLLayout：表格的方式输出日志信息。
* org.apache.log4j.XMLLayout：输出由一系列在log4j.dtd中定义的<log4j:event>元素组成的。
* org.apache.log4j.TTCCLayout：输出由时间(time)、线程(Thread)、类别(category)和嵌套的诊断上下文(context)信息组成。
* org.apache.log4j.PatternLayout：提供了和C语言printf()方法一样的灵活性，让程序员可以按照一定的转换模式指定日志信息的输出格式。
