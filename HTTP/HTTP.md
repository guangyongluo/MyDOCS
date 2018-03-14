### HTTP协议详解

###### 请求行与状态行
1. HTTP的请求行的基本格式：`请求方式 资源路径 HTTP版本号<CRLF>`
   例如：GET /test.html HTTP/1.1
   请求方式主要有**GET**、**POST**、HEAD、OPTIONS、DELETE、TRACE、PUT
2. 响应消息中状态行在返回消息中的第一行，其基本格式：HTTP版本号、状态码、原因叙述<CRLF>
   例如：HTTP/1.1 200 OK

###### 传递请求参数参数
* 在URL地址后面可以添加一些参数，例如：
  `http://www.it315.org/servlet/ParamsServlet?param1=abc&param2=xyz`
* GET方式：HTTP默认都会以GET的方式请求如上例URL中的请求参数会被加入到HTTP请求头中，例如：
  `GET /servlet/ParamsServlet?param1=abc&param2=xyz` HTTP/1.1
* POST方式：如果在请求中指定用POST方式来传递参数，参数将放在请求内容中传递给客户端，例如：
  ```
  POST /servlet/ParamsServlet HTTP/1.1
  HOST:
  Content-Type:application/x-www-form-urlencoded
  Content-Length:28

  param1=abc&param2=xyz
  ```
  * GET方式传递参数由于参数是放在头字段中的所以数据量的大小有限制，一般限制在1K以下。而POST则无此限制，理论上参数的大小没有限制。

###### 响应状态码
响应状态码用于表示服务器对请求的各种不同处理结果和状态，它是一个三位十进制。响应状态码可归为5类使用最高位1-5进行分类
* 100-199 ：表示成功接收请求，要求客户端继续提交下一次请求才能完成整个处理过程。
* 200-299 ：表示成功接收请求并已完成整个处理过程。
* 300-399 ：表示为完成请求，客户需要进一步细化请求。
* 400-499 ：表示客户端请求有误。
* 500-599 ：表示服务器出现错误。

###### 通用信息头
通用信息头字段既能用于请求消息，也能用于响应消息，它包含一些与被传输的实体内容没有关系的常用消息头字段。以下是几个常用的信息头：
1. Cache-Control : no-cache (缓存设置)
2. Connection ：close (服务器处理完请求之后是否继续保持连接的设置)
3. Date ：(请求发起的时间和处理完请求后返回的时间，时间使用GMT格式)
4. Pragma ：no-cache (HTTP 1.1中不缓存当前返回消息)
5. Trailer ：Date (指定某个信息头可以放在实体消息后面)
6. Transfer-Encoding ：chunked (返回消息分段)
7. Upgrade ：HTTP/2.0, SHTTP/1.3 (指定支持的HTTP版本)
8. Via ：HTTP/1.1 proxy1，HTTP/1.1 proxy2 (途径的代理服务器和HTTP协议版本)
9. Warning ：any text

###### 请求头
请求头字段用于客户端在请求消息中向服务器发送传递附加信息，主要包括客户端可以接受的数据类型、压缩方法、语言、以及发出请求的超链接所属网页的URL地址等信息。
1. Accept：自出浏览器能够支持的数据格式；
2. Accept-Charset：用于指出浏览器能够处理的字符集；
3. Accept-Encoding：用于指定浏览器能够进行解码的方式；
4. Accept-Language：用于指定浏览器的国家语言信息；
5. Authorization：用于响应服务器要求的认证机制；
6. Expect：100-continue 用于指定浏览器请求服务器采取特殊的处理；
7. From：用于指定发送者的E-mail地址；
8. Host：用于指定浏览器访问的资源所在的主机名和端口号。
9. If-Match：用于指定浏览器访问资源的ETag，只有服务器上的资源ETag值与请求头中的ETag相同才处理该请求；
10. If-Modified-Since：用于指定上次所缓存网页文档的修改时间；
11. If-Range：用于服务器返回上次所缓存网页文档的修改时间；
12. Range：用于指定服务器只放回部分内容。
13. Referer：用于指定访问请求是从哪里发送的。
14. User-Agent：用于指定客户端浏览器的程序类型。

###### 实体头
实体头用作实体内容的元信息，描述了实体内容的属性，包括实体信息的类型、长度、压缩方式、最后一次修改时间、数据有效性。
1. Allow：指定接受的访问方式；
2. Content-Encoding：指定返回实体内容的压缩方式；
3. Content-Language：指定返回实体内容的语言信息；
4. Content-Length：指定返回实体内容的大小；
5. Content-Location：指定消息中实体的实际位子；
6. Content-MD5：提供实际内容的MD5摘要值校验；
7. Content-Range：用于指定返回的部分实体的位子信息；
8. Content-Type：用于指定实体内容的数据格式和字符集信息；
9. Expires：用于指定当前返回的实体缓存在什么时候过期；
10. Last-Modified：用于指定文档的最后更新时间。

###### 扩展头
* 在HTTP消息中我们也可以使用没有在HTTP/1.1正式规范中没有定义过的头字段，这些头字段统称为自定义HTTP头或扩张头，它们通常被当做一种实体头来处理
* 现在流行的浏览器实际上都支持Cookie、set-Cookie、Refresh和Content-Disposition等几个常用的扩张头字段；

