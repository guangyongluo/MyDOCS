### 使用RabbitMQ Java Client实现RPCdemo

在这篇文档中我们将使用RabbitMQ搭建一个RPC远程调用服务系统，包含一个客户端和一个可扩展的RPC服务器。以下demo创建一个远程调用服务返回斐波纳契数字。使
用RabbitMQ来进行远程调用是很容易的，客户端发送一个带有回掉队列名字的请求消息给服务器

###### 客户端的逻辑结构
在这个客户端里使用一个方法名为Call的方法发送一个RPC请求然后等待服务器返回结果。逻辑代码如下：
```
FibonacciRpcClient fibonacciRpc = new FibonacciRpcClient();
String result = fibonacciRpc.call("4");
System.out.println( "fib(4) is " + result);
```