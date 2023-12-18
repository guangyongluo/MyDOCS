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
  
  private static HungrySingleton hungrySingleton = new HungrySingleton();
  
  private HungrySingleton(){}
  
  public static HungrySingleton getInstance(){
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

静态内部类实现的懒汉模式单例，由于静态内部类是在使用的时候由JVM来保证单次加载的，同时也是线程安全的。这里需要简单地回顾JVM类的加载过程：

1. 加载二进制到内存中，生成对应的Class数据结构；
2. 连接阶段：a.验证 b.准备(给内的静态成员变量赋初始值) c.解析
3. 初始化：给类的静态成员赋初值

只有在真正使用对应类的时候，才会初始化，当前是启动类所在的类，直接进行new操作，访问静态属性，访问静态方法，使用反射访问类文件，初始化一个类的子类等；

```java
class InnerClassSingleton {

  private InnerClassSingleton(){}
  
  private static class SingletonHolder{
    private static InnerClassSingleton innerClassSingleton = new InnerClassSingleton();
  }
  
  public InnerClassSingleton getInstance(){
    return SingletonHolder.innerClassSingleton;
  }
}
```

如果使用反射来new对象可以攻击单例的实现，如果是饿汉模式或者是静态内部类可以在构造方法中加一个判断来防止单例模式实现产生多个实例，但是如果是懒汉模式就无法防止反射的攻击。

使用enum来实现单例，JVM来保证静态代码块来初始化enum的元素所以是线程安全的，同时enum类型不支持反射，而且如果使用反序列化也不需要进行特殊的处理来保证单例的实施。

```java
public enum EnumSingleton {
  
  INSTANCE;
  
  public void print(){
    System.out.println("INSTANCE = " + this.hashCode());
  }
}
```

### 2. 工厂设计模式 Factory

- 工厂方法模式：定义一个用于创建对象的接口，让子类决定创建哪个类，Factory Method使得一个类的实例化延迟到子类；
- 抽象工厂模式：提供一个创建一系列相关或互相依赖对象的接口，而无需指定它们的具体类；

### 3. 建造者设计模式 Builder

建造者设计模式：将一个复杂对象的创建于它的表示分离，使得同样的构建过程可以创建不同的表示。通常建造者模式主要应用在需要复杂的构造过程的对象创建时，定义一个创建对象的接口，然后定义创建对象的具体实现，由Director指导对象的创建过程。大多数场景中不需要这么复杂的创建过程，一般使用一个建造者设计模式的变种类似于lombok中的builder实现。

```java
public class Product{
  
  private final String param1;
  
  private final Integer param2;
  
  public Product(String param1, Integer param2) {
    this.param1 = param1;
    this.param2 = param2;
  }
  
  public static class ProductBuilder{
    
    private String param1;
    
    private Integer param2;
    
    public ProductBuilder param1(String param1) {
      this.param1 = param1;
      return this;
    }
    
    public ProductBuilder param2(Integer param2) {
      this.param2 = param2;
      return this;
    }
    
    public Product build(){
      return new Product(this.param1, this.param2);
    }
    
  }
  
}
```

### 4. 原型设计模式 Prototype

原型设计模式：指原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。在JDK中使用Object.clone()方法来浅拷贝对象，需要注意的是在使用clone方法时，需要实现Clonable接口，该接口是一个标记接口，旨在JVM运行时指定是否可以运行clone()方法,，而且需要覆盖Object的clone()方法。

### 5. 享元设计模式 Flyweight

享元设计模式：运用共享技术有效地支持大量细粒度的对象。

### 6. 门面模式 Facade

门面设计模式：为子系统中的一组接口提供一致的接口，Facade模式定义了一个高层接口，这个接口使得这一子系统更加容易使用。

### 7. 适配器模式 Adapter

适配器设计模式：将一个类的接口转换成客户希望的另一个接口。Adapter模式使得原本由于接口不兼容而不能在一起工作的那些类可以一起工作。

- 对象适配器模式
- 类适配器模式

### 8. 装饰者模式 Decorator

装饰者设计模式：在不改变原有对象的基础上，将功能附加到对象上。

### 9. 策略模式 Strategy

策略设计模式：定义了算法族，分别封装起来，让它们之间可以相互替换，此模式的变化独立于算法的使用者。

### 10. 模板模式 Template

模板设计模式：定义一个算法的骨架，而将一些步骤延迟到子类中，模板设计模式可以在不改变一个算法结构的情况下，通过继承抽象类的方式来实现其中特定方法。

### 11. 观察者模式 Observer

观察者模式：定义了对象之间的一对多依赖，让多个观察者对象同事监听同一个主题对象，当主题对象发生变化时，它的所有观察者都会收到通知并更新。

### 12. 责任链模式 Chain of Resposibility

责任链模式：为请求创建了一个接受者对象的链