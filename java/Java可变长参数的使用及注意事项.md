### Java可变长参数的使用及注意事项  
***
在Java5 中提供了变长参数（varargs），也就是在方法定义中可以使用个数不确定的参数，对于同一方法可以使用不同个数的参数调用，例如`print("hello");print("hello","lisi");print("hello","张三", "alexia");`下面介绍如何定义可变长参数 以及如何使用可变长参数。

##### 1. 可变长参数的定义
使用...表示可变长参数，例如
```
print(String... args){
   ...
}
```
在具有可变长参数的方法中可以把参数当成数组使用，例如可以循环输出所有的参数值。
```
print(String... args){
   for(String temp:args)
      System.out.println(temp);
}
```

##### 2. 可变长参数的方法的调用 
调用的时候可以给出任意多个参数也可不给参数，例如：  
```
print();

print("hello");

print("hello","lisi");

print("hello","张三", "alexia");
```

##### 3. 可变长参数的使用规则
3.1 在调用方法的时候，如果能够和固定参数的方法匹配，也能够与可变长参数的方法匹配，则选择固定参数的方法。看下面代码的输出：
```
package com;

// 这里使用了静态导入
import static java.lang.System.out;

public class VarArgsTest {

    public void print(String... args) {
        for (int i = 0; i < args.length; i++) {
            out.println(args[i]);
        }
    }

    public void print(String test) {
        out.println("----------");
    }

    public static void main(String[] args) {
        VarArgsTest test = new VarArgsTest();
        test.print("hello");
        test.print("hello", "alexia");
    }
}

--------
hello
alexia
```


3.2 如果要调用的方法可以和两个可变参数匹配，则出现错误，例如下面的代码：
```
package com;

// 这里使用了静态导入
import static java.lang.System.out;

public class VarArgsTest1 {

    public void print(String... args) {
        for (int i = 0; i < args.length; i++) {
            out.println(args[i]);
        }
    }

    public void print(String test,String...args ){
          out.println("----------");
    }

    public static void main(String[] args) {
        VarArgsTest1 test = new VarArgsTest1();
        test.print("hello");
        test.print("hello", "alexia");
    }
}
```
对于上面的代码，main方法中的两个调用都不能编译通过，因为编译器不知道该选哪个方法调用，如下所示：  
![图3-1][java_varargs_01]

3.3 一个方法只能有一个可变长参数，并且这个可变长参数必须是该方法的最后一个参数,以下两种方法定义都是错误的:
```
public void test(String... strings,ArrayList list){
 
}
 
public void test(String... strings,ArrayList... list){
 
}
```

##### 4. 可变长参数的使用规范
4.1 避免带有可变长参数的方法重载：如3.1中，编译器虽然知道怎么调用，但人容易陷入调用的陷阱及误区  
4.2 别让null值和空值威胁到变长方法，如3.2中所示，为了说明null值的调用，重新给出一个例子：
```
package com;public class VarArgsTest1 {

    public void print(String test, Integer... is) {
        
    }

    public void print(String test,String...args ){
          
    }

    public static void main(String[] args) {
        VarArgsTest1 test = new VarArgsTest1();
        test.print("hello");
        test.print("hello", null);
    }
}
```
这时会发现两个调用编译都不通过：  
![图4-1][java_varargs_02]  

因为两个方法都匹配，编译器不知道选哪个，于是报错了，这里同时还有个非常不好的编码习惯，即调用者隐藏了实参类型，这是非常危险的，不仅仅调用者需要“猜测”该调用哪个方法，而且被调用者也可能产生内部逻辑混乱的情况。对于本例来说应该做如下修改：  
```
public static void main(String[] args) {
    VarArgsTest1 test = new VarArgsTest1();
    String[] strs = null;
    test.print("hello", strs);
}
```
4.3 覆写变长方法也要循规蹈矩
下面看一个例子，大家猜测下程序能不能编译通过：
```
package com;

public class VarArgsTest2 {

    /**
     * @param args
     */
    public static void main(String[] args) {
        // TODO Auto-generated method stub
        // 向上转型
        Base base = new Sub();
        base.print("hello");
        
        // 不转型
        Sub sub = new Sub();
        sub.print("hello");
    }

}

// 基类
class Base {
    void print(String... args) {
        System.out.println("Base......test");
    }
}

// 子类，覆写父类方法
class Sub extends Base {
    @Override
    void print(String[] args) {
        System.out.println("Sub......test");
    }
}
```
答案当然是编译不通过，是不是觉得很奇怪？  
![图4-2][java_varargs_03]  

第一个能编译通过，这是为什么呢？事实上，base对象把子类对象sub做了向上转型，形参列表是由父类决定的，当然能通过。而看看子类直接调用的情况，这时编译器看到子类覆写了父类的print方法，因此肯定使用子类重新定义的print方法，尽管参数列表不匹配也不会跑到父类再去匹配下，因为找到了就不再找了，因此有了类型不匹配的错误。

这是个特例，覆写的方法参数列表竟然可以与父类不相同，这违背了覆写的定义，并且会引发莫名其妙的错误。

这里，总结下覆写必须满足的条件：

* 重写方法不能缩小访问权限；
* 参数列表必须与被重写方法相同（包括显示形式）；
* 返回类型必须与被重写方法的相同或是其子类；
* 重写方法不能抛出新的异常，或者超过了父类范围的异常，但是可以抛出更少、更有限的异常，或者不抛出异常。

[java_varargs_01]: ../image/java_varargs_01.png "图3-1"
[java_varargs_02]: ../image/java_varargs_02.png "图4-1"
[java_varargs_03]: ../image/java_varargs_03.png "图4-2"


