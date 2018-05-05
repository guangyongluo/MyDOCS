### Filter过滤器
对于Web应用程序来说，过滤器是一个驻留在服务器端的Web组件，它可以截取客户端和资源之间的请求与响应信息，
并对这些信息进行过滤，当Web容器接收到一个对资源的请求时，它将判断是否有过滤器与这个资源相关。如果有，那
么容器将把请求交给过滤器进行处理。在过滤器中，你可以改变请求的内容，或者重新设置请求的报头信息，然后再
将请求发送给目标资源。当目标资源对请求作出响应时，容器同样会将响应先转发给过滤器，在过滤器中，你可以对响应
的内容进行转换，然后再将响应发送到客户端。

###### Filter接口
在Filter接口中定义了三个方法：
1. init(FilterConfig filterConfig)：Web容器调用该方法来初始化过滤器。容器在调用该方法时，向过滤器传递FilterConfig对象，FilterConfig
的用法和ServletConfig类似。利用FilterConfig对象可以得到ServletContext对象，以及在部署描述符中配置的过滤器的
初始化参数。在这个方法中，可以抛出ServletException异常，通知容器该过滤器不能正常工作。
2. doFilter(ServletRequest request, ServletResponse response, FilterChain chain)：doFilter()方法类似于Servlet接口的Service()方法。当
客户端请求目标资源的时候，容器就会调用与这个目标资源相关联的过滤器的doFilter()方法。在这个方法中，可以对请求和响应进行处理，实现过滤器
的特定功能。在特定的操作完成后，可以调用chain.doFilter(request, response)将请求传给下一个过滤器(或者目标资源)，也可以直接向客户端返回
响应消息，或者利用RequestDispatcher的forward()和include()方法，以及HTTPServletResponse的sendRedirect()方法将请求转向到其他资源。需要
注意的是，这个方法的请求和响应参数的类型是ServletRequest和ServletResponse,也就是说，过滤器的使用并不依赖于具体的协议。
3. destroy()：Web容器调用该方法指示过滤器的生命周期结束。在这个方法中，可以释放过滤器使用的资源。

###### FilterConfig接口
1. getFilterName()：得到在部署描述符中指定的过滤器的名字；
2. getInitParameter()：返回在部署描述符中指定的名字为name的初始化参数的值。如果这个参数不存在，该方法将返回null；
3. getInitParameterNames()：返回过滤器的所有初始化参数的名字的枚举集合；
4. getServletContext()：返回Servlet上下文对象的引用。

###### FilterChain接口
doFilter调用该方法将使过滤器链中的下一个过滤器被调用。如果调用该方法的过滤器是链中最后一个过滤器，那么目标资源被调用。

###### Filter工作流程
在一个Web应用中，可以部署多个过滤器，这些过滤器组成一个过滤器链。
过滤器链中的每个过滤器负责特定的操作和任务，客户端的请求在这些过滤器之间传递，直到目标资源。在请求资源时，
过滤器链中的过滤器将依次对请求进行处理，并将请求传递给下一个过滤器，直到目标资源；在发送响应时，则按照
相反的顺序对响应进行处理，直到客户端。**过滤器并不是必须要将请求传送到下一个过滤器(或目标资源)，它
也可以自行对请求进行处理，然后发送响应给客户端，或者将请求转发给另一个目标资源。**
Filter的工作流程可以参看*Filter工作流程图*  ![图1-1][Servlet_Filter]

###### Filter部署描述
Filter的部署描述与Servlet相似，`<filter-name>`元素用于为过滤器指定一个名字，该元素的内容不能为空。`<filter-class>`
元素用于指定过滤器的完整限定类名。`<init-param>`元素用于为过滤器指定初始化参数，它的子元素`<param-name>`指定参数的名字
，`<param-value>`指定参数的值。在过滤器中，可以使用FilterConfig接口对象来访问初始化参数。`<filter-mapping>`元素用于指定
过滤器关联的URL样式或者Servlet。其中`<filter-name>`子元素的值必须是在`<filter>`元素中声明过的过滤器的名字。`<url-pattern>`
元素和`<servlet-name>`元素可以选择一个；`<url-pattern>`元素指定过滤器关联的URL样式；`<servlet-name>`元素指定过滤器对应的
servlet。用户在访问`<url-pattern>`元素指定的URL上的资源或`<servlet-name>`元素指定的servlet时，该过滤器才会被容器调用。
`<filter-mapping>`元素还可以包含0到4个`<dispatcher>`，`<dispatcher>`元素指定过滤器的请求方法，可以是REQUEST，INCLUDE，FORWARD
和ERROR四种之一。
* REQUEST：当用户直接访问页面时，Web容器将会调用过滤器。如果目标资源是通过RequestDispatcher的include()或forward()方法访问时
，那么该过滤器将不会调用。
* INCLUDE：如果目标资源是通过RequestDispatcher的include()方法访问时，那么该过滤器将被调用。除此之外，过滤器不会被调用。
* FORWARD：如果目标资源是通过RequestDispatcher的forward()方法访问时，那么给过滤器将被调用。除此之外，过滤器不会被调用。
* ERROR：如果目标资源是通过声明式异常处理机制调用时，那么该过滤器将被调用。除此之外，过滤器不会被调用。



[Servlet_Filter]: ../image/Servlet_Filter.png "图1-1"