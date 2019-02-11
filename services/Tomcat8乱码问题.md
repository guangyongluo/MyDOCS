##### Tomcat8控制台乱码问题三步解决方案

###### 问题原因：
Tomcat8默认使用UTF-8编码，而windows系统控制台默认使用GBK编码方式，所以当Tomcat有信息输出到控制台时就变成乱码了。

解决步骤：

1. 修改Tomcat安装目录中bin文件夹下的startup.bat文件(rem为windows批处理文件的注释关键字)，将 call "%EXECUTABLE%" start 
%CMD_LINE_ARGS%  修改为  call "%EXECUTABLE%" run %CMD_LINE_ARGS%  ：
```
rem call "%EXECUTABLE%" start %CMD_LINE_ARGS%
call "%EXECUTABLE%" run %CMD_LINE_ARGS%
```

2. 修改Tomcat安装目录中bin文件夹下的catalina.bat文件，将 set "JAVA_OPTS=%JAVA_OPTS% %JSSE_OPTS%"  修改为  set 
"JAVA_OPTS=%JAVA_OPTS% %JSSE_OPTS%  -Dfile.encoding=UTF-8"
```
rem set "JAVA_OPTS=%JAVA_OPTS% %JSSE_OPTS%"
set "JAVA_OPTS=%JAVA_OPTS% %JSSE_OPTS% -Dfile.encoding=UTF-8"
```

3. 添加Windows系统注册表中的字符串值：
*  运行（win+r） --> 输入 regedit 打开注册表；
*  找到 [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Command Processor]；
*  右键 --> 新建 --> 字符串值；
*  输入数值名称 autorun ；输入数值数据 chcp 65001，点击确定。

######最新解决方案
直接注销Tomcat安装目录中conf文件夹下logging.properties文件中的一行配置信息如下：
```
#java.util.logging.ConsoleHandler.encoding = UTF-8
```

##### request和response乱码问题
经过两天的测试Tomcat8、9都存在post请求默认编码ISO-8859-1，使用
`request.setCharacterEncoding("UTF-8")`无法正确解析中文还是使用默认的ISO-8859-1
的编码。解决方案如下：
```
String temp = req.getParameter(param);

if(temp != null) {
    byte[] encode = temp.getBytes("ISO-8859-1");
    return new String(encode, "UTF-8");
}else {
	return "";
}
```