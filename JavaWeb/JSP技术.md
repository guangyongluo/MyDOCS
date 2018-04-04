### JSP技术

###### JSP生命周期
JSP容器管理JSP页面的生命周期的两个阶段：装换阶段(Translation phase)和执行阶段(Execution phase)。当有一个对JSP页面的客户请求到来时，JSP容器检验JSP页面的语法是否正确，将JSP页面装换为Servlet源文件，然后调用javac工具类编译Servlet源文件生成字节码文件，这一阶段是转换阶段。接下来，Servlet容器加载转换后的Servlet类，实例化一个对象处理客户端的请求，在请求处理完成后，响应对象被JSP容器接收，容器将HTML格式的响应信息发送给客户端，这一阶段就是执行阶段。
从整个过程中我们可以知道，当第一次加载JSP页面时，因为要将JSP文件转换为Servlet类，所以响应速度较慢。当再次请求时，JSP容器就会直接执行第一次请求时产生的Servlet,而不会再重新转换JSP文件，所以其执行速度和原始的Servlet执行速度几乎就相同了。在JSP执行期间，JSP容器会检查JSP文件，看是否有更新或修改。如果有更新或修改，JSP容器会再次编译JSP或Servlet；如果没有更新或修改，就直接执行前面产生的Servlet，这也是JSP相对于Servlet的好处之一。

###### JSP语法
一个JSP页面由元素和模板数据组成。元素是必须由JSP容器处理的部分，而模板数据是JSP容器不处理的部分，例如，JSP页面中的HTML内容，这些内容会直接发送到客户端。在JSP2.0规范中，元素有三种类型：指令元素、脚本元素和动作元素。

1. 指令元素：主要用于为转换阶段提供整个JSP页面的相关信息，指令不会产生任何的输出到当前的输出流中。指令元素的语法形式如下：`<%@ directive {attr="value"} %>`但是要注意的是,在起始的符号中的<和%之间、%和@之间，以及结束符号中的%和>之间不能有任何的空格。指令元素有三种指令：page,include和taglib。
> 1.1 Page指令:有十三个页面属性
>> * language="scriptingLanguage"：指定脚本元素中使用的脚本语言，默认值是Java。
>> * extends="className"：指定JSP转换后的Servlet类从哪一个类继承，属性的值是完整的限定类名。
>> * import="importList"：指定在脚本环境中可以使用的Java类，和Java程序中的import声明类似，该属性的值是以逗号分隔。
>> * session="true|false"：指定在JSP页面中是否可以使用session对象，默认值是true。
>> * buffer="none|sizekb"：指定out对象(类型为JSPWriter)使用的缓冲区大小，如果设置为none，将不使用缓冲区，所有的输出直接通过ServletResponse的PrintWriter对象写出。该设置属性的值只能以kb为单位，默认值是8kb。
>> * autoFlush="true|false"：指定当缓冲区满的时候，缓存的输出是否应该自动刷新。如果设置为false，当缓冲区溢出的时候，一个异常将被抛出。默认值为true。
>> * isThreadSafe="true|false"：指定指定对JSP页面的访这问是否是线程安全的。如果设置为true，则向JSP容器表明个页面可以同时被多个客户端请求访问。如果设置为false，则JSP容器将对转换后的Servlet类实现SingleThreadModel接口。由于该接口在Servlet2.4规范中已经声明为不赞成使用，所以该属性也建议不要使用了。
>> * info="info_text"：该属性用于指定页面的相关信息，该信息可以通过Servlet接口的getServletInfo()方法来得到。
>> * errorPage="error_url"：该属性用于指定当JSP页面发生异常时，将转向哪一个错误处理页面。要注意的是，如果一个页面通过使用该属性定义了错误页面，那么在web.xml文件中定义的任何错误页面将不会被使用。
>> * isErrorPage="true|false"：指定当前JSP页面是否是另一个JSP页面错误处理页面。默认值是false。
>> * contentType="ctinfo"：指定响应JSP页面的MIME类型和字符编码。
>> * pageEncoding="peinfo"：指定JSP页面使用的字符编码。如果指定了这个属性，则JSP页面字符编码使用该属性指定的字符集，如果没有设置这个属性，JSP页面使用contentType属性指定的字符集，如果这两个属性都没有设置，则使用字符集“ISO-8859-1”。
>> * isELIgnored="true|false"：定义在JSP页面中是否执行或忽略EL表达式。如果设置为true，EL表达式将被容器忽略，设置为false，EL表达式将被执行。

2. include指令：用于在JSP页面中静态包含一个文件，该文件可以是JSP页面、HTML网页、文本文件或一段Java代码。使用了include指令的JSP页面在转换时，JSP容器会在其中插入所包含文件的文本或代码。

3. taglib指令：允许页面使用用户定制的标签，taglib指令的语法如下：`<%@ taglib(uri="tagLibraryURI" | tagdir="tagDir") prefix="tagPrefix" %>`。taglib指令由三个属性：uri：唯一地标识和前缀相关的标签库描述符，可以是绝对或者相对的URI。这个URI被用于定位标签库描述符的位置；tagdir：属性指示前缀(prefix)被用于标识安装在/WEB-INF/tags/目录或子目录下的标签文件。一个隐含的标签库描述符被使用。下面三种情况将发生转换(translation)错误：
* 属性值不是以/WEB-INF/tags/开始；
* 属性值没有指向一个已经存在的目录；
* 属性与uri属性一起使用。
prefix:定义一个prefix:tagname形式的字符串前缀，用于区分多个自定义标签。

4. 脚本元素：脚本元素包括三个部分：声明、脚本段和表达式。声明脚本用于声明在其他脚本中可以使用的变量和方法，脚本段是一段Java代码，用于描述在对请求的响应中要执行的动作，表达式脚本元素是Java语言中完整的表达式，在响应请求时被计算，计算的结果将被转换为字符串，插入到输出流中。
* 声明脚本元素用于声明JSP页面的脚本语言中使用的变量和方法。声明必须是完整的声明语句，遵照Java语言的语法。声明不会在当前的输出流中产生任何的输出。声明以<%!开始，以%>结束。**声明变量将作为该类的实例变量或者类变量(声明时使用了static关键字)，在多用户并发访问时，这将导致线程安全问题。**
* 脚本段是在请求处理期间要执行的Java代码段。脚本段可以产生输出，并将输出发送到客户端，也可以是一些流程控制语句。脚本段以<%开始，以%>结束。**在脚本段中可以声明本地变量，在后面的脚本段中可以使用该变量。在JSP中本地变量是线程安全的**
* 表达式元素是Java语言中完整的表达式，在请求处理时计算这些表达式，计算结果将被转换为字符串，插入到当前的输出流中。表达式以<%=开始，以%>结束。

5. 动作元素：动作元素为请求处理阶段提供信息。动作元素遵循XML元素的语法，有一个包含元素名的开始标签，可以有属性、可选的内容、与开始标签匹配的结束标签。动作元素也可以是一个空标签，可以有属性。与XML和XHTML一样，JSP的标签也是区分大小写的。JSP2.0规范定义了一些标准的动作。标准动作是一些标签，它们影响JSP运行时行为和对客户端请求的响应，这些动作有JSP容器来实现。从效果上来说，一个标准动作是嵌入到JSP页面中的一个标签。在页面被转换为Servlet期间，当JSP容器遇到这个标签，就用预先定义的对应于该标签的Java代码来代替它。

6. 对象和范围
在JSP页面中的对象，包括用户创建的对象和JSP隐含的对象，都有一个范围属性。具有page范围的对象被绑定到javax.servlet.jsp.PageContext对象中。在这个范围内的对象，只能在创建对象的页面中访问。可以调用pageContext这个隐含对象的getAttribute()方法来访问具有这种范围类型的对象(pageContext对象还提供了访问其他范围对象的getAttribute方法)，pageContext对象本身也属于page范围。当Servlet类的_jspService()方法执行完毕，属于page范围的对象的引用将被丢弃。page范围内的对象，在客户端每次请求JSP页面时创建，在页面向客户端发送回响应或请求被转发(forward)到其他的资源后被删除。具有request范围对象被绑定到javax.servlet.ServletRequest对象中，可以调用这个隐含对象的getAttribute()方法来访问具有这种范围类型的对象。在调用forward()方法转向的页面或者调用include()方法包含的页面中，都可以访问这个范围内的对象。要注意的是，因为请求对象对于每一个客户请求都是不同的，所以对于每一个新的请求，都要重新创建和删除这个范围内的对象。
session范围的对象被绑定到javax.servlet.http.HttpSession对象中，可以调用session这个隐含对象的getAttribute()方法来访问具有这种范围类型的对象。JSP容器为每一次会话，创建一个HTTPSession对象，在会话期间，可以访问session范围内的对象。具有application范围的对象被绑定到javax.servlet.ServletContext中，可以调用application这个隐含对象的getAttribute()方法来访问具有这种范围类型的对象。在Web应用程序运行期间，所有的页面都可以访问在这个范围内的对象。