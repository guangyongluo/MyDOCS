# JUC学习手册

### 1. Java多线程基本概念复习

##### java多线程相关概念：一把锁，两个并，三个程：

1. 一把锁指的是synchronized关键字；
2. 两个并指的是并发(concurrent)和并行(parallel):
   - 并发（concurrent）：是在同一实体上的多个事件，是在**一台机器**上“**同时**”处理多个任务，同一时刻，其实是**只有一个**事情再发生。
   - 并行（parallel）：是在不同实体上的多个事件，是在**多台处理器**上同时处理多个任务，同一时刻，大家都在做事情，你做你的，我做我的，各干各的。
3. 三个程指的是进程、线程和管程：
   - 进程：在系统中运行的一个应用程序，每个进程都有它自己的内存空间和系统资源
   - 线程：也被称为轻量级进程，在同一个进程内会有一个或多个线程，是大多数操作系统进行时序调度的基本单元。
   - 管程：Monitor（锁），也就是我们平时所说的锁。Monitor其实是一种**同步机制**，它的义务是保证（同一时间）只有一个线程可以访问被保护的数据和代码，JVM中同步是基于进入和退出监视器（Monitor管程对象）来实现的，每个对象实例都会有一个Monitor对象，Monitor对象和Java对象一同创建并销毁，底层由C++语言实现。

##### 重点理解管程的概念：

- 为什么要引入管程：管程（Monitor）是一种操作系统中的同步机制，它的引入是为了解决多线程或多进程环境下的并发控制问题。在传统的操作系统中，当多个进程或线程同时访问共享资源时，可能会导致数据的不一致性、竞态条件和死锁等问题。为了避免这些问题，需要引入一种同步机制来协调并发访问。管程提供了一种高级的同步原语，它将共享资源和对资源的操作封装在一个单元中，并提供了对这个单元的访问控制机制。相比于信号量机制，用管程编写程序更加简单，写代码更加轻松。在JVM中是基于进入和退出监控器对象（monitor, 管程对象）来实现的，每个对象都有一个管程对象。

- 1.管程的定义："管程是一种机制，用于强制并发线程对一组共享变量的互斥访问（或等效操作）。此外，管程还提供了等待线程满足特定条件的机制，并通知其他线程该条件已满足的方法"。这个定义描述了管程的两个主要功能：

  1. 互斥访问：管程确保多个线程对共享变量的访问互斥，即同一时间只有一个线程可以访问共享资源，以避免竞态条件和数据不一致性问题。

  2. 条件等待和通知：管程提供了等待线程满足特定条件的机制，线程可以通过条件变量等待某个条件满足后再继续执行，或者通过条件变量通知其他线程某个条件已经满足。

  > 可以将管程理解为一个房间，这个房间里有一些共享的资源，比如变量、队列等。同时，房间里有一个门，只有一把钥匙。多个线程或进程需要访问房间内的资源时，它们需要先获得这把钥匙，一次只能有一个线程或进程持有钥匙，进入房间并访问资源。其他线程或进程必须等待，直到当前持有钥匙的线程或进程释放钥匙，才能获得钥匙进入房间。
  >
  > 此外，管程还提供了条件变量，类似于房间内的提示牌。线程在进入房间后，如果发现某个条件不满足（比如队列为空），它可以通过条件变量来知道自己需要等待，暂时离开房间，并将钥匙交给下一个等待的线程。当其他线程满足了等待的条件（比如向队列中添加了元素），它可以通过条件变量通知告诉正在等待的线程，使其重新获得钥匙进入房间，并继续执行。

##### 管程由以下几个主要部分组成：

1. 共享变量：管程中包含了共享的变量或数据结构，多个线程或进程需要通过管程来访问和修改这些共享资源。
2. 互斥锁（Mutex）：互斥锁是管程中的一个关键组成部分，用于确保在同一时间只有一个线程或进程可以进入管程。一旦一个线程或进程进入管程，其他线程或进程必须等待，直到当前线程或进程退出管程。
3. 条件变量（Condition Variables）：条件变量用于实现线程或进程之间的等待和通知机制。当一个线程或进程需要等待某个条件满足时（比如某个共享资源的状态），它可以通过条件变量进入等待状态。当其他线程或进程满足了这个条件时，它们可以通过条件变量发送信号来唤醒等待的线程或进程。
4. 管程接口（对管程进行操作的函数）：管程还包括了一组操作共享资源的接口或方法。这些接口定义了对共享资源的操作，并且在内部实现中包含了互斥锁和条件变量的管理逻辑。其他线程或进程通过调用这些接口来访问共享资源，从而确保了对共享资源的有序访问。

##### 管程的基本特征包括：

1. 互斥性（Mutual Exclusion）：管程提供了互斥访问共享资源的机制，同一时间只允许一个线程或进程进入管程并执行操作，以避免数据竞争和冲突。
2. 封装性（Encapsulation）：管程将共享资源和对资源的操作封装在一起，对外部提供了一组抽象的接口或方法，使得其他线程或进程只能通过这些接口来访问和修改共享资源。
3. 条件等待（Condition Wait）：管程提供了条件变量，允许线程或进程在某个条件不满足时等待，并在条件满足时被唤醒继续执行。条件等待能够避免忙等待，提高系统的效率。
4. 条件通知（Condition Signal）：管程允许线程或进程在某个条件发生变化时发出通知，唤醒等待的线程或进程继续执行。条件通知使得线程或进程之间能够有效地进行协作和同步。
5. 可阻塞性（Blocking）：当一个线程或进程尝试进入管程时，如果管程已经被其他线程或进程占用，它将被阻塞，直到管程可用。同样，当一个线程或进程等待某个条件满足时，如果条件不满足，它也会被阻塞，直到条件满足。
6. 公平性（Fairness）：管程通常会提供公平性保证，即线程或进程按照它们等待的顺序获得对管程的访问权限。这样可以避免某些线程或进程一直被其他线程或进程抢占，导致饥饿现象。

这些特征使得管程成为一种强大的并发编程机制，可以简化并发程序的编写和调试过程，并提供了良好的线程或进程间的协作方式。

##### 线程分类（一般不做特别说明配置，默认都是用户线程）：

- 用户线程：是系统的工作线程，它会完成这个程序需要完成的业务操作。
- 守护线程：是一种特殊的线程为其他线程服务的，在后台默默地完成一些系统性的任务，比如垃圾回收线程就是最典型的例子。守护线程作为一个服务线程，没有服务对象就没有必要继续运行了，如果用户线程全部结束了，意味着程序需要完成的业务操作已经结束了，系统可以退出了。所以假如当系统只剩下守护线程的时候，守护线程伴随着JVM一同结束工作。

### 2. CompletableFuture

##### Future接口理论知识复习

Future接口（FutureTask实现类）定义了操作异步任务执行一些方法，如获取异步任务的执行结果、取消异步任务的执行、判断任务是否被取消、判断任务执行是否完毕等。

![juc_future](../image/juc_future.png)

举例：比如主线程让一个子线程去执行任务，子线程可能比较耗时，启动子线程开始执行任务后，主线程就去做其他事情了，忙完其他事情或者先执行完，过了一会再才去获取子任务的执行结果或变更的任务状态（老师上课时间想喝水，他继续讲课不结束上课这个主线程，让学生去小卖部帮老师买水完成这个耗时和费力的任务）。

Future是Java5新加的一个接口，它提供一种异步并行计算的功能，如果主线程需要执行一个很耗时的计算任务，我们会就可以通过Future把这个任务放进异步线程中执行，主线程继续处理其他任务或者先行结束，再通过Future获取计算结果。

##### Future接口相关架构

- 目的：异步多线程任务执行且返回有结果，三个特点：多线程、有返回、异步任务（班长为老师去买水作为新启动的异步多线程任务且买到水有结果返回）
- 代码实现：Runnable接口+Callable接口+Future接口和FutureTask实现类。

![juc_future_structure](../image/juc_future_structure.png)

#####  Future编码实战和优缺点分析

```java
public class FutureApiDemo {
  public static void main(String[] args) throws ExecutionException, InterruptedException, TimeoutException {
    FutureTask<String> futureTask = new FutureTask<>(() -> {
      System.out.println(Thread.currentThread().getName() + "--------come in future task---------");
      try {
        TimeUnit.SECONDS.sleep(5);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return "task over";
    });

    Thread t1 = new Thread(futureTask, "t1");
    t1.start();

//        System.out.println(futureTask.get());//这样会有阻塞的可能，在程序没有计算完毕的情况下。
    System.out.println(Thread.currentThread().getName() + " ------忙其他任务");
//        System.out.println(futureTask.get(3,TimeUnit.SECONDS));//只愿意等待三秒，计算未完成直接抛出异常
    while (true) {//轮询
      if (futureTask.isDone()) {
        System.out.println(futureTask.get());
        break;
      } else {
        TimeUnit.MILLISECONDS.sleep(500);
        System.out.println("正在处理中。。。");
      }
    }
  }
}
```



优点：

- Future+线程池异步多线程任务配合，能显著提高程序的运行效率。

缺点：

- get()阻塞：一旦调用get()方法求结果，非要等到结果才会离开，不管你是否计算完成，如果没有计算完成容易程序堵塞。
- isDone()轮询：轮询的方式会耗费无谓的cpu资源，而且也不见得能及时得到计算结果，如果想要异步获取结果，通常会以轮询的方式去获取结果，尽量不要阻塞。

- 结论：Future对于结果的获取不是很友好，只能通过**阻塞或轮询**的方式得到任务的结果。

##### CompletableFuture为什么会出现

- get()方法在Future计算完成之前会一直处在阻塞状态下，阻塞的方式和异步编程的设计理念相违背；
- isDone()方法容易耗费cpu资源（cpu空转）；
- 对于真正的异步处理我们希望是可以通过传入回调函数，在Future结束时自动调用该回调函数，这样，我们就不用等待结果

jdk8设计出CompletableFuture，CompletableFuture提供了一种观察者模式类似的机制，可以让任务执行完成后通知监听的一方。

##### CompletableFuture和CompletionStage介绍

**类架构说明**：

![completable_future_structure](../image/completable_future_structure.png)

- **接口CompletionStage**：
  - 代表异步计算过程中的某一个阶段，一个阶段完成以后可能会触发另外一个阶段。
  - 一个阶段的执行可能是被单个阶段的完成触发，也可能是由多个阶段一起触发

- **类CompletableFuture**
  - 提供了非常强大的Future的扩展功能，可以帮助我们简化异步编程的复杂性，并且提供了函数式编程的能力，可以通过回调的方式处理计算结果，也提供了转换和组合CompletableFuture的方法
  - 它可能代表一个明确完成的Future，也可能代表一个完成阶段（CompletionStage），它支持在计算完成以后触发一些函数或执行某些动作

##### 使用CompletableFuture的核心的四个静态方法，来创建一个异步任务

![completable_future_core_method](../image/completable_future_core_method.png)

对于上述Executor参数说明：若没有指定，则使用默认的ForkJoinPoolcommonPool（）作为它的线程池执行异步代码，如果指定线程池，则使用我们自定义的或者特别指定的线程池执行异步代码:

```java
package com.vilin.future;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CompletableFutureBuildDemo {
  public static void main(String[] args) throws ExecutionException, InterruptedException {
    ExecutorService executorService = Executors.newFixedThreadPool(3);

    CompletableFuture<Void> completableFuture = CompletableFuture.runAsync(() -> {
      log.debug(Thread.currentThread().getName());
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    },executorService);

    log.debug("completableFuture.get() = {}", completableFuture.get()); //null


    CompletableFuture<String> objectCompletableFuture = CompletableFuture.supplyAsync(()->{
      log.debug(Thread.currentThread().getName());
      try {
        TimeUnit.SECONDS.sleep(1);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
      return "hello supplyAsync";
    },executorService);

    log.debug("completableFuture.get() = {}", objectCompletableFuture.get());//hello supplyAsync

    executorService.shutdown();

  }
}

```

CompletableFuture减少阻塞和轮询，可以传入回调对象，当异步任务完成或者发生异常时，自动调用回调对象的回调方法。

```java
public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(3);
        CompletableFuture<Integer> completableFuture = CompletableFuture.supplyAsync(() -> {
            System.out.println(Thread.currentThread().getName() + "---come in");
            int result = ThreadLocalRandom.current().nextInt(10);
            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if (result > 5) { //模拟产生异常情况
                int i = 10 / 0;
            }
            System.out.println("----------1秒钟后出结果" + result);
            return result;
        }, executorService).whenComplete((v, e) -> {
            if (e == null) {
                System.out.println("计算完成 更新系统" + v);
            }
        }).exceptionally(e -> {
            e.printStackTrace();
            System.out.println("异常情况：" + e.getCause() + " " + e.getMessage());
            return null;
        });
        System.out.println(Thread.currentThread().getName() + "先去完成其他任务");
        executorService.shutdown();
    }
```

CompletableFuture优点：

- 异步任务**结束**时，会自动回调某个对象的方法
- 主线程设置好回调后，不用关心异步任务的执行，异步任务之间可以顺序执行
- 异步任务**出错**时，会自动回调某个对象的方法

##### CompletableFuture常用方法

- **获得结果和触发计算**

  - 获取结果

    - public T get()

    - public T get(long timeout,TimeUnit unit)

    - public T join()：和get一样的作用，只是不需要抛出异常

    - public T getNow(T valuelfAbsent) ：计算完成就返回正常值，否则返回传入的参数，立即获取结果不阻塞

  - 主动触发计算
    - public boolean complete(T value)：是否打断get方法立即返回传入的参数

- **对计算结果进行处理**

  - thenApply ：计算结果存在依赖关系，这两个线程串行化，由于存在依赖关系（当前步错，不走下一步），当前步骤有异常的话就叫停，有点像try/catch

  - handle ：计算结果存在依赖关系，这两个线程串行化，有异常也可以往下走一步,

- **对计算结果进行消费**

  - thenAccept：接受任务的处理结果，并消费处理，无返回结果

  - 对比补充

    - thenRun(Runnable runnable) :任务A执行完执行B，并且不需要A的结果

    - thenAccept(Consumer action): 任务A执行完执行B，B需要A的结果，但是任务B没有返回值

    - thenApply(Function fn): 任务A执行完执行B，B需要A的结果，同时任务B有返回值

  - CompletableFuture和线程池说明

    - 如果没有传入自定义线程池，都用默认线程池ForkJoinPool

    - 传入一个线程池，如果你执行第一个任务时，传入了一个自定义线程池

    - 调用thenRun方法执行第二个任务时，则第二个任务和第一个任务时共用同一个线程池

    - 调用thenRunAsync执行第二个任务时，则第一个任务使用的是你自定义的线程池，第二个任务使用的是ForkJoin线程池

  - 备注：可能是线程处理太快，系统优化切换原则， 直接使用main线程处理，thenAccept和thenAcceptAsync，thenApply和thenApplyAsync等，之间的区别同理。

- **对计算速度进行选用**
  - applyToEither：谁快用谁

- **对计算结果进行合并**

  - 两个CompletableStage任务都完成后，最终能把两个任务的结果一起交给thenCombine来处理

  - 先完成的先等着，等待其他分支任务