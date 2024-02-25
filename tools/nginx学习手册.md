# Nginx学习手册

### 1. nginx简介

Nginx是一款轻量级的Web服务器、反向代理服务器，由于它的内存占用少，启动极快，高并发能力强，在互联网项目中广泛应用。

### 2. 常用命令

```shell
#启动nginx
nginx 

#立即停止
nginx -s stop

#执行完当前请求再停止
nginx -s quit

#重新加载配置文件，相当于restart
nginx -s reload

#将日志写入一个新的文件
nginx -s reopen

#测试配置文件
nginx -t
```

### 3.静态网页配置

配置文件示例：

```nginx
server{
  
    listen 8000;
    server_name localhost;
    
    location / {
        root /home/AdminLTE-3.2.0;
        index index.html index2.html index3.html;
    }
  
}
```

虚拟主机server通过listen和server_name进行区分，如果有多个server配置，listen + server_name不能重复。

##### listen

监听可以配置成`IP`或`端口`或`IP+端口` 

```
listen 127.0.0.1:8000; 
listen 127.0.0.1;（ 端口不写,默认80 ） 
listen 8000; 
listen *:8000; 
listen localhost:8000;
```

##### server_name

server_name主要用于区分，可以随便起。也可以使用变量` $hostname `配置成主机名。或者配置成域名：` example.org ` ` www.example.org ` ` *.example.org `如果多个server的端口重复，那么根据`域名`或者`主机名`去匹配 server_name 进行选择。

下面的例子中：

```
curl http://localhost:80`会访问`/usr/share/nginx/html
curl http://nginx-dev:80`会访问`/home/AdminLTE-3.2.0
```

```nginx
# curl http://localhost:80 会访问这个
server {
    listen       80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

 # curl http://nginx-dev:80 会访问这个
server{
    listen 80;
    server_name nginx-dev;#主机名
    
    location / {
        root /home/AdminLTE-3.2.0;
        index index.html index2.html index3.html;
    }
  
}
```

##### location

`/`请求指向 root 目录

location 总是从`/`目录开始匹配，如果有子目录，例如`/css`，他会指向`/static/css`，例如：

```nginx
location /css {
  root /static;
}
```

### 4. 反向代理配置

先解析一下正向代理和反向代理的定义，在**客户端**代理转发请求称为**正向代理**。例如VPN。而在**服务器端**代理转发请求称为**反向代理**。例如nginx。