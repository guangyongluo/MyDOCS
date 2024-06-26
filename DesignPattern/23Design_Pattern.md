# 重温23种设计模式

代码码的太久，一直写，没有过多的考虑代码的编码风格，这样的代码自己看起来都费劲，今天23-11-17开始重温SOLID设计原则和23种设计模式，在以后的编码中要多做设计方面的思考，不能盲目的一通写，合理的结合业务来产出优雅的代码。

软件设计模式(software design pattern)：又称设计模式，是一套反复使用，多数人知晓的，经过分目编类的，代码设计经验的总结。它描述了在软件设计过程中一些不断重复发生的问题，以及解决这些问题的方案。也就是说，设计模式(Design Pattern)是前辈们对代码开发经验的总结，是解决特定问题的一系列套路。它不是语法规定，而是一套用来提高代码可复用性、可维护性、可读性、稳健性以及安全性的解决方案。

1995 年，GoF(Gang of Four，四人组/四人帮)合作出版了《设计模式：可复用面向对象软件的基础》一书，共收录了23种设计模式，从此树立了软件设计模式领域的里程碑，人称「GoF设计模式」。这23种设计模式的本质是面向对象设计原则的实际运用，是对类的封装性、继承性和多态性，以及类的关联关系和组合关系的充分理解。

当然，软件设计模式只是一个引导，在实际的软件开发中，必须根据具体的需求来选择：

- 对于简单的程序，可能写一个简单的算法要比引入某种设计模式更加容易；
- 但是对于大型项目开发或者框架设计，用设计模式来组织代码显然更好。

### 类之间的关系

1. 依赖（Dependency）关系是一种使用关系，它是对象之间耦合度最弱的一种关联方式，是临时性的关联。在代码中，某个类的方法通过局部变量、方法的参数或者对静态方法的调用来访问另一个类（被依赖类）中的某些方法来完成一些职责。比如一个人使用手机来发送信息，人对手机的依赖是临时的。
2. 关联（Association）关系是对象之间的一种引用关系，用于表示一类对象与另一类对象之间的联系，如老师和学生、师傅和徒弟、丈夫和妻子等。关联关系是类与类之间最常用的一种关系，分为一般关联关系、聚合关系和组合关系。我们先介绍一般关联。在代码中通常将一个类的对象作为另一个类的成员变量来实现关联关系。比如老师和学生之间的关联关系就是属于一般关联关系。
3. 聚合（Aggregation）关系是关联关系的一种，是强关联关系，是整体和部分之间的关系，是 has-a 的关系。聚合关系也是通过成员对象来实现的，其中成员对象是整体对象的一部分，但是成员对象可以脱离整体对象而独立存在。例如，学校与老师的关系，学校包含老师，但如果学校停办了，老师依然存在。
4. 组合（Composition）关系也是关联关系的一种，也表示类之间的整体与部分的关系，但它是一种更强烈的聚合关系，是 cxmtains-a 关系。在组合关系中，整体对象可以控制部分对象的生命周期，一旦整体对象不存在，部分对象也将不存在，部分对象不能脱离整体对象而存在。例如，头和嘴的关系，没有了头，嘴也就不存在了。
5. 泛化（Generalization）关系是对象之间耦合度最大的一种关系，表示一般与特殊的关系，是父类与子类之间的关系，是一种继承关系，是 is-a 的关系。
6. 实现（Realization）关系是接口与实现类之间的关系。在这种关系中，类实现了接口，类中的操作实现了接口中所声明的所有的抽象操作。

### SOLID原则：

SOLID是五个面向对象的设置原则的首字母，这些设计原则建立了最佳实践，这些实践可以帮助开发者在项目不断推进过程中考虑到了代码的可维护性和可扩展性。在开发项目时采用这个设计原则可以有效的避免代码过于复杂而导致代码重构，阅读困难，同时使代码修改更加敏捷和方便。

1. **责任单一原则**：一个类应该只承担一个任务，当需要修改时有且只有一个理由；一个类或者模块只负责完成一个职责,不要设计大而全的类，要设计的粒度小、功能单一的类，也就是说如果一个类包含两个或者两个以上业务不相关的功能，就可以说它的职责不够单一，可以考虑拆分类，单一职责原则是最简单但又最难运用的原则，需要设计人员发现类的不同职责并将其分离，再封装到不同的类或模块中，而发现类的多重职责需要设计人员具有较强的分析设计能力和相关重构经验。**对于责任单一原则的评判标准**：

   - 类中的代码行数、函数或属性过多，影响代码的可读性和维护性，就需要考虑对类进行拆分；

   - 类依赖其它类过多，或者依赖的类的其它类过多，不符合高内聚、低耦合的设计思想，就需要考虑对类就行拆分；

   - 私有方法过多,考虑能否将私有方法到新的类中，设置为public方法，供更多的类使用，提高代码的复用性；

   - 比较难给定一个适合的名字，很难用一个业务名词概括，说明职责定义的不够清晰；

   - 类中大量的方法都是集中在操作类的几个属性，其它的属性就可以拆分出来。

2. **开闭原则**：对象或者实体应该对扩展开发，对修改关闭，使用面向对象语言继承和多态特性来对类实现扩展，尽量减少对类的修改，我们不能做到完全地对扩展开放、对修改关闭，我们只可能在最上面抽象尽可能不改动原逻辑的前提下做扩展。可以通过”抽象约束、封装变化“来实现开闭原则，即通过接口或者抽象类为软件实体定义一个相对稳定的抽象层，而将相同的可变因素封装在相同的具体实现类中。因为抽象灵活性好，适应性广，只要抽象的合理，可以基本保持软件架构的稳定。而软件中易变的细节可以从抽象派生来的实现类来进行扩展，当软件需要发生变化时，只需要根据需求重新派生一个实现类来扩展就可以了。**对于开闭原则的评判标准**：

   - 一段代码是否易于扩展，应该需要考虑这段代码在应对未来需求变化的时候，能够做到“对外开放，对修改关闭”，那就说明这段代码的扩展性比较好。

   - 添加一个新功能，不可能任何模块、类、方法不做修改。类需要创建、组装、并且做一些初始化操作，才能构建可运行的程序，修改这部分代码是再所难免的。我们要做的尽量修改的操作更集中、更少、更上层、尽量让最核心、最复杂的那部分逻辑代码满足开闭原则。

3. **里式替换原则**：里氏替换原则通俗来讲就是：子类可以扩展父类的功能，但不能改变父类原有的功能。也就是说：子类继承父类时，除添加新的方法完成新增功能外，尽量不要重写父类的方法。通过重写父类的方法来完成新的功能写起来虽然简单，但是整个继承体系的可复用性会比较差，特别是运用多态比较频繁时，程序运行出错的概率会非常大。如果程序违背了里氏替换原则，则继承类的对象在基类出现的地方会出现运行错误。这时其修正方法是：取消原来的继承关系，重新设计它们之间的关系。**对于里式替换原则的评判标准**：

   - 子类违背父类声明要实现的功能，比如说我父类从小到大排序，子类重新这个方法后是从大到小的顺序排序；

   - 子类违背父类对输入、输出、异常约定，入参和出参类型一样，抛的异常类型也必须完全一样；

   - 子类违背父类注释中所罗列的任何特殊说明，实现方法跟父类注释方式说明不符。

4. **接口隔离原则**：不应该强迫客户端实现他们不使用的接口，或者不应该强迫客户端依赖他们不使用的方案。以上两个定义的含义是：要为各个类建立它们需要的专用接口，而不要试图去建立一个很庞大的接口供所有依赖它的类去调用。**对于接口隔离原则的评判标准**：

   - 接口尽量小，但是要有限度。一个接口只服务于一个子模块或业务逻辑。
   - 为依赖接口的类定制服务。只提供调用者需要的方法，屏蔽不需要的方法。
   - 了解环境，拒绝盲从。每个项目或产品都有选定的环境因素，环境不同，接口拆分的标准就不同深入了解业务逻辑。
   - 提高内聚，减少对外交互。使接口用最少的方法去完成最多的事情。

5. **依赖翻转原则**：实体应该依赖抽象，而不是具体实现。同时上层模块不应爱依赖于下层模块，但是可以依赖中间的抽象。**其核心思想是：要面向接口编程，不要面向实现编程**。由于在软件设计中，细节具有多变性，而抽象层则相对稳定，因此以抽象为基础搭建起来的架构要比以细节为基础搭建起来的架构要稳定得多。这里的抽象指的是接口或者抽象类，而细节是指具体的实现类。使用接口或者抽象类的目的是制定好规范和契约，而不去涉及任何具体的操作，把展现细节的任务交给它们的实现类去完成。**对于依赖翻转原则评判标准**：

   - 每个类尽量提供接口或抽象类，或者两者都具备。
   - 变量的声明类型尽量是接口或者是抽象类。
   - 任何类都不应该从具体类派生。

   - 高层次模块没有依赖低层次模块的具体实现仅仅依赖了抽象层，方便低层次模块的替换。

6. **迪米特法则**：如果两个软件实体无须直接通信，那么就不应当发生直接的相互调用，可以通过第三方转发该调用。其目的是降低类之间的耦合度，提高模块的相对独立性。那么什么实体可以直接通信呢？当前对象本身、当前对象的成员对象、当前对象所创建的对象、当前对象的方法参数等，这些对象同当前对象存在关联、聚合或组合关系，可以直接访问这些对象的方法。但是，过度使用迪米特法则会使系统产生大量的中介类，从而增加系统的复杂性，使模块之间的通信效率降低。所以，在釆用迪米特法则时需要反复权衡，确保高内聚和低耦合的同时，保证系统的结构清晰。**对于迪米特法则的评价标准**：

   - 在类的划分上，应该创建弱耦合的类。类与类之间的耦合越弱，就越有利于实现可复用的目标。

   - 在类的结构设计上，尽量降低类成员的访问权限。

   - 在类的设计上，优先考虑将一个类设置成不变类。

   - 在对其他类的引用上，将引用其他对象的次数降到最低。

   - 不暴露类的属性成员，而应该提供相应的访问器（set 和 get 方法）。

   - 谨慎使用序列化（Serializable）功能。

7. **合成复用原则**：它要求在软件复用时，要尽量先使用组合或者聚合等关联关系来实现，其次才考虑使用继承关系来实现。通常类的复用分为继承复用和合成复用两种，继承复用虽然有简单和易实现的优点，但它也存在以下缺点。

   - 继承复用破坏了类的封装性。因为继承会将父类的实现细节暴露给子类，父类对子类是透明的，所以这种复用又称为“白箱”复用。

   - 子类与父类的耦合度高。父类的实现的任何改变都会导致子类的实现发生变化，这不利于类的扩展与维护。

   - 它限制了复用的灵活性。从父类继承而来的实现是静态的，在编译时已经定义，所以在运行时不可能发生变化。

   采用组合或聚合复用时，可以将已有对象纳入新对象中，使之成为新对象的一部分，新对象可以调用已有对象的功能，它有以下优点。

   - 它维持了类的封装性。因为成分对象的内部细节是新对象看不见的，所以这种复用又称为“黑箱”复用。

   - 新旧类之间的耦合度低。这种复用所需的依赖较少，新对象存取成员对象的唯一方法是通过成员对象的接口。

   - 复用的灵活性高。这种复用可以在运行时动态进行，新对象可以动态地引用与成员对象类型相同的对象。

### 设计模式的分类

1. **创建型模式（Creational）**：关注对象的实例化过程，包括了如何实例化对象、隐藏对象的创建细节等。常见的创建型模式有单例模式、工厂模式、抽象工厂模式等。
2. **结构型模式（Structural）**：关注对象之间的组合方式，以达到构建更大结构的目标。这些模式帮助你定义对象之间的关系，从而实现更大的结构。常见的结构型模式有适配器模式、装饰器模式、代理模式等。
3. **行为型模式（Behavioral）**：关注对象之间的通信方式，以及如何合作共同完成任务。这些模式涉及到对象之间的交互、责任分配等。常见的行为型模式有观察者模式、策略模式、命令模式等。



### 1.单例设计模式 Singleton

在程序运行时，对于一个类的引用有且只有一个实例，我们称这样的实例成为单例。在实际的开发中有很多这样的例子比如：数据库连接池，线程池，工具类库中的工具类等；单例模式是设计模式中最简单的模式之一。通常，普通类的构造函数是公有的，外部类可以通过“new 构造函数()”来生成多个实例。但是，如果将类的构造函数设为私有的，外部类就无法调用该构造函数，也就无法生成多个实例。这时该类自身必须定义一个静态私有实例，并向外提供一个静态的公有函数用于创建或获取该静态私有实例。

- 饿汉模式：在class被加载到内存的同时初始化单例实例，JVM保证了所有class只会被加载到内存一次，这样的实现方式大多数情况下适用，而且写法相对简单容易理解，这里需要简单地回顾JVM类的加载过程：

  1. 加载二进制到内存中，生成对应的Class数据结构；
  2. 连接阶段：a.验证(验证加载的class二进制是否符合JVM规范) b.准备(给内的静态成员变量赋初始值，这里的静态成员变量如果是Java的8大基本数据类型，将会赋一个默认值比如int类型会赋值0，如果是引用类型将会赋null)  c.解析(将常量池中的符号引用转换为直接引用)；
  3. 初始化：给类的静态成员赋初值，这里的静态成员是指引用类型对象。

  只有在真正使用对应类的时候，才会初始化，比如：启动类即main函数所在的类，直接进行new操作，访问静态属性，访问静态方法，使用反射访问类文件，初始化一个类的子类时发现没有该类对应的class信息，JVM就会加载这个类。

```java
class HungrySingleton {
  
  private static HungrySingleton hungrySingleton = new HungrySingleton();
  
  private HungrySingleton(){
    if(SingletonHolder.innerClassSingleton != null){
      throw RuntimeException("单例不允许使用反射来创建实例");
    }
  }
  
  public static HungrySingleton getInstance(){
    return this.hungrySingleton;
  }
}
```



- 懒汉模式：只有真正用到的时候才去初始化实例，对于单线程来说非常好实现，但是要考虑线程安全问题，如果使用synchronize给getInstance()方法加锁在高并发下会出现很多无效的加锁，经过前人的总结经验后使用double check来优化加锁，同时为了避免JIT(Java Just in Time即时编译)和CPU或者编译器为了更高的性能进行指令重排后导致使用没有被完全初始化好的实例，可以使用volatile关键字来防止指令重排；

```java
class LazySingleton {
  
  private volatile LazySingleton lazySingleton;
  
  private LazySingleton(){}
  
  public LazySingleton getInstance(){
    if(lazySingleton != null){
      synchronized(LazySingleton.class){
        if(lazySingleton != null) {
          // 查看反编译Java class文件可以看出简单的new做了以下三件事：
          // 1. 使用常量池中的LazySingleton class在JVM heap空间上创建一个实例对象
          // 2. 初始化这个新的对象
          // 3. 将初始化好的对象赋值给私有成员变量
          // 由于这些步骤不具有原子性，那么JIT、CPU或者编译器都有可能对这些指令进行重排，而获得更高的执行效率，           
          // 如果第三步在第二步之前执行很可能造成空指针异常。所以我们需要使用volatile来防止指令重排许。
          lazySingleton = new LazySingleton();
        }
      }
      return lazySingleton;
    }
  }
}
```

- 静态内部类实现的饿汉模式单例，由于静态内部类是在使用的时候由JVM来保证单次加载的，同时也是线程安全的。只有当我们调用InnerClassSingleton.getInstance()时JVM才会加载InnerClassSingleton的Class文件，该方法中返回了SingletonHodler.innerClassSingleton，JVM又会加载SingletonHolder这个Class文件。同时JVM保证了Class只被加载一次。这种方式加载不需要考虑线程安全问题，本质上也是利用了类加载机制来保证线程安全，跟恶汉式的实现原理类似。


```java
class InnerClassSingleton {

  private InnerClassSingleton(){
    if(SingletonHolder.innerClassSingleton != null){
      throw new RuntimeException("单例不允许使用反射来创建实例");
    }
  }
  
  private static class SingletonHolder{
    private static InnerClassSingleton innerClassSingleton = new InnerClassSingleton();
  }
  
  public InnerClassSingleton getInstance(){
    return SingletonHolder.innerClassSingleton;
  }
}
```

如果使用反射可以得到私有构造函数后使用newInstance来new对象，这样就可以生成多个该类的实例对象，这就造成了单例类可以生成多个实例。如果是饿汉模式或者是静态内部类可以在构造方法中加一个判断来防止使用反射操作单例模式的构造方法产生多个实例，但是如果是懒汉模式，由于懒汉模式的成员变量没有用静态来修饰，其实加不加这个判断成员变量永远是null，就无法防止反射的攻击。

使用enum来实现单例，通过查看enum的反编译文件可以知道enum使用静态代码块来初始化所有的成员，同时JVM类加载保证静态代码块只执行一次和线程安全，最后enum类型不支持反射来通过newInstance类new该类的实例对象。需要注意的是Java还有一个序列化和反序列化的功能，主要的应用场景是当我们的实例需要网络传输或者持久化时，可以使用Java的序列化将实例转换成一个二进制序列的表示，然后通过网络传输到目标地址或者直接存储在磁盘上，需要使用该实例时只需反序列化就可以得到实例对象了。所有需要序列化的类都需要实现Serializable接口，这个接口其实是个标记接口没有任何抽象方法。所以通过序列化和反序列化可以破坏单例模式，这里首先要提的是serialVersionUID，我们在代码中经常看到这个成员变量，它到底是做什么的？为了保证序列化和反序列化的版本兼容性，在实现了Serializable接口的类都需要设置一个serialVersionUID版本号，如果你不指定的话Java会根据类的成员变量和成员方法的数据来生成一个serialVersionUID版本号保持在序列化的二机制里，在反序列化的时候也会根据生成的成员变量和成员方法生成一个serialVersionUID再跟之前序列化保存的版本号对比，如果不一样就说明被更改过滤JVM就会抛异常。在Serializable接口说明中提到，可以使用readResovle()方法来直接返回反序列化的对象，这样对于单例来讲又可以做一个增强即所有实现了Serializable接口的类中，都添加一个readResovle()来返回单例即可。

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

建造者设计模式：将一个复杂对象的创建与它的表示分离，使得同样的构建过程可以创建不同的表示。通常建造者模式主要应用在需要复杂构造过程的对象创建时，由于创建对象需要很多步骤，而且步骤的顺序又不相同，这样的场景非常适合使用构造者模式来创建对象。大多数场景中不需要这么复杂的创建过程，一般使用一个建造者设计模式的变种类似于lombok中的builder实现。

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

建造者模式的有点：

1. 封装性好，创建和使用分离；
2. 扩展性好，构造类之间独立、一定程度上解耦。

缺点也很明显：

1. 使用Builder来创建对象，增加了创建对象的成本；
2. 如果类发生改变，那么建造者也得跟着改变来创建所需的对象。

建造者模式与工厂模式的区别：

1. 建造者模式更加注重方法的调用顺序，工厂模式注重于创建对象；
2. 创建对象的粒度不同，建造者创建复杂的对象，由各种复杂的部件组成，工厂模式创建出来的都一样；

### 4. 原型设计模式 Prototype

原型设计模式：指原型实例指定创建对象的种类，并且通过拷贝这些原型创建新的对象。在JDK中使用Object.clone()方法来浅拷贝对象，需要注意的是在使用clone方法时，需要实现Clonable接口，该接口是一个标记接口，旨在JVM运行时指定是否可以运行clone()方法。

原型设计模式的适用场景：

1. 类初始化消耗资源较多；
2. new产生一个对象需要非常繁琐的过程；
3. 构造函数比较复杂；

使用Object.clone()方法来克隆对象比直接使用new来创建对象的效率要高，我们查看Object.clone的源码会发现，clone是一个native的方法，JDK底层使用基于二进制流来实现对象的克隆，对比new一个新的对象效率更高。

```java
protected native Object clone() throws CloneNotSupportedException;
```

但是使用Object.clone的最大的问题就是对于有引用类型的属性对象的克隆是浅克隆，浅克隆是指对于引用属性不会创建新的对象，还是直接拷贝的原来的引用所以在更新引用类型属性时，将更新所有克隆出来的对象。如果要使用深克隆需要自己实现一个deepClone方法，注意：不要重写clone方法，这样会违背里式替换原则。一种简单的深克隆方式可以使用Java的对象序列化来实现：

```java
public ConcretePrototype deepClone(){
    try(ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ObjectOutputStream oos = new ObjectOutputStream(bos)){
        oos.writeObject(this);

        ByteArrayInputStream ios = new ByteArrayInputStream(bos.toByteArray());
        ObjectInputStream ois = new ObjectInputStream(ios);
        ConcretePrototype o = (ConcretePrototype)ois.readObject();
        return o;
    } catch (IOException e) {
        throw new RuntimeException(e);
    } catch (ClassNotFoundException e) {
        throw new RuntimeException(e);
    }
}
```

原型模式的缺点是：

1. 要使用原型模式必须实现clonable接口，该接口并没有需要实现的抽象方法，只是一个标记接口当对象需要使用克隆方法时，JDK会检查是否实现该接口，否则会抛异常；
2. 如果需要实现深克隆必须考虑类中引用属性的修改，这违背了开闭原则；

### 5. 代理设计模式 Proxy

代理模式是为对象提供一个代理，以控制对这个对象的访问，代理对象在客户端和目标对象之间起到中介的作用。

适用场景：保护目标对象，增强目标功能。

代理模式分成静态代理和动态代理：静态代理显示地声明被代理对象。静态代理最大的问题在于，如果有很多实现了代理接口的对象，那么需要为每个对象实现一个代理对象，这样会导致类膨胀。所以需要使用动态代理，动态代理的实现分为JDK的实现和cglib的实现两种：

1. JDK的反射实现动态代理：

   ```java
   public interface Isubject {
       void doSomething();
   } 
   
   pubic class Person implements Isubject {
       public void doSomething(){
           System.out.println("person do something.");
       }
   }
   
   public class People implements Isubject {
       public void doSomething(){
           System.out.println("people do something.");
       }
   }
   
   public class DynamicProxy implements {
       private Isubject target;
   
       public DynamicProxy(Isubject target) {
           this.target = target;
       }
   
       public Object invoke(Object proxy, Method method, Object[] args) throws Throwable{
           System.out.println("before");
           Object result = method.invoke(target, args);
           System.out.println("after");
           return result;
       }
   }
   
   public class Test{
       
   }
   ```

   

2. cglib来实现动态代理：

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