# NIO学习手册(Non-blocking IO)

Java IO流是一个庞大的生态环境，Java1.4之前的BIO其内部提供了很多不同的**输入流和输出流**，细分下去还有字节流和字符流，甚至还有**缓冲流**提高 IO 性能，转换流将字节流转换为字符流等等，这些都是传统的Java IO。

> （1）传统的 BIO 是以流为基本单位处理数据的，想象成水流，一点点地传输字节数据，IO 流传输的过程永远是以字节形式传输。
>
> （2）字节流和字符流的区别在于操作的数据单位不相同，字符流是通过将字节数据通过字符集映射成对应的字符，字符流本质上也是字节流。

 BIO 的最大痛点：**阻塞**。

- BIO 如果遇到 IO 阻塞时，线程将会被挂起，直到 IO 完成后才唤醒线程，线程切换带来了额外的开销。
- BIO 中每个 IO 都需要有对应的一个线程去专门处理该次 IO 请求，会让服务器的压力迅速提高。

我们希望做到的是**当线程等待 IO 完成时能够去完成其它事情，当 IO 完成时线程可以回来继续处理 IO 相关操作，不必一直等着 IO 完成。**在 IO 处理的过程中，能够有一个**专门的线程负责监听这些 IO 操作，通知服务器该如何操作**。

我们来看看 BIO 和 NIO 的区别，BIO 是**面向流**的 IO，它建立的通道都是**单向**的，所以输入和输出流的通道不相同，必须建立2个通道，通道内的都是传输0101001···的字节数据。

![bio](../image/bio.jpg)

而在 NIO 中，不再是面向流的 IO 了，而是面向**缓冲区**，它会建立一个**通道（Channel）**，该通道我们可以理解为**铁路**，该铁路上可以运输各种货物，而通道上会有一个**缓冲区（Buffer）**用于存储真正的数据，缓冲区我们可以理解为**一辆火车**。

**通道（铁路）**只是作为运输数据的一个连接资源，而真正存储数据的是**缓冲区（火车）**。即**通道负责传输，缓冲区负责存储。**

![nio](../image/nio.jpg)

### 1. 三大组件 buffer - channel - Selector

##### 缓冲区（Buffer）

缓冲区是**存储数据**的区域，在 Java 中，缓冲区就是数组，为了可以操作不同数据类型的数据，Java 提供了许多不同类型的缓冲区，**除了布尔类型以外**，其它基本数据类型都有对应的缓冲区数组对象。

![nio_byte_buffer](../image/nio_byte_buffer.jpg)

##### ByteBuffer的结构

一开始初始化ByteBuffer时，position=0, limit, capacity = buffer容量

![nio_bytebuffer_01](../image/nio_bytebuffer_01.png)

写模式下，position 是写入位置，limit 等于容量，下图表示写入了 4 个字节后的状态: position=4， limit,capacity = buffer容量

![nio_bytebuffer_02](../image/nio_bytebuffer_02.png)

flip 动作发生后，position 切换为读取位置，limit 切换为读取限制，position=0，limit=4，capacity = buffer容量

![nio_bytebuffer_03](../image/nio_bytebuffer_03.png)

读取 4 个字节后，状态position,limit=4，capacity = buffer容量

![](/Users/luowei/Downloads/Netty教程源码资料/讲义/Netty-讲义/img/0020.png)

clear 动作发生后，状态

![nio_bytebuffer_01](../image/nio_bytebuffer_01.png)

compact 方法，是把未读完的部分向前压缩，然后切换至写模式

![](/Users/luowei/Downloads/Netty教程源码资料/讲义/Netty-讲义/img/0022.png)

##### ByteBuffer常用的方法：

1. allocate()与allocateDirect()

```java
/**
     * class java.nio.HeapByteBuffer -> use JVM heap memory with low efficiency, JVM can GC this memory.
     * class java.nio.DirectByteBuffer -> use Direct system memory with high efficiency, Direct memory
     * invoke system kernel to allocate so need more cup time, and Direct memory must be collected when
     * no need to use.
     */
    log.debug("ByteBuffer.allocate() use heap memory. -> {}", ByteBuffer.allocate(16).getClass());
    log.debug("ByteBuffer.allocateDirect() use system memory. -> {}", ByteBuffer.allocateDirect(16).getClass());
```

2. get()与put()

```java
buffer.put((byte) 0x61); // write a into the buffer.
buffer.flip();
buffer.get(); // read a from from buffer
```

3. get(int i)，get(byte[] bytes)与rewind()

```java
		buffer.put(new byte[]{0x61, 0x62, 0x63, 0x64});  // put a, b, c, d
    byte[] bytes = new byte[4];
    buffer.flip(); // switch to read mode.
    buffer.get(bytes); // read a, b, c, d to byte array.
    
    buffer.rewind(); // reset position to 0

    buffer.get(new byte[2]); // read a, b from byte buffer.
    buffer.mark(); // mark index 2.

    bytes = new byte[2];
    buffer.get(bytes); // read c, d from byte buffer.
    
    buffer.reset(); // set index to mark.
    buffer.get(bytes); // read c, d from byte buffer.

    byte b = buffer.get(2); // read specify index byte, doesn't move position.
```

4. bytebuffer与字符串之间的转换

```java
		ByteBuffer buffer1 = ByteBuffer.allocate(10);
    // ---------String convert to ByteBuffer----------

    // 1. String.getBytes()
    buffer1.put("Hello".getBytes());

    // 2. StandardCharsets
    ByteBuffer buffer2 = StandardCharsets.UTF_8.encode("Hello");

    // 3. ByteBuffer.wrap()
    ByteBuffer buffer3 = ByteBuffer.wrap("Hello".getBytes());

    // ---------ByteBuffer convert to String----------
    buffer1.flip();
    CharBuffer decode1 = StandardCharsets.UTF_8.decode(buffer1);
    log.debug("decode byte buffer1 : {}", decode1);

    CharBuffer decode2 = StandardCharsets.UTF_8.decode(buffer2);
    log.debug("decode byte buffer2 : {}", decode2);

    CharBuffer decode3 = StandardCharsets.UTF_8.decode(buffer3);
    log.debug("decode byte buffer3 : {}", decode3);
```

5. scattering read与gathering write：理解分散读取和集中写入的思想，对于理解Netty源码很重要。

```java
    //------------scattering read---------------
    ByteBuffer buffer1 = ByteBuffer.allocate(3);
    ByteBuffer buffer2 = ByteBuffer.allocate(3);
    ByteBuffer buffer3 = ByteBuffer.allocate(5);

    channel.read(new ByteBuffer[]{buffer1, buffer2, buffer3});

    //------------scattering read---------------
```

6. 解决网络packet fragmentation问题，后面会有更好的办法来处理黏包和半包问题。

```java
public class ByteBufferPackageHandler {

  public static void main(String[] args) {
    ByteBuffer source = ByteBuffer.allocate(32);

    source.put("Hello,world\nI'm zhangsan\nHo".getBytes());
    split(source);

    source.put("w are you?\nhaha!\n".getBytes());
    split(source);
  }

  /**
   * handle the packet fragmentation in the network communications
   * @param source : network packet mock.
   */
  private static void split(ByteBuffer source) {
    source.flip();

    for(int i = 0; i < source.limit(); i++){

      if (source.get(i) == '\n') {

        int length = i + 1 - source.position();

        ByteBuffer target = ByteBuffer.allocate(length);

        for(int j = 0; j < length; j++){
          target.put(source.get());
        }

        debugAll(target);
      }
    }


    source.compact();
  }
}
```

##### NIO文件编程

FileChannel是对一个文件读，写，映射，操作的Channel。FileChannel是线程安全的，可以被多个线程并发使用。同一个进程中的多个FileChannel看到的同一个文件的视图是相同的，由于底层操作系统执行的缓存和网络文件系统协议引起的延迟，不同进程中在同一时间看到的文件视图可能会不同。

##### FileChannel的创建

获取FileChannel的方式有下面四种

- FileChannel.open()直接调用FileChannel的open()方法，传入Path即可获得FileChannel。

```java
// 直接传入Path默认是只读FileChannel
FileChannel fileChannel = FileChannel.open(Path.of("./tmp/test.txt"));
// 和直接传入Path相比，支持传入OpenOption数组
FileChannel channel = FileChannel.open(Path.of("./tmp/test.txt"), StandardOpenOption.WRITE);
```

OpenOption是一个空接口，我们可以传入StandardOpenOption枚举，StandardOpenOption有如下值：

```java
public enum StandardOpenOption implements OpenOption {
		// 可读Channel
    READ,
		// 可写Channel
    WRITE,
		// 如果Channel是可写(WRITE)的，缓冲中的数据会从文件末尾开始写，而不是从头开始写
    APPEND,
		// 如果Channel是可写(WRITE)的，文件的长度会被置为0
    TRUNCATE_EXISTING,
		// 如果文件不存在，则会创建一个新的文件，如果配置了CREATE，则CREATE_NEW会失效
    CREATE,
		// 创建换一个新的文件，如果文件已经存在，则会失败
    CREATE_NEW,
		// Channel关闭时删除
    DELETE_ON_CLOSE,
		// 稀疏文件
    SPARSE,
		// 要求对文件内容或元数据的每次更新都同步写入基础存储设备。
    SYNC,
		// 要求对文件内容的每次更新都同步写入基础存储设备。
    DSYNC;
}
```

- FileInputStream.getChannel()通过FileInputStream的getChannel()方法获取FileChannel，FileInputStream创建的FileChannel不可写，只能读：

```java
FileInputStream fileInputStream = new FileInputStream("./tmp/test.txt");
FileChannel fileChannel = fileInputStream.getChannel();
```

- FileOutputStream.getChannel()通过FileOutputStream的getChannel()方法获取FileChannel，FileOutputStream创建FileChannel不可读，只能写：

```java
FileOutputStream fileInputStream = new FileOutputStream("./tmp/test.txt");
FileChannel fileChannel = fileInputStream.getChannel();
```

- RandomAccessFile.getChannel()通过RandomAccessFile的getChannel()方法获取FileChannel：

```java
RandomAccessFile file = new RandomAccessFile("./tmp/test.txt", "rw");
FileChannel fileChannel = file.getChannel();
```

RandomAccessFile中的模式与OutputStream和InputStream不同的是创建RandomAccessFile需要传入模式，RandomAccessFile的模式也会影响到FileChannel，创建RandomAccessFile可以传入的模式有下面4种：

1. r：只读模式，创建的RandomAccessFile只能读，如果使用只读的RandomAccessFile创建的FileChannel写数据会抛出NonWritableChannelException

2. rw：读写模式，创建的RandomAccessFile即可读，也可写

3. rws：与rw一样，打开以进行读取和写入，并且还要求对文件内容或元数据的每次更新同步写入基础存储设备

4. rwd：与rw一样，打开以进行读取和写入，并且还要求对文件内容的每次更新都同步写入底层存储设备
   
