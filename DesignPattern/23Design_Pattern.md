# 重温23种设计模式

代码码的太久，一直写，没有过多的考虑代码的编码风格，这样的代码自己看起来都费劲，今天23-11-17开始重温SOLID设计原则和23种设计模式，在以后的编码中要多做设计方面的思考，不能盲目的一通写，合理的结合业务来产出优雅的代码。

### SOLID原则：

SOLID是五个面向对象的设置原则的首字母，这些设计原则建立了最佳实践，这些实践可以帮助开发者在项目不断的推进的过程考虑到了代码的可维护性和可扩展性。在开发项目时采用这个设计原则可以有效的避免代码复杂导致的代码重构，阅读困难，同时使代码修改更加敏捷和方便。

1. **责任单一原则**：一个类应该只承担一个任务，当需要修改时有且只有一个理由；
2. **开闭原则**：对象或者实体应该对扩展开发，对修改关闭；
3. **里式替换原则**：q(x)是关于类型为T的x对象可以被证明，q(y)是关于类型为S也可以被证明，其中S是T的子类，换句话说就是任何子类和派生类都可以替换他们的父类和基类；
4. **接口隔离原则**：不应该强迫客户端实现他们不使用的接口，或者不应该强迫客户端依赖他们不使用的方案；
5. **依赖翻转原则**：实体应该依赖抽象，而不是具体实现。也就是说上层模块不应爱依赖于下层模块，但是可以依赖抽象。

### 1.单例设计模式 Singleton

在程序运行时，对于一个类的引用有且只有一个实例，我们称这样的实例成为单例。在实际的开发中有很多这样的例子比如：数据库连接池，线程池，工具类库中的工具类等；

- 饿汉模式：在class被加载到内存就初始化单例实例，JVM保证了所有class只会被加载到内存一次，这样的实现方式大多数情况下适用，同时写法相对简单理解容易；

```java
class HungrySingleton {
  
  private final HungrySingleton hungrySingleton = new HungrySingleton();
  
  private HungrySingleton(){}
  
  public HungrySingleton getInstance(){
    return this.hungrySingleton;
  }
}
```



- 懒汉模式：只有真正用到的时候才去初始化实例，要考虑线程安全问题，如果使用synchronize加锁后使用double check来优化加锁，同时为了避免JIT和CPU的指令重排后导致使用没有被完全初始化好的实例，可以使用volatile关键字来防止指令重排；

```java
class LazySingleton {
  
  private volatile LazySingleton lazySingleton;
  
  private LazySingleton(){}
  
  public LazySingleton getInstance(){
    if(lazySingleton != null){
      synchronized(LazySingleton.class){
        if(lazySingleton != null) {
          lazySingleton = new LazySingleton();
        }
      }
      return lazySingleton;
    }
  }
}
```



- 