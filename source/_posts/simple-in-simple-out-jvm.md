---
title: 浅入浅出JVM
date: 2022-07-31
author: 寒雨
hide: false
summary: 红岩讲课的课件
categories: 笔记
tags:
  - JVM
  - 字节码
  - ASM
---

# 浅入浅出JVM & Hook

> 其中混杂有相当多的个人理解，如有谬误烦请学长指正

## 什么是JVM

**Java Virtual Machine**，即Java虚拟机。那么虚拟机又是什么？

> 虚拟机（Virtual Machine）指通过软件模拟的具有完整硬件系统功能的、运行在一个完全隔离环境中的完整计算机系统。

但不同于其他虚拟机的是，JVM模拟的是一个无法直接在硬件设备上安装的计算机系统——究其根本，它就是一个在各个系统中具有基本相同行为的**跨平台程序**，它提供了一系列可供Java语言调用的API，而这些API都可以溯源到**本地方法**(也就是native修饰的方法)。这些方法在native语言层面实现，且在不同的系统上有着不同逻辑的实现。但抽象到java语言层面，它们的作用是一致的。

就这样，JVM为我们在各个系统提供了一个具有统一“系统“的虚拟机环境，我们不需要让外部的实际系统认识我们的编译出来的软件，我们只需要让JVM认识它就可以了。每当我们使用`java -jar`命令运行一个jar文件, 实际上都先运行了JVM，再由JVM来**运行时**的解释并加载jar包中的类文件，并通过META-INF中的主类信息找到主类并执行其中的main方法。

因此，我们使用Java等依赖于JVM的语言编写程序时如果只调用Java语言为我们提供的API，我们编写的代码就可以在一切支持JVM的系统上运行。正所谓 ***Write once, run anywhere***。你会发现很多直接编译为native的语言(C, C++, Rust, Go...)甚至需要在对应的系统编译才能运行，这也正是JVM系语言相对于其他语言的优势之一。

## JVM的种类

这里介绍主要的几种

### Sun Classic VM

> 万物伊始

其中使用的技术在今天看来已经相当原始，这款虚拟机的使命也早已终结，但凭它”世界上第一款商用Java虚拟机“的头衔，便足以让它被历史铭记。

### HotSpot VM

> 武林盟主

毫无疑问是当今被最广泛使用的Java虚拟机

### Graal VM

> 明日之星

创造性的将字节码编译为另一种中间媒介，同时支持将其他语言编译为这种中间媒介，实现多语言之间的相互调用，JVM将不再专属于字节码。举个例子，我们甚至可以在Java中使用Node.js的Express框架来开发后端程序。

### Dalvik VM

> 为Android而生

> Dalvik是[Google](https://baike.baidu.com/item/Google/86964)公司自己设计用于Android平台的[虚拟机](https://baike.baidu.com/item/虚拟机/104440)。Dalvik虚拟机是Google等厂商合作开发的Android移动设备平台的核心组成部分之一。它可以支持已转换为 .dex（即Dalvik Executable）格式的Java应用程序的运行，.dex格式是专为Dalvik设计的一种[压缩格式](https://baike.baidu.com/item/压缩格式/2844535)，适合内存和处理器速度有限的系统。Dalvik 经过优化，允许在有限的内存中同时运行多个虚拟机的实例，并且每一个Dalvik 应用作为一个独立的Linux 进程执行。独立的进程可以防止在虚拟机崩溃的时候所有程序都被关闭。
>
> 很长时间以来，Dalvik虚拟机一直被用户指责为拖慢安卓系统运行速度不如IOS的根源。
>
> 2014年6月25日，Android L 正式亮相于召开的谷歌I/O大会，Android L 改动幅度较大，[谷歌](https://baike.baidu.com/item/谷歌/117920)将直接删除Dalvik，代替它的是传闻已久的ART。

### ART

> ART(Android Runtime)是Android 4.4发布的，用来替换Dalvik虚拟，Android 4.4之前默认采用的还是DVM，系统会提供一个选项来开启ART模式。在Android 5.0时，默认采用ART，DVM从此退出历史舞台。

**Dalvik虚拟机执行的是dex字节码，ART虚拟机执行的是本地机器码。**

> Dalvik执行的是dex字节码，依靠JIT编译器去解释执行，运行时动态地将执行频率很高的dex字节码翻译成本地机器码，然后在执行，但是将dex字节码翻译成本地机器码是发生在应用程序的运行过程中，并且应用程序每一次重新运行的时候，都要重新做这个翻译工作，因此，即使采用了JIT，Dalvik虚拟机的总体性能还是不能与直接执行本地机器码的ART虚拟机相比。 安卓运行时从Dalvik虚拟机替换成ART虚拟机，并不要求开发者重新将自己的应用直接编译成目标机器码，也就是说，应用程序仍然是一个包含dex字节码的apk文件。所以在安装应用的时候，dex中的字节码将被编译成本地机器码，之后每次打开应用，执行的都是本地机器码。移除了运行时的解释执行，效率更高，启动更快。（安卓在4.4中发布了ART运行时）

ART优点:

- 系统性能显著提升
- 应用启动更快、运行更快、体验更流畅、触感反馈更及时
- 续航能力提升
- 支持更低的硬件

ART缺点:

- 更大的存储空间占用，可能增加10%-20%
- 更长的应用安装时间

> 应廖老师的要求，讲讲ART的GC

// TODO 内容好多，我太难了

## 自行编译JDK8

非常麻烦，看看有没有时间去做。自行编译jvm可以对jvm打断点，还是很有帮助的。

// TODO

## 内存管理

对于从事C，C++程序开发的开发人员，在内存管理领域，他们需要手动分配/释放内存。虽然这是一件繁琐的工作，但这也使C++等一系列需要手动管理内存的语言能做到更多的事情。例如MMKV，它的底层原理使用C++实现——手动管理了一块堆外内存。(但其实Java也并非做不到这个，Unsafe类中提供了手动分配/释放堆外内存的方法，并且提供了跟C++一样的面向指针的操作方法。)

得益于JVM强大的内存管理机制，JVM语言程序员不需要手动为每个对象分配/释放堆内存，一切看起来相当美好。但正是因为我们将内存管理的程序交给了JVM，一旦出现内存泄漏的问题，如果不清楚JVM内存管理机制的原理就很难解决问题。

### 运行时数据区

Java虚拟机在执行Java程序的过程中会把它管理的内存划分为若干个不同的数据区域:

![Java虚拟机运行时数据区](http://images2015.cnblogs.com/blog/1182497/201706/1182497-20170616192739978-1176032049.png)

#### 程序计数器

程序计数器占用了比较小的一块内存空间，可以看作是**当前线程**所执行字节码的行号(字节码的行号，不是代码的行号，字节码应该包含有对应代码行数的信息)指示器。字节码解释器在工作时就是通过改变这个计数器的值来选取下一条需要执行的字节码指令, 它是**程序控制流**的指示器，流程控制，异常处理，线程恢复都需要依赖它来实现。

Java虚拟机的多线程是通过**线程轮流切换，分配处理器时间**实现的，因此在任何一个确定的时刻，一个内核都只会执行一条线程中的指令（即并发执行)。因此，为了线程切换后能恢复到正确的执行位置，每条线程都需要有一个程序计数器。因此程序计数器是**线程私有**的。

**---这里稍微讲讲Java的线程调度 & 协程---**

这里引用一段别人的话，上面我可能表述得不是很准确

> 因为Java的多线程也是依靠时间片轮转算法进行的，因此一个CPU同一时间也只会处理一个线程，当某个线程的时间片消耗完成后，会自动切换到下一个线程继续执行，而当前线程的执行位置会被保存到当前线程的程序计数器中，当下次轮转到此线程时，又继续根据之前的执行位置继续向下执行。

> **单核**的CPU是一种假的多线程，因为在一个时间单元内，也只能执行一个线程的任务。同时间段内有多个线程需要CPU去运行时，CPU也只能交替去执行多个线程中的一个线程，但是由于其执行速度特别快，因此感觉不出来。

按照上面的说法，我们发现，其实线程可以看作一个任务，**内核一直在很多线程之间反复横跳**: 这个做一会儿就停下来，去做下一个。

但这里就会出现一个问题，使用`Thread.sleep(long)`停下的线程，内核会怎么办？答案是仍然会到他身上去，但什么也不做，就白白浪费了给cpu分配的时间分片。这就是这种设计的局限性，且不说创建一个新的线程相当占内存，即便是内存足够，并发效率也相当差（其实跟Java当时刚出的时候的其他语言比起来已经很不错了）。线程池当然也会有这个问题。

那么理想的状态是什么呢？我让这个线程休眠了，你cpu就不要管他，把时间分给其他有任务的线程。

两条路，要么你从内核层面去改良，去教cpu做事。对应了`Thread#yield()`,让当前线程把自己的时间让给其他线程，实现**抢占式调度**。

另外一条道路就是协程，从用户层面改良，cpu教我做事。

> 如果你觉得Thread#sleep会浪费并发效率，那你就不要用！你要提交能充分利用我效率的任务，而不是一味的谩骂和指责。
>
> ​																																												—— CPU

既然`Thread.sleep()`会导致并发效率低下，那我就不用！在线程下面再区分出来一个协程的概念，在这里把无用的任务过滤一遍，再交给线程。这样每个内核对每个线程的利用率就提高了，也可以提高并发效率。

是不是感觉java的线程也挺像协程的:)，之前蔷神讲协程也说过线程也可以看成协程的一种实现。我个人觉得他们唯一不同的地方就在于线程是由内核来调度，处于**内核态**，协程由用户编写的逻辑进行调度，处于**用户态**。协程其实是减少了内核的**无用的**工作量，所以并发吞吐量更大。

![](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/飞书20220708-161709.jpg)

**---私货结束---**

程序计数器是JVM唯一一个不会产生OOM的内存区域。

> 在执行Java方法时，程序计数器的值为正在执行的虚拟机字节码指令的地址
>
> 在执行本地方法时，程序计数器的值为空(undefined)

#### 虚拟机栈

其实大家应该都知道所谓堆和栈的概念吧。即便Jvm的堆和栈你没有了解过，在C/C++课上应该也了解过堆栈的概念吧？虽然C++这种直接编译到native的语言中的堆和栈与Jvm语言中的堆和栈并不是一个东西——JVM是virtual machine，是虚拟机，它的一切特性都是软件模拟的。C++中我们执行程序直接使用硬件的堆栈，而Java我们执行程序使用JVM为我们模拟出来的堆栈。

与程序计数器一样，虚拟机栈也是线程私有的, 它的生命周期与线程相同，随线程的释放而释放。每当一个方法被调用，虚拟机都会同步创建一个栈帧用于存储**局部变量表，操作数栈，动态连接，方法出口**等信息。每一个方法从调用到返回的过程就对应着一个栈帧入栈到出栈的过程。

这里从别人那里抄来了一个流程图解

>可能听起来有点懵逼，这里我们来模拟一下整个虚拟机栈的运作流程，先编写一个测试类：
>
>```java
>public class Main {
>    public static void main(String[] args) {
>        int res = a();
>        System.out.println(res);
>    }
>
>    public static int a(){
>        return b();
>    }
>
>    public static int b(){
>        return c();
>    }
>
>    public static int c(){
>        int a = 10;
>        int b = 20;
>        return a + b;
>    }
>}
>```
>
>当我们的主方法执行后，会依次执行三个方法`a() -> b() -> c() -> 返回`
>
>可以看到在编译之后，我们整个方法的最大操作数栈深度、局部变量表都是已经确定好的，当我们程序开始执行时，会根据这些信息封装为对应的栈帧，我们从`main`方法开始看起：
>
>![image-20220131142625842](https://tva1.sinaimg.cn/large/008i3skNly1gywucw6rcyj30ws0gyq4h.jpg)
>
>接着我们继续往下，调用方法`a()`，这时当前方法就不会继续向下运行了，而是去执行方法`a()`，那么同样的，将此方法也入栈，注意是放入到栈顶位置，`main`方法的栈帧会被压下去：
>
>![image-20220131143641690](https://tva1.sinaimg.cn/large/008i3skNly1gywuhfjok5j30v40g875z.jpg)
>
>这时，进入方法a之后，又继而进入到方法b，最后在进入c，因此，到达方法c的时候，我们的虚拟机栈变成了：
>
>![image-20220131144209743](https://tva1.sinaimg.cn/large/008i3skNly1gywun3qnp6j30zq0h6jtq.jpg)
>
>现在我们依次执行方法c中的指令，最后返回a+b的结果，在方法c返回之后，也就代表方法c已经执行结束了，栈帧4会自动出栈，这时栈帧3就得到了上一栈帧返回的结果，并继续执行，但是由于紧接着马上就返回，所以继续重复栈帧4的操作，此时栈帧3也出栈并继续将结果交给下一个栈帧2，最后栈帧2再将结果返回给栈帧1，然后栈帧1就可以继续向下运行了，最后输出结果。
>
>![image-20220131144955668](https://tva1.sinaimg.cn/large/008i3skNgy1gywxbv24qlj30tk0giwg2.jpg)

虚拟机栈并不是无限大的，如果其中堆积的栈帧数量太多就会**爆栈**(StackOverFlowException)，我们可以通过`-Xss size`的vm options设置虚拟机的栈大小。

常见关于虚拟机栈的问题:

垃圾回收是否涉及栈内存？

- **不涉及**，垃圾回收只涉及堆内存。在方法返回后其对应的栈帧就会出栈，所以不需要回收内存。

栈内存分配得越大越好吗?

- **不**，栈内存大了，其他的内存区域就小了。有时你对递归调用并没有这么大的需求，毕竟所有的递归调用都可以通过循环实现。

#### 本地方法栈

本地方法栈其实跟虚拟机栈的作用非常相似，只是他们一个为字节码层面的方法服务，一个为本地方法服务。

#### Java堆

Java堆是虚拟机管理的内存中最大的一块, 用来存放对象实例。也是GC的主战场。不同于以上几个区域，Java堆是线程间共享的。所以在访问堆中存储的数据需要注意线程安全问题。

#### 方法区

与Java堆一样是线程间共享的区域，它主要用于存储已经被虚拟机加载的**类型信息，常量，静态变量，即时编译器编译后的代码缓存**。虽然《Java虚拟机规范》中把方法区描述为堆的一个逻辑部分，但它却有一个别名叫做“非堆”(Non-Heap)，目的是与Java堆区分开来。

你可能会听说方法区就是堆的永久代这个说法，实际不是这样的。仅仅只是因为HotSpot VM选择使用永久代来实现方法区，但实际上这是两个完全不同的概念。

> 可能看起来有点突兀，只是写到这里的时候突然想说一下JIT（即时编译器）的工作流程
>
> 这里可以发现其实jvm并非单纯解释执行字节码，而是在解释量达到一定阈值后触发即时编译，将编译后的字节码缓存到方法区，下次调用时便可以直接执行编译后的机器码。（也就是说常用的方法会被缓存为机器码）
>
> ![img](https://pic4.zhimg.com/80/v2-b6f9389c136957504a5c1ae563aba5f3_1440w.jpg)

**运行时常量池**

运行时常量池是方法区的一部分。在类加载时JVM读取class文件中常量池表的信息，并把它存入运行时常量池。至于常量池表，下面我们讲字节码的时候再详细介绍，现在我们只需要知道它是存放程序运行所需的常量即可。

而运行时常量池的另外一个重要特征就是具备**动态性**，Java并不要求常量一定只有在编译期才能产生，这点与c++不同，运行期间也可以有新的常量进入常量池。这种特性被开发人员利用得比较多的就是`String#intern()`方法。

> 关于String#intern方法，直接使用双引号声明的字符串都会直接存储在常量池中
>
> 而非通过双引号声明出来的字符串可以使用String#intern方法查询常量池中是否存在该字符串，若不存在就会将其放入常量池
>
> 是不是又可以理解java的字符串对象为什么不可变了，因为我们一般获取的字符串都会存储在常量池中，如果直接对字符串对象动刀岂不是没有意义了
>
> 这也是为什么不推荐直接通过String的构造方法获得一个String对象的原因，因为这样会new出来一个新对象，而非存储在常量池中的字符串

### 对象

#### 创建对象大致流程

##### 类加载检查

当jvm遇到一条字节码new指令的时候，首先将会检查这个指令的参数是否能在常量池定位到一个类的符号引用，并且检查这个符号引用代表的类是否已经被加载，解析和初始化过。如果没有，先执行相应的类加载过程。

##### 分配内存

- 指针碰撞

​	在Java堆规整的情况下（所有对象的地址连续），为新对象分配内存只需要把指针向空闲区域移动

- 空闲列表

​	在Java堆内存存放分散的情况下，我们必须维护一个列表，记录哪些内存块是可用的，分配内存时从列表中找到合适的内存块，并更新表上的记录。

**分配内存这个过程需要保证线程安全**，一般采取两种做法: 

- 对分配内存空间的动作进行同步处理——实际上虚拟机是采用CAS配上失败重试的方式保证更新操作的原子性
- 为每条线程预先分配一块堆内存，即本地线程分配缓冲，哪个线程要分配内存，就在哪个线程的本地缓冲区分配。本地缓冲区消耗完了才会锁同步。

##### 初始化内存空间

即为对象的成员变量赋初值，没有赋初值的初始化为类型对应零值（引用类型对应null）

##### 初始化对象头 (Object Header)

Java虚拟机需要对对象进行必要的设置，例如这个对象是哪个类的实例，如何才能找到类的元数据信息，对象的hash code(实际上会延后到调用`Object#hashCode()`才会计算)，对象的GC分代年龄等信息，这些信息会存放在对象的**对象头**中。

##### 调用构造器

使用正常途径新建对象必不可少的环节，当然使用`Unsafe#allocateInstance()`创建对象是可以跳过这一步的。(Gson的反序列化出来的对象就是使用它新建的，所以说它不适合Kt，因为Kt的空安全检查逻辑实际上是写在构造器里的，Gson这样做直接跳过了空安全检查)

#### 对象的内存布局

在HotSpot虚拟机中，对象在堆内存中的储存布局可以划分为三个部分: 对象头(Header)，实例数据(Instance Data)和对齐填充(Padding)。

对象头中包含两类信息: 第一类是用于存储对象自身的运行时数据，如HashCode，GC分代年龄，锁状态标志，线程持有的锁，偏向线程ID，偏向时间戳等，这部分数据的长度在32位和64位的虚拟机中分别为32和64个bit，官方称它为“Mark World”。

实例数据部分是对象真正存储的有效信息，即我们在程序代码中所定义的字段等内容

对齐填充部分只是起到一个占位符的作用，由于HotSpot虚拟机的自动内存管理系统要求对象起始地址必须是8字节的整数倍，也就是说任何对象的大小都必须是8字节的倍数。对象头部分已经被精心设计为8字节的倍数（1倍或2倍）。因此，如果对象实例数据部分没有对齐的话，就需要通过对齐填充来补全。

#### 对象的访问定位

创建对象自然是为了使用对象，我们的java程序一般通过栈上保存的**reference**(即引用)来操作堆上的具体对象。但Java虚拟机规范中只规定了这个reference类型是一个指向对象的引用，并没有强制要求这个引用应该如何定位，访问对象。所以对象访问方式也是由虚拟机实现而定的，主流的访问方式主要有使用**句柄**和**指针**。

##### 句柄

>  如果使用句柄访问的话，Java堆中将可能划分出一块内存来作为句柄池，reference中存储的就是对象的句柄地址，而句柄中包含了对象的实例数据与类型数据各自具体的地址信息

使用句柄来访问的最大好处是reference中存储的是稳定的句柄地址，在对象被移动（GC时移动是很普遍的行为）时只会改变句柄中的实例数据指针，而reference本身不需要被修改。

![飞书20220708-221205](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/%E9%A3%9E%E4%B9%A620220708-221205.png)

##### 指针

> 如果直接使用指针访问的话，Java堆中对象的内存布局就必须考虑如何放置访问类型的相关信息，reference中存储的直接就是对象地址，如果只是访问对象本身的话，就不需要多一次访问的开销。

直接使用指针访问的好处在与速度快，它节省了一次指针定位的开销，由于对象访问在java中非常频繁，这笔开销相当不容小觑。**HotSpot**虚拟机采用指针访问

![飞书20220708-221128](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/%E9%A3%9E%E4%B9%A620220708-221128.png)

### 垃圾回收 (GC)

大家应该都知道这个东西，我就不介绍了，直接切入正题

#### 引用计数算法 & 可达性分析算法

在堆中存放着Java世界中几乎所有的对象实例，垃圾收集器在堆中进行回收前，第一件事就是要确定这些对象之中还有哪些”存活“着，哪些已经“死去”。下面就讲一讲比较常见的两种判断的方法。

##### 引用计数算法

在对象中添加一个引用计数器，每当有一个地方引用它时，计数器值就+1，引用失效时，计数器值就-1。任何时候计数器为0的对象是不可能再使用的，可以直接回收。

虽然引用计数法简单高效，在大多数情况下是一个不错的算法。但主流的Java虚拟机并没有采用引用计数法进行内存管理，因为这个算法需要处理大量的意外情况——比如循环引用。

##### 可达性分析算法

当前主流的商用应用语言（Java，C#等）的内存管理子系统都是通过**可达性分析**算法来判定对象是否存活。这个算法的基本思路就是通过一系列称为**GC Roots**的根对象作为起始节点集，从这些节点开始，根据引用关系向下搜索，搜索过程中走过路径称为**引用链**，如果某个对象到GC Roots间没有任何引用链相连，则该对象**不可达**，就会被判定为可回收的对象。

可作为GC Roots的对象:

- 在虚拟机栈中引用的对象
- 方法区中类静态属性引用的对象 （例如Java的引用类型静态变量）
- 方法区中常量引用的对象 （例如字符串常量池中的引用）
- 在本地方法栈中JNI引用的对象
- Java虚拟机内部的引用，如**基本数据类型对应的Class对象**，一些常驻的异常对象（如NullPointerException）等，还有系统类加载器。

![](https://img-blog.csdn.net/20180626084654607?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3l1YnVqaWFuX2w=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

#### 引用的类型

实际上GC的回收策略并不死板，在剩余内存较少的时候，GC会尽可能回收多的对象来腾出更多的内存空间。那么我们要如何规定在剩余内存较少的时候才需要回收的那部分对象呢？于是在JDK1.2之后，Java对引用的概念进行了扩充，将引用分为**强引用，软引用，弱引用，虚引用**四种类型。

##### 强引用

最传统的引用定义，指程序代码中普遍存在的引用赋值。只要强引用关系存在，GC就不会回收被引用的对象。

##### 软引用

软引用用来描述一些还需要用到，但非必须的对象，在内存不足时，GC会回收掉只被软引用关联的对象。可以使用`SoftReference`类来实现软引用。

##### 弱引用

只被弱引用关联的对象只能存活到下一次GC到来前。可以使用`WeakReference`类来实现弱引用。

##### 虚引用

相当于没有引用，也没有办法通过这种引用得到关联的对象，为一个对象设置虚引用的唯一目的就是为了能在对象被回收时收到通知。可以使用`PhantomReference`类来实现虚引用。

#### 垃圾收集算法

##### 分代收集理论

实际上，如果我们对堆中的每一个对象都依次判断是否需要回收，这样的效率其实是很低的，那么有没有更好地回收机制呢？第一步，我们可以对堆中的对象进行分代管理。

比如某些对象，在多次垃圾回收时，都未被判定为可回收对象，我们完全可以将这一部分对象放在一起，并让垃圾收集器减少回收此区域对象的频率，这样就能很好地提高垃圾回收的效率了。

因此，Java虚拟机将堆内存划分为**新生代**、**老年代**和**永久代**（其中永久代是HotSpot虚拟机特有的概念，在JDK8之前方法区实际上就是采用的永久代作为实现，而在JDK8之后，方法区由元空间实现，并且使用的是本地内存，容量大小取决于物理机实际大小，之后会详细介绍）这里我们主要讨论的是**新生代**和**老年代**。

不同的分代内存回收机制也存在一些不同之处，在HotSpot虚拟机中，新生代被划分为三块，一块较大的Eden空间和两块较小的Survivor空间，默认比例为8：1：1，老年代的GC评率相对较低，永久代一般存放类信息等（其实就是方法区的实现）如图所示：

![image-20220222151708141](https://tva1.sinaimg.cn/large/e6c9d24egy1gzmbaa6eg9j217a0ggta0.jpg)

那么它是如何运作的呢？

首先，所有新创建的对象，在一开始都会进入到新生代的Eden区（如果是大对象会被直接丢进老年代），在进行新生代区域的垃圾回收时，首先会对所有新生代区域的对象进行扫描，并回收那些不再使用对象：

![image-20220222153104582](https://tva1.sinaimg.cn/large/e6c9d24egy1gzmbyo48r0j21i20cqq4l.jpg)

接着，在一次垃圾回收之后，Eden区域没有被回收的对象，会进入到Survivor区。在一开始From和To都是空的，而GC之后，所有Eden区域存活的对象都会直接被放入到From区，最后From和To会发生一次交换，也就是说目前存放我们对象的From区，变为To区，而To区变为From区：

![image-20220222154032674](https://tva1.sinaimg.cn/large/e6c9d24egy1gzmbyn34yfj21gk0d4gn5.jpg)

接着就是下一次垃圾回收了，操作与上面是一样的，不过这时由于我们From区域中已经存在对象了，所以，在Eden区的存活对象复制到From区之后，所有To区域中的对象会进行年龄判定（每经历一轮GC年龄`+1`，如果对象的年龄大于`默认值为15`，那么会直接进入到老年代，否则移动到From区）

![image-20220222154828416](https://tva1.sinaimg.cn/large/e6c9d24egy1gzmc6v1nzcj21h60d2q4l.jpg)

最后像上面一样交换To区和From区，之后不断重复以上步骤。

而垃圾收集也分为：

* Minor GC   -   次要垃圾回收，主要进行新生代区域的垃圾收集。

  * 触发条件：新生代的Eden区容量已满时。

* Major GC   -   主要垃圾回收，主要进行老年代的垃圾收集。

* Full GC      -    完全垃圾回收，对整个Java堆内存和方法区进行垃圾回收。

  * 触发条件1：每次晋升到老年代的对象平均大小大于老年代剩余空间
  * 触发条件2：Minor GC后存活的对象超过了老年代剩余空间
  * 触发条件3：永久代内存不足（JDK8之前）
  * 触发条件4：手动调用`System.gc()`方法

  ![image-20220222205605690](https://tva1.sinaimg.cn/large/e6c9d24ely1gzml30209wj21u80ren3q.jpg)

##### 标记-清除算法

前面我们已经了解了整个堆内存实际上是以分代收集机制为主，但是依然没有讲到具体的收集过程，那么，具体的回收过程又是什么样的呢？首先我们来了解一下最古老的`标记-清除`算法。

首先标记出所有需要回收的对象，然后再依次回收掉被标记的对象，或是标记出所有不需要回收的对象，只回收未标记的对象。实际上这种算法是非常基础的，并且最易于理解的（这里对象我就以一个方框代替了，当然实际上存放是我们前说到的GC Roots形式）

![image-20220222165709034](https://tva1.sinaimg.cn/large/e6c9d24egy1gzme6btluwj21e40c0760.jpg)

虽然此方法非常简单，但是缺点也是非常明显的 ，首先如果内存中存在大量的对象，那么可能就会存在大量的标记，并且大规模进行清除。并且一次标记清除之后，连续的内存空间可能会出现许许多多的空隙，碎片化会导致连续内存空间利用率降低。

##### 标记-复制算法

既然标记清除算法在面对大量对象时效率低，那么我们可以采用标记-复制算法。它将容量分为同样大小的两块区域，

标记复制算法，实际上就是将内存区域划分为大小相同的两块区域，每次只使用其中的一块区域，每次垃圾回收结束后，将所有存活的对象全部复制到另一块区域中，并一次性清空当前区域。虽然浪费了一些时间进行复制操作，但是这样能够很好地解决对象大面积回收后空间碎片化严重的问题。

![image-20220222210942507](https://tva1.sinaimg.cn/large/e6c9d24ely1gzmlh5aveqj21ti0u079c.jpg)

这种算法就非常适用于新生代（因为新生代的回收效率极高，一般不会留下太多的对象）的垃圾回收，而我们之前所说的新生代Survivor区其实就是这个思路，包括8:1:1的比例也正是为了对标记复制算法进行优化而采取的。

##### 标记-整理算法

虽然标记-复制算法能够很好地应对新生代高回收率的场景，但是放到老年代，它就显得很鸡肋了。我们知道，一般长期都回收不到的对象，才有机会进入到老年代，所以老年代一般都是些钉子户，可能一次GC后，仍然存留很多对象。而标记复制算法会在GC后完整复制整个区域内容，并且会折损50%的区域，显然这并不适用于老年代。

那么我们能否这样，在标记所有待回收对象之后，不急着去进行回收操作，而是将所有待回收的对象整齐排列在一段内存空间中，而需要回收的对象全部往后丢，这样，前半部分的所有对象都是无需进行回收的，而后半部分直接一次性清除即可。

![image-20220222213208681](https://tva1.sinaimg.cn/large/e6c9d24ely1gzmm4g8voxj21vm08ywhj.jpg)

虽然这样能保证内存空间充分使用，并且也没有标记复制算法那么繁杂，但是缺点也是显而易见的，它的效率比前两者都低。甚至，由于需要修改对象在内存中的位置，此时程序必须要暂停才可以，在极端情况下，可能会导致整个程序发生停顿（被称为“Stop The World”）。

所以，我们可以将标记清除算法和标记整理算法混合使用，在内存空间还不是很凌乱的时候，采用标记清除算法其实是没有多大问题的，当内存空间凌乱到一定程度后，我们可以进行一次标记整理算法。

#### 各种垃圾收集器 (只讲部分具有代表性的)

##### Serial

这款垃圾收集器也是元老级别的收集器了，在JDK1.3.1之前，是虚拟机新生代区域收集器的唯一选择。这是一款单线程的垃圾收集器，也就是说，当开始进行垃圾回收时，需要暂停所有的线程，直到垃圾收集工作结束。它的新生代收集算法采用的是标记复制算法，老年代采用的是标记整理算法。

![image-20220223104605648](https://tva1.sinaimg.cn/large/e6c9d24ely1gzn92k8ooej21ae0bc75m.jpg)

可以看到，当进入到垃圾回收阶段时，所有的用户线程必须等待GC线程完成工作，就相当于你打一把游戏，中途每隔1分钟网络就卡5秒钟，这确实让人难以接受。

虽然缺点很明显，但是优势也是显而易见的：

1. 设计简单而高效。
2. 在用户的桌面应用场景中，内存一般不大，可以在较短时间内完成垃圾收集，只要不频繁发生，使用串行回收器是可以接受的。

##### ParNew

这款垃圾收集器相当于是Serial收集器的多线程版本，它能够支持多线程垃圾收集：

![image-20220223111344962](https://tva1.sinaimg.cn/large/e6c9d24ely1gzn9vbvb0mj21c20c00uc.jpg)

除了多线程支持以外，其他内容基本与Serial收集器一致，并且目前某些JVM默认的服务端模式新生代收集器就是使用的ParNew收集器。

##### CMS

在JDK1.5，HotSpot推出了一款在强交互应用中几乎可认为有划时代意义的垃圾收集器：CMS（Concurrent-Mark-Sweep）收集器，这款收集器是HotSpot虚拟机中第一款真正意义上的并发（注意这里的并发和之前的并行是有区别的，并发可以理解为同时运行用户线程和GC线程，而并行可以理解为多条GC线程同时工作）收集器，它第一次实现了让垃圾收集线程与用户线程同时工作。

它主要采用标记清除算法：

![image-20220223114019381](https://tva1.sinaimg.cn/large/e6c9d24ely1gznamys2bdj21as0co404.jpg)

它的垃圾回收分为4个阶段：

* 初始标记（需要暂停用户线程）：这个阶段的主要任务仅仅只是标记出GC Roots能直接关联到的对象，速度比较快，不用担心会停顿太长时间。
* 并发标记：从GC Roots的直接关联对象开始遍历整个对象图的过程，这个过程耗时较长但是不需要停顿用户线程，可以与垃圾收集线程一起并发运行。
* 重新标记（需要暂停用户线程）：由于并发标记阶段可能某些用户线程会导致标记产生变得，因此这里需要再次暂停所有线程进行并行标记，这个时间会比初始标记时间长一丢丢。
* 并发清除：最后就可以直接将所有标记好的无用对象进行删除，因为这些对象程序中也用不到了，所以可以与用户线程并发运行。

虽然它的优点非常之大，但是缺点也是显而易见的，我们之前说过，标记清除算法会产生大量的内存碎片，导致可用连续空间逐渐变少，长期这样下来，会有更高的概率触发Full GC，并且在与用户线程并发执行的情况下，也会占用一部分的系统资源，导致用户线程的运行速度一定程度上减慢。

不过，如果你希望的是最低的GC停顿时间，这款垃圾收集器无疑是最佳选择，不过自从G1收集器问世之后，CMS收集器不再推荐使用了。

##### Garbage First (JDK9+)

此垃圾收集器也是一款划时代的垃圾收集器，在JDK7的时候正式走上历史舞台，它是一款主要面向于服务端的垃圾收集器，并且在JDK9时，取代了JDK8默认的 Parallel Scavenge + Parallel Old 的回收方案。

我们知道，我们的垃圾回收分为`Minor GC`、`Major GC `和`Full GC`，它们分别对应的是新生代，老年代和整个堆内存的垃圾回收，而G1收集器巧妙地绕过了这些约定，它将整个Java堆划分成`2048`个大小相同的独立`Region`块，每个`Region块`的大小根据堆空间的实际大小而定，整体被控制在1MB到32MB之间，且都为2的N次幂。所有的`Region`大小相同，且在JVM的整个生命周期内不会发生改变。

那么分出这些`Region`有什么意义呢？每一个`Region`都可以根据需要，自由决定扮演哪个角色（Eden、Survivor和老年代），收集器会根据对应的角色采用不同的回收策略。此外，G1收集器还存在一个Humongous区域，它专门用于存放大对象（一般认为大小超过了Region容量一半的对象为大对象）这样，新生代、老年代在物理上，不再是一个连续的内存区域，而是到处分布的。

![image-20220223123636582](https://tva1.sinaimg.cn/large/e6c9d24ely1gznc9jvdzdj21f40eiq4g.jpg)

它的回收过程与CMS大体类似：

![image-20220223123557871](https://tva1.sinaimg.cn/large/e6c9d24ely1gznc8vqqqij21h00emwgt.jpg)

分为以下四个步骤：

* 初始标记（暂停用户线程）：仅仅只是标记一下GC Roots能直接关联到的对象，并且修改TAMS指针的值，让下一阶段用户线程并发运行时，能正确地在可用的Region中分配新对象。这个阶段需要停顿线程，但耗时很短，而且是借用进行Minor GC的时候同步完成的，所以G1收集器在这个阶段实际并没有额外的停顿。
* 并发标记：从GC Root开始对堆中对象进行可达性分析，递归扫描整个堆里的对象图，找出要回收的对象，这阶段耗时较长，但可与用户程序并发执行。
* 最终标记（暂停用户线程）：对用户线程做一个短暂的暂停，用于处理并发标记阶段漏标的那部分对象。
* 筛选回收：负责更新Region的统计数据，对各个Region的回收价值和成本进行排序，根据用户所期望的停顿时间来制定回收计划，可以自由选择任意多个Region构成回收集，然后把决定回收的那一部分Region的存活对象复制到空的Region中，再清理掉整个旧Region的全部空间。这里的操作涉及存活对象的移动，是必须暂停用户线程，由多个收集器线程并行完成的。

##### Shenandoah & ZGC (低延迟)

专为低延迟场景特化的垃圾收集器，论综合表现可能比不上G1，但他们暂停线程的时间比G1还要短得多。适合一些对GC延迟有特殊要求的特殊场景。具体不想介绍了，有兴趣可以课下了解，他们的几乎整个工作过程都是并发的，工作原理蛮有意思的。

## 字节码

终于写到这里了，我最想讲的就是这个，这个也最好玩:D

### 什么是字节码

众所周知，Java是一门跨平台语言，只要能跑JVM的平台都能运行同一份Jar包。而Jar包其实本质上就是一堆class文件和一些资源文件打包放到一个压缩包里罢了，我们也可以直接运行class文件。那么class文件里面有什么内容呢？肯定不可能是机器码吧，如果是机器码要怎么跨平台？答案就是字节码。Kotlin之所以兼容Java，也是因为它是把kt文件编译成字节码，而Java和Kotlin之间的相互调用其实就是字节码之间的调用。JVM内置字节码解释器，在运行时动态解释字节码文件，把字节码翻译成对应平台的机器码运行。

### 类文件的基础结构

Class文件是一组以8个字节为基础单位的二进制流，当遇到需要占用8个字节以上空间的数据项时，则会按照高位在前的方式分割成若干个8个字节进行存储。Class文件使用一种类似于C语言结构体的伪结构来存储数据，这种伪结构中只有两种数据类型: **无符号数**, **表**。后面的解析都以这两种数据类型为基础。

我们先来看一段示例代码

~~~java
public class TestClazz {
    public static void main(String[] args) {
        int a = 1;
        int b = 2 + a;
        System.out.println(sum(a, b));
    }

    private static int sum(int a, int b) {
        System.out.println("execute sum function.");
        return a + b;
    }
}
~~~

我们用`javap -verbose` 指令将它编译并解码为我们肉眼可以观测的字节码

~~~
Classfile /D:/project/android/ksp-learn/test/build/classes/java/main/kim/bifrost/rain/ksp/TestClazz.class
  Last modified 2022-7-9; size 754 bytes
  MD5 checksum 2b38afaa297c7960c988943b0c475282
  Compiled from "TestClazz.java"
public class kim.bifrost.rain.ksp.TestClazz
  minor version: 0
  major version: 52
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #8.#27         // java/lang/Object."<init>":()V
   #2 = Fieldref           #28.#29        // java/lang/System.out:Ljava/io/PrintStream;
   #3 = Methodref          #7.#30         // kim/bifrost/rain/ksp/TestClazz.sum:(II)I
   #4 = Methodref          #31.#32        // java/io/PrintStream.println:(I)V
   #5 = String             #33            // execute sum function.
   #6 = Methodref          #31.#34        // java/io/PrintStream.println:(Ljava/lang/String;)V
   #7 = Class              #35            // kim/bifrost/rain/ksp/TestClazz
   #8 = Class              #36            // java/lang/Object
   #9 = Utf8               <init>
  #10 = Utf8               ()V
  #11 = Utf8               Code
  #12 = Utf8               LineNumberTable
  #13 = Utf8               LocalVariableTable
  #14 = Utf8               this
  #15 = Utf8               Lkim/bifrost/rain/ksp/TestClazz;
  #16 = Utf8               main
  #17 = Utf8               ([Ljava/lang/String;)V
  #18 = Utf8               args
  #19 = Utf8               [Ljava/lang/String;
  #20 = Utf8               a
  #21 = Utf8               I
  #22 = Utf8               b
  #23 = Utf8               sum
  #24 = Utf8               (II)I
  #25 = Utf8               SourceFile
  #26 = Utf8               TestClazz.java
  #27 = NameAndType        #9:#10         // "<init>":()V
  #28 = Class              #37            // java/lang/System
  #29 = NameAndType        #38:#39        // out:Ljava/io/PrintStream;
  #30 = NameAndType        #23:#24        // sum:(II)I
  #31 = Class              #40            // java/io/PrintStream
  #32 = NameAndType        #41:#42        // println:(I)V
  #33 = Utf8               execute sum function.
  #34 = NameAndType        #41:#43        // println:(Ljava/lang/String;)V
  #35 = Utf8               kim/bifrost/rain/ksp/TestClazz
  #36 = Utf8               java/lang/Object
  #37 = Utf8               java/lang/System
  #38 = Utf8               out
  #39 = Utf8               Ljava/io/PrintStream;
  #40 = Utf8               java/io/PrintStream
  #41 = Utf8               println
  #42 = Utf8               (I)V
  #43 = Utf8               (Ljava/lang/String;)V
{
  public kim.bifrost.rain.ksp.TestClazz();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 10: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   Lkim/bifrost/rain/ksp/TestClazz;

  public static void main(java.lang.String[]);
    descriptor: ([Ljava/lang/String;)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=3, locals=3, args_size=1
         0: iconst_1
         1: istore_1
         2: iconst_2
         3: iload_1
         4: iadd
         5: istore_2
         6: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
         9: iload_1
        10: iload_2
        11: invokestatic  #3                  // Method sum:(II)I
        14: invokevirtual #4                  // Method java/io/PrintStream.println:(I)V
        17: return
      LineNumberTable:
        line 12: 0
        line 13: 2
        line 14: 6
        line 15: 17
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      18     0  args   [Ljava/lang/String;
            2      16     1     a   I
            6      12     2     b   I
}
SourceFile: "TestClazz.java"
~~~

#### 魔数 & Class文件版本

class文件的前4个Byte被称为魔数(Magic Number), 这些魔数的意义在于标识class文件。在类的加载阶段会根据这头四个Byte判断是否是合法的class文件。魔数的选取也颇有历史渊源`0xCAFE BABE`，Java的创始人十分喜欢咖啡:)。

![aZx0S4EjfY](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/aZx0S4EjfY.jpg)

![飞书20220709-173350](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/%E9%A3%9E%E4%B9%A620220709-173350.jpg)

随后第四个字节，也就是7列存储着字节码的版本号。这里是34，从16进制翻译过来就是52，对应着Java8的字节码版本。

第5和第6个字节是次版本号（Minor Version）,第7，8个字节是主版本号（Major Version）。Java是版本号是从45开始，JDK1.1之后的每个JDK大版本发布主版本号向上+1，高版本的JDK能向下兼容以前版本的Class文件，而不能运行以后版本的Class文件。

#### 常量池

即

~~~
Constant pool:
   #1 = Methodref          #8.#27         // java/lang/Object."<init>":()V
   #2 = Fieldref           #28.#29        // java/lang/System.out:Ljava/io/PrintStream;
   #3 = Methodref          #7.#30         // kim/bifrost/rain/ksp/TestClazz.sum:(II)I
   #4 = Methodref          #31.#32        // java/io/PrintStream.println:(I)V
   #5 = String             #33            // execute sum function.
   #6 = Methodref          #31.#34        // java/io/PrintStream.println:(Ljava/lang/String;)V
   #7 = Class              #35            // kim/bifrost/rain/ksp/TestClazz
   #8 = Class              #36            // java/lang/Object
   #9 = Utf8               <init>
  #10 = Utf8               ()V
  #11 = Utf8               Code
  #12 = Utf8               LineNumberTable
  #13 = Utf8               LocalVariableTable
  #14 = Utf8               this
  #15 = Utf8               Lkim/bifrost/rain/ksp/TestClazz;
  #16 = Utf8               main
  #17 = Utf8               ([Ljava/lang/String;)V
  #18 = Utf8               args
  #19 = Utf8               [Ljava/lang/String;
  #20 = Utf8               a
  #21 = Utf8               I
  #22 = Utf8               b
  #23 = Utf8               sum
  #24 = Utf8               (II)I
  #25 = Utf8               SourceFile
  #26 = Utf8               TestClazz.java
  #27 = NameAndType        #9:#10         // "<init>":()V
  #28 = Class              #37            // java/lang/System
  #29 = NameAndType        #38:#39        // out:Ljava/io/PrintStream;
  #30 = NameAndType        #23:#24        // sum:(II)I
  #31 = Class              #40            // java/io/PrintStream
  #32 = NameAndType        #41:#42        // println:(I)V
  #33 = Utf8               execute sum function.
  #34 = NameAndType        #41:#43        // println:(Ljava/lang/String;)V
  #35 = Utf8               kim/bifrost/rain/ksp/TestClazz
  #36 = Utf8               java/lang/Object
  #37 = Utf8               java/lang/System
  #38 = Utf8               out
  #39 = Utf8               Ljava/io/PrintStream;
  #40 = Utf8               java/io/PrintStream
  #41 = Utf8               println
  #42 = Utf8               (I)V
  #43 = Utf8               (Ljava/lang/String;)V
~~~

紧接着主次版本号之后的是常量池入口，常量池可以比喻为Class文件里的资源仓库，它是Class文件结构中与其他项目关联最多的数据。

首先上来就会有一个1字节的无符号数，它用于表示当前常量的类型（常量类型有很多个）这里只列举一部分的类型介绍：

|           类型            | 标志 |                             描述                             |
| :-----------------------: | :--: | :----------------------------------------------------------: |
|    CONSTANT_Utf8_info     |  1   |                    UTF-8编码格式的字符串                     |
|   CONSTANT_Integer_info   |  3   | 整形字面量（第一章我们演示的很大的数字，实际上就是以字面量存储在常量池中的） |
|    CONSTANT_Class_info    |  7   |                      类或接口的符号引用                      |
|   CONSTANT_String_info    |  8   |                      字符串类型的字面量                      |
|  CONSTANT_Fieldref_info   |  9   |                        字段的符号引用                        |
|  CONSTANT_Methodref_info  |  10  |                        方法的符号引用                        |
| CONSTANT_MethodType_info  |  16  |                           方法类型                           |
| CONSTANT_NameAndType_info |  12  |                   字段或方法的部分符号引用                   |

实际上这些东西，虽然我们不知道符号引用是什么东西，我们可以观察出来，这些东西或多或少都是存放类中一些名称、数据之类的东西。

比如我们来看第一个`CONSTANT_Methodref_info`表中存放了什么数据，这里我只列出它的结构表（详细的结构表可以查阅《深入理解Java虚拟机 第三版》中222页总表）：

|          常量           | 项目  | 类型 |                        描述                         |
| :---------------------: | :---: | :--: | :-------------------------------------------------: |
| CONSTANT_Methodref_info |  tag  |  u1  |                       值为10                        |
|                         | index |  u2  |   指向声明方法的类描述父CONSTANT_Class_info索引项   |
|                         | index |  u2  | 指向名称及类型描述符CONSTANT_NameAndType_info索引项 |

再看看它指向的`CONSTANT_Class_info`和`CONSTANT_NameAndType_info`的结构

|        常量         | 项目  | 类型 |           描述           |
| :-----------------: | :---: | :--: | :----------------------: |
| CONSTANT_Class_info |  tag  |  u1  |          值为7           |
|                     | index |  u2  | 指向全限定名常量项的索引 |

|           常量            | 项目  | 类型 |               描述               |
| :-----------------------: | :---: | :--: | :------------------------------: |
| CONSTANT_NameAndType_info |  tag  |  u1  |              值为12              |
|                           | index |  u2  |  指向字段或方法名称常量项的索引  |
|                           | index |  u2  | 指向字段或方法描述符常量项的索引 |

##### 方法标识符

再说一下方法标识符，我们先找到sum方法的NameAndType常量

> #30 = NameAndType        #23:#24        // sum:(II)I

我们会发现这里已经为我们标识出来了，#23对应`sum`，也就是方法名称。#24对应`(II)I`即方法标识符。

那么这个(II)I有什么意思呢，括号内的两个I代表该方法有两个int类型的形参，括号后面的I代表该方法的返回值是int类型。

至于不同类型的修饰符，我贴一个表在下面:

![image-20220223192518999](https://tva1.sinaimg.cn/large/e6c9d24ely1gzno2stssaj216i08mjsr.jpg)

构造器的标识符为`()V`，即一个无形参，返回值为void类型的方法。

再举几个例子:

> public Set<ArathothAttribute> getAttrInstSet()
>
> ()Ljava/util/Set<ink/rainbowbridge/v1/arathoth/attribute/abstracts/ArathothAttribute;>;
>
> 如你所见，泛型并不会在编译时被擦除，只会在运行时
>
> 所以我们可以在运行时通过草字节码的方式获得一个已经被擦除的泛型

> public Double getRandom(Double value1, Double value2)
>
> (Ljava/lang/Double;Ljava/lang/Double;)Ljava/lang/Double;
>
> 装箱后的基础类型实际上是类
>
> 提点题外话
>
> public double sum(Double value1, double value2) {
>
> ​		return value1 + value2;
>
> }
>
> 你们觉得它编译出来字节码会怎么样:), 实际上字节码调用了value1的doubleValue()方法得到了未装箱的值，再进行相加。
>
> 反之亦然，java有自动装箱和自动拆箱的特性。

> 那么数组会如何呢
>
> public double[] getRandomNums()
>
> ()[D
>
> 当然是在前面加个[

#### 访问标志

即

~~~
  flags: ACC_PUBLIC, ACC_SUPER
~~~

从字面上应该就能猜出这些访问标志的意思，它们用来描述一个类/方法/字段的各种修饰符。

类的标志类型:

![image-20220223200619811](https://tva1.sinaimg.cn/large/e6c9d24ely1gznp9glonej216i0hcjui.jpg)

字段的标志类型:

![image-20220223201053780](https://tva1.sinaimg.cn/large/e6c9d24ely1gznpe7is4wj21620eswh4.jpg)

方法的标志类型:

| 标志名称         | 标志值 | 含义                             |
| ---------------- | ------ | -------------------------------- |
| ACC_PUBLIC       | 0x0001 | 方法是否为public                 |
| ACC_PRIVATE      | 0x0002 | 方法是否为private                |
| ACC_PROTECTED    | 0x0004 | 方法是否为protected              |
| ACC_STATIC       | 0x0008 | 方法是否为static                 |
| ACC_FINAL        | 0x0010 | 方法是否为final                  |
| ACC_SYNCHRONIZED | 0x0020 | 方法是否为synchronized           |
| ACC_BRIDGE       | 0x0040 | 方法是不是由编译器产生的桥接方法 |
| ACC_VARARGS      | 0x0080 | 方法是否接受不定参数             |
| ACC_NATIVE       | 0x0100 | 方法是否为native                 |
| ACC_ABSTRACT     | 0x0400 | 方法是否为abstract               |
| ACC_STRICT       | 0x0800 | 方法是否为strictfp               |
| ACC_SYNTHETIC    | 0x1000 | 方法是否由编译器自动产生         |

#### 字节码指令

> 我觉得字节码要细讲完全可以再单开一篇讲，这里就稍微讲一点基础的，让待会ASM的时候不至于完全懵逼就行

前面讲了这么多基本都是描述类和方法的信息，大家一定很好奇我们编写的程序逻辑到底放在哪里了吧。没错，我们编写的逻辑被编译成了面向操作**操作数栈**的字节码指令。为什么要说它是面向**操作数栈**的操作指令？接下来我会讲一讲main方法中所有字节码指令的作用，听完你们就知道了。

```java
public static void main(String[] args) {
    int a = 1;
    int b = 2 + a;
    System.out.println(sum(a, b));
}
```

    Code:
      stack=3, locals=3, args_size=1
         0: iconst_1
         1: istore_1
         2: iconst_2
         3: iload_1
         4: iadd
         5: istore_2
         6: getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;
         9: iload_1
        10: iload_2
        11: invokestatic  #3                  // Method sum:(II)I
        14: invokevirtual #4                  // Method java/io/PrintStream.println:(I)V
        17: return

---

> iconst_1

将一个int类型的常量`1`加载到**操作数栈**, 此时操作数栈深度为1。对应`int a = 1`中1的初始化。

> istore_1

将一个int类型的数值从**操作数栈**顶取出并存储到局部变量表，这个数值在操作数栈的位置为1，即我们刚才压进操作数栈的`1`，对应`int a = 1`中的赋值操作

> iconst_2

将一个int类型的常量`2`加载到**操作数栈**，此时操作数栈深度为2。对应 `int b = 2 + a`中2的初始化

> iload_1

将一个int类型的局部变量直接加载到**操作数栈**，这个局部变量在局部变量表的位置为1。即刚才第二条指令存进局部变量表的局部变量`a`

> iadd

将**操作数栈**顶的两个int类型的数值取出并相加，再压进**操作数栈**中，对应`int b = 2 + a`的加法运算

> istore_2

将一个int类型的数值从**操作数栈**顶中取出并存储到局部变量表，这个数值在**操作数栈**的位置为2，对应`int b = 2 + a`的赋值

> getstatic     #2                  // Field java/lang/System.out:Ljava/io/PrintStream;

获取静态域`System.out`, 类型为`Ljava/io/PrintStream`,并将其压入**操作数栈**顶。后面跟的`#2`在常量池中对应`Field java/lang/System.out:Ljava/io/PrintStream;`

> iload_1

将int类型的局部变量`a`加载到**操作数栈**，待用

> iload_2

将int类型的局部变量b加载到**操作数栈**，待用

> invokestatic  #3                  // Method sum:(II)I

执行所在类中的静态方法，传入栈顶的两个int数值作为形参，返回一个int类型的值压入栈顶

> invokevirtual #4                  // Method java/io/PrintStream.println:(I)V

执行`PrintStream#println`方法，传入栈顶元素作为参数，再传入下一个栈顶元素作为receiver（不知道java这个叫什么，反正kotlin有receiver这个概念）

> return

返回void

---

经过上面的分析我们已经大致知道了某些字节码的功能，你肯定也发现了，很大一部分字节码的功能是基于**操作数栈**实现的。

特别是基于栈的数学运算，挺有意思的，我记得我们上学期有一次红岩作业就是实现一个逻辑运算，当时去网上看了一下，要用逆波兰表达式的解析方式配合栈来实现，这应该也是jvm数学运算的实现方式吧，有兴趣可以再写一遍。

这里我就不系统性的讲解字节码指令了，太多了，根本讲不完。但你们可以课下去了解，我一般是遇见不认识的然后再去查:)

### ASM框架

前面我们学习了字节码的基本结构以及部分字节码指令，我们一般使用ASM/Javassist/cglib等字节码操控框架来动态的修改/生成字节码。那么通过它们我们能做到什么事情呢?

- 编译期代码生成/替换 ，一般通过gradle插件干预编译实现（例如著名的gradle插件shadowJar的依赖包重定向(relocate)功能)。字节码插桩也是在这个过程进行。
- 运行期动态代理，可以做到一些InvocationHandler做不到的事情，例如修改类中包引用的包名。
- 在获取一些类的信息时，使用asm读取字节码比反射要快得多。
- 使用jvm一些奇奇怪怪的特性，例如[MeiVinEight/ReflectionFX: Reflection Toolkit (github.com)](https://github.com/MeiVinEight/ReflectionFX)，该项目利用字节码的一些乱七八糟的特性实现了性能开销更小的反射，其性能甚至能够与操作MethodHandle持平。

其实应该还有很多，我就不列举了。

这里可能有人有疑问，我们android不是编译成dex吗，那按照常规的方式操作字节码是可行的吗？答案是可行，因为我们字节码插桩的过程一般是

这里我主要介绍asm框架，它是最流行，最直接的操作字节码的框架，jdk甚至内置了一份。如果从学习字节码的角度来看，asm无疑是最合适的选择。同时安卓中用得比较多的技术就是字节码插桩，所以我准备讲一讲如何用asm框架实现字节码插桩。

#### ASM Core API & Tree API

##### Core API

ASM 是基于访问者模式设计的，访问者模式可以让ASM更好的操作某个Jar包/class文件中的所有类/字段/方法。因此要学会ASM，首先必须要了解访问者模式。(我其实懵逼了很久) 如果你们以后有兴趣了解kapt/ksp也会用到访问者模式。（实际上这俩很多时候是跟asm配合着用的, kapt/ksp生成代码，asm对代码进行插桩调用）

[访问者模式 | 菜鸟教程 (runoob.com)](https://www.runoob.com/design-pattern/visitor-pattern.html)

现在我们来讲讲基础用法:

ASM基于访问者模式，为我们提供了一套访问class文件中所有属性的API。

```java
public abstract class ClassVisitor {
        ......
    public void visit(int version, int access, String name, String signature, String superName, String[] interfaces);
    //访问类字段时回调
    public FieldVisitor visitField(int access, String name, String desc, String signature, Object value);
    //访问类方法是回调
    public MethodVisitor visitMethod(int access, String name, String desc, String signature, String[] exceptions);
    public void visitEnd();
}
```

在使用ClassVisitor访问类时，一旦访问到其中的属性就会回调到对应的属性的访问方法。

> ###### 1：void visit(int version, int access, String name, String signature, String superName, String[] interfaces)
>
> 访问class的头信息
>
> version：class版本（编译级别）
>
> access： 访问标示
>
> name：类名称
>
> signature：class的签名，可能是null
>
> superName：超类名称
>
> interfaces：接口的名称
>
> ###### 2：void visitAnnotation(String descriptor, boolean visible)
>
> 访问class的注解信息
>
> descriptor：描述信息
>
> visible：是否运行时可见
>
> ###### 3：FieldVisitor visitField(int access, String name,String descriptor, String signature,Object value)
>
> 访问class中字段的信息，返回一个FieldVisitor用于获取字段中更加详细的信息。
>
> name：字段个的名称
>
> descriptor：字段的描述
>
> value：该字段的初始值，文档上面说：
>
> 该参数，其可以是零，如果字段不具有初始值，必须是一个`Integer`，一`Float`，一`Long`，一个`Double`或一个`String`（对于`int`，`float`，`long` 或`String`分别字段）。*此参数仅用于静态字段*。对于非静态字段，它的值被忽略，非静态字段必须通过构造函数或方法中的字节码指令进行初始化（但是不管我怎么试，结果都是null）。
>
> ###### 4：MethodVisitor visitMethod(int access,String name,String descriptor,String signature, String[] exceptions)
>
> 访问class中方法的信息，返回一个MethodVisitor用于获取方法中更加详细的信息。
>
> name：方法的名称
>
> descriptor：方法的描述
>
> signature：方法的签名
>
> exceptions：方法的异常名称
>
> ###### 5：visitInnerClass(String name, String outerName, String innerName, int access)
>
> 访问class中内部类的信息。这个内部类不一定是被访问类的成员（这里的意思是可能是一段方法中的**匿名内部类**，或者**声明在一个方法中的类**等等）。
>
> name：内部类的名称。例子`com/hebaibai/example/demo/Aoo$1XX`
>
> outerName：内部类所在类的名称
>
> innerName：内部类的名称
>
> ###### 6：visitOuterClass(String owner, String name, String descriptor)
>
> 访问该类的封闭类。仅当类具有封闭类时，才必须调用此方法。
>
> 我自己试了一下，如果在一个方法中定义了一个class，或者定义个一个匿名内部类，这时通过visitInnerClass方法能够得到例如`com/hebaibai/example/demo/Aoo$1`或者`com/hebaibai/example/demo/Aoo$1XX`的类名称。这时通过使用
>
> ```javascript
> ClassReader classReader = new ClassReader("com/hebaibai/example/demo/Aoo$1");
>  classReader.accept(new DemoClassVisitor(Opcodes.ASM7), ClassReader.SKIP_CODE);
> ```
>
> 复制
>
> 可以得到持有内部类的类信息。
>
> owner：拥有该类的class名称
>
> name：包含该类的方法的名称，如果该类未包含在其封闭类的方法中，则返回null
>
> descriptor：描述

ClassVisitor是一个抽象类，我们可以通过继承它来实现自己的ClassVisitor（MethodVistitor/FieldVisitor同)。我们可以插入一段逻辑来获取我们要访问的类的信息，也可以通过改变方法的返回值来修改类的信息。

当然我们也可以直接通过ClassWriter来生成一个类，手动调用它的各种visit方法来向生成的类来写入字节码，下面我们先简简单单写个HelloWorld。

```kotlin
fun main() {
    val classWriter = ClassWriter(0)
    classWriter.visit(
        V1_8,
        ACC_PUBLIC + ACC_SUPER,
        "org/example/asmlearn/ASMLearn_Test",
        null,
        "java/lang/Object",
        null
    )
    val mv = classWriter.visitMethod(
        ACC_PUBLIC + ACC_STATIC,
        "main",
        "([Ljava/lang/String;)V",
        null,
        null
    )
    mv.visitFieldInsn(GETSTATIC, "java/lang/System", "out", "Ljava/io/PrintStream;")
    mv.visitLdcInsn("Hello, World!")
    mv.visitMethodInsn(INVOKEVIRTUAL, "java/io/PrintStream", "println", "(Ljava/lang/String;)V", false)
    mv.visitInsn(RETURN)
    mv.visitMaxs(2, 1)
    mv.visitEnd()
    classWriter.visitEnd()
    val byteArray = classWriter.toByteArray()
    val classLoader = MyClassLoader()
    val clazz = classLoader.defineClass("org.example.asmlearn.ASMLearn_Test", byteArray)
    val m = clazz.getMethod("main", Array<String>::class.java)
    m.invoke(null, arrayOf(""))
}

class MyClassLoader : ClassLoader() {
    fun defineClass(name: String, b: ByteArray): Class<*> {
        return defineClass(name, b, 0, b.size)
    }
}
```

这里我们通过asm生成了一个`org/example/asmlearn/ASMLearn_Test`类，并在里面生成了一个main方法，加载到自定义的classLoader中，然后对它进行反射执行main方法。

>  顺便说下生成代码的事情，编译期生成常规代码其实不推荐使用asm，我们一般只在运行期动态生成代码才使用asm。因为asm写起来比较繁琐，运行期用它来生成代码其实是因为没有更好的办法了。编译期如果不是你想实现什么魔法的话一般不用来生成代码，生成代码可以了解一下kapt和ksp，编译期asm一般只是用来在已有的代码中进行插桩。

##### Tree API

Tree API基于Core API实现，Tree API让我们不用再自定义Visitor，我们可以直接获取一个类的ClassNode，然后通过ClassNode直接获得里面所有的方法/字段信息。

那么我们要如何得到一个ClassNode呢？

~~~kotlin
fun getClassNode(clazzFile: File): ClassNode {
    val classReader = ClassReader(clazzFile.inputStream())
    val classNode = ClassWriter(ASM9)
    classReader.accept(classNode, 0)
    return classNode
}
~~~

我们可以发现，其实ClassNode就是一个封装过的ClassVisitor。它重写了ClassVisitor所有的访问方法，在访问时把访问到的信息存到类中，然后我们就可以直接从里面获取。***有兴趣可以自己实现一下ClassNode，非常简单。***

~~~kotlin
val classNode = getClassNode(clazzFile)
// 获取所有方法信息
val methods: List<MethodNode> = classNode.methods
// 获取所有字段信息
val fields: List<FieldNode> = classNode.fields
~~~

#### 实战

接下来我会讲解一些asm框架的实战用例，大家有兴趣回去可以跟着敲一敲，都不难。

推荐的参考资料[Java ASM详解：MethodVisitor和Opcode（二）类型、数组、字段、方法、异常与同步 - 哔哩哔哩 (bilibili.com)](https://www.bilibili.com/read/cv13433468)

写的时候跟字节码和这个资料对照着看。

##### ApiJarGenerator

> 写这个实战的时候我还只知道Core API，所以以下功能均使用Core API实现

> 我们知道，Java的类文件都是可以反编译的，同时如果要依赖于某个Jar进行开发就必须要有Jar文件。
>
> 设想一种情况，我们开发项目人手不够，去找了外包。同时我们有一份自主开发的框架/类库，但我们不希望这份库的Jar文件落入外包者之手，但项目开发必须要依赖这份Jar文件，否则就通不过编译，怎么办呢？
>
> 了解了asm框架与JVM字节码结构后我们很容易就能想出一个解决方案，删空Jar文件中所有方法的字节码指令，只留下可供调用的方法声明。这样外包者就无法通过反编译得知方法的具体逻辑，但外包者仍然能调用其中的公开方法，并且项目也能通过编译。

~~~kotlin
/**
 * org.example.asmlearn.ApiJarGenerator
 * asm-learn
 *
 * @author 寒雨
 * @since 2022/7/11 14:22
 */
fun generate(sourceJar: File, output: File) {
    if (!output.exists()) {
        output.createNewFile()
    }
    JarOutputStream(output.outputStream()).use { out ->
        JarFile(sourceJar).use { jarFile ->
            for (jarEntry in jarFile.entries()) {
                jarFile.getInputStream(jarEntry).use { input ->
                    if (jarEntry.name.endsWith(".class")) {
                        // 如果是class文件，就用我们自定义的ClassVisitor visit它
                        val classReader = ClassReader(input)
                        val classWriter = ClassWriter(0)
                        val visitor = EmptyClassVisitor(classWriter)
                        classReader.accept(visitor, 0)
                        out.putNextEntry(JarEntry(jarEntry.name))
                        // 写入class文件
                        out.write(classWriter.toByteArray())
                    } else {
                        out.putNextEntry(JarEntry(jarEntry.name))
                        input.copyTo(out)
                    }
                }
            }
        }
    }
}

class EmptyClassVisitor(visitor: ClassVisitor) : ClassVisitor(ASM9, visitor) {
    override fun visitMethod(
        access: Int,
        name: String?,
        descriptor: String?,
        signature: String?,
        exceptions: Array<out String>?
    ): MethodVisitor {
        return EmptyMethodVisitor(super.visitMethod(access, name, descriptor, signature, exceptions))
    }
}

class EmptyMethodVisitor(methodVisitor: MethodVisitor) : MethodVisitor(ASM9, methodVisitor) {
    override fun visitIincInsn(`var`: Int, increment: Int) {
    }

    override fun visitInsn(opcode: Int) {
    }

    override fun visitIntInsn(opcode: Int, operand: Int) {
    }

    override fun visitVarInsn(opcode: Int, `var`: Int) {
    }

    override fun visitTypeInsn(opcode: Int, type: String?) {
    }

    override fun visitJumpInsn(opcode: Int, label: Label?) {
    }

    override fun visitLabel(label: Label?) {
    }

    override fun visitLdcInsn(value: Any?) {
    }

    override fun visitTableSwitchInsn(min: Int, max: Int, dflt: Label?, vararg labels: Label?) {
    }

    override fun visitLookupSwitchInsn(dflt: Label?, keys: IntArray?, labels: Array<out Label>?) {
    }

    override fun visitMultiANewArrayInsn(descriptor: String?, numDimensions: Int) {
    }

    override fun visitTryCatchBlock(start: Label?, end: Label?, handler: Label?, type: String?) {
    }

    override fun visitLocalVariable(name: String?, descriptor: String?, signature: String?, start: Label?, end: Label?, index: Int) {
    }

    override fun visitLineNumber(line: Int, start: Label?) {
    }

    override fun visitFrame(type: Int, numLocal: Int, local: Array<out Any>?, numStack: Int, stack: Array<out Any>?) {
    }

    override fun visitFieldInsn(opcode: Int, owner: String?, name: String?, descriptor: String?) {
    }

    override fun visitMethodInsn(opcode: Int, owner: String?, name: String?, descriptor: String?) {
    }

    override fun visitMethodInsn(opcode: Int, owner: String?, name: String?, descriptor: String?, isInterface: Boolean) {
    }

    override fun visitInvokeDynamicInsn(name: String?, descriptor: String?, bootstrapMethodHandle: Handle?, vararg bootstrapMethodArguments: Any?) {
    }
}

fun main() {
    generate(
        File("C:\\Users\\Rain\\Desktop\\recaf-2.21.13-J8-jar-with-dependencies.jar"), 		                         File("C:\\Users\\Rain\\Desktop\\recaf-empty.jar")
    )
}
~~~

上面我们让EmptyClassVisitor在visitMethod返回了一个我们自定义的EmptyMethodVisitor，也就是说在访问方法时执行的是在EmptyMethodVisitor中我们自定义的逻辑。而在EmptyMethodVisitor中我们重写了所有方法，把原本的执行父类方法的逻辑删除。这样在访问时便不会想原本一样生成跟之前一样的字节码，而是什么都不做，这样就删掉了方法中方法体的字节码。

##### ASMVersionControl

> 这是在Minecraft服务端插件开发经常中遇见的问题
>
> 众所周知，目前主流的minecraft服务端都是第三方反编译官方服务端的代码后对其进行封装而来的，而作为服务端插件开发者，我们大部分时候只需要用到第三方封装的API，但也有例外。
>
> 当我们需要调用官方服务端的代码，我们会发现一个问题：不同版本的服务端的官方服务端代码的包名不一样，它们被版本号分隔开来。
>
> 比如，在Minecraft 1.16.5版本的官方代码中，所有类都在`net.minecraft.server.v1_16_R3`包下
>
> 但在Minecraft 1.12.2版本的代码中，所有类都在`net.minecraft.server.v1_12_R1`包下
>
> 关键是它们之间的代码其实没有很大的改动，就是包名不一样了
>
> 考虑到版本兼容问题，开发者一般不会直接调用`n.m.s`包下的代码，在ASMVersionControl这个解决方案诞生之前，一般有两种解决方案
>
> - 运行时获取版本号，然后拼接字符串通过反射调用
> - 为不同版本写多份代码，再在运行时判断当前运行版本来决定调用哪一份
>
> 这两种解决方案都不太尽人意。反射调用不仅麻烦，还会导致额外的性能开销。而编写多份代码更是白白增加了开发者的工作量，而且需要导入多个版本的服务端核心依赖，导包的时候及其容易导错。
>
> 这时候`ASMVersionControl`应运而生，开发者只需要在一个实现类中写一份代码，便可以通过ASM动态代理得到一个实例。开发者可以放心调用实例中的方法，因为这个实例已经被asm修改过了，所有`n.m.s`调用的包名的版本号部分全部被修改为了运行环境的版本号。

这部分逻辑其实ASM已经提供了一个现成的工具`ClassRemapper`来实现，但它本质上也是一个被封装过的`ClassVisitor`，为了方便理解，我们使用ClassVisitor实现。

如果你想知道使用ClassRemapper如何实现，看这里[taboolib/MinecraftRemapper.kt at master · TabooLib/taboolib (github.com)](https://github.com/TabooLib/taboolib/blob/master/module/module-nms/src/main/kotlin/taboolib/module/nms/MinecraftRemapper.kt)

或者你也可以试着自己实现一下ClassRemapper的封装，比较简单。

我们先模拟两个“不同版本”下的类，也就是包名不同，但方法声明相同，实现略有不同的两个类。

~~~java
// net.minecraft.server.v1_12_R1
public class Test {
    public void test() {
        System.out.println("execute successfully v1.12");
    }
}
// net.minecraft.server.v1_16_R3
public class Test {
    public void test() {
        System.out.println("execute successfully v1.16");
    }
}
~~~

理想的状态是，我要让我调用`net.minecraft.server.v1_12_R1`的所有方法全部变成`net.minecraft.server.v1_16_R3`。

我们先写一段伪代码

~~~kotlin
import net.minecraft.server.v1_12_R1.Test

interface NMSHandler {
    fun callTest()
}

class NMSHandlerImpl : NMSHandler {
    override fun callTest() {
        Test().test()
    }
}

fun main() {
    // 获得asm修改过的代理对象
    val nmsProxy: NMSHandler = createProxyInstance<NMSHandler>()
    nmsProxy.callTest() // 这里输出 execute successfully v1.16, 说明我们修改成功了
}
~~~

我们先看看`NMSHandlerImpl#callTest`的字节码指令

>    L0
>     LINENUMBER 85 L0
>     NEW net/minecraft/server/v1_12_R1/Test
>     DUP
>     INVOKESPECIAL net/minecraft/server/v1_12_R1/Test.<init> ()V
>     INVOKEVIRTUAL net/minecraft/server/v1_12_R1/Test.test ()V
>    L1
>     LINENUMBER 86 L1
>     RETURN
>    L2
>     LOCALVARIABLE this Lorg/example/asmlearn/NMSHandlerImpl; L0 L2 0
>     MAXSTACK = 2
>     MAXLOCALS = 1

我们只需要修改其中所有的 `net/minecraft/server/v1_12_R1/Test`为`net/minecraft/server/v1_16_R3/Test`即可，目前为止我们知道我们肯定首先要先visitMethod，然后在具体的操作方法。

> 需要修改的指令：
>
> - NEW net/minecraft/server/v1_12_R1/Test
>
> - INVOKESPECIAL net/minecraft/server/v1_12_R1/Test.<init> ()V
>
> - INVOKEVIRTUAL net/minecraft/server/v1_12_R1/Test.test ()V

在[Java ASM详解：MethodVisitor和Opcode（二）类型、数组、字段、方法、异常与同步 - 哔哩哔哩 (bilibili.com)](https://www.bilibili.com/read/cv13433468)对照

发现我们只需要重写`visitTypeInsn`, `visitMethodInsn`，并在里面替换对应的参数即可。

~~~kotlin
class VersionControlMethodVisitor(methodVisitor: MethodVisitor, private val currentVersion: String) : MethodVisitor(ASM9, methodVisitor) {
    override fun visitTypeInsn(opcode: Int, type: String) {
        super.visitTypeInsn(opcode, type.modifyVersion(currentVersion))
    }

    override fun visitMethodInsn(
        opcode: Int,
        owner: String,
        name: String,
        descriptor: String,
        isInterface: Boolean
    ) {
        super.visitMethodInsn(opcode, owner.modifyVersion(currentVersion), name, descriptor, isInterface)
    }
}
~~~

完整代码如下:

~~~kotlin
import net.minecraft.server.v1_12_R1.Test

class VersionControlClassVisitor(classVisitor: ClassVisitor, val currentVersion: String) : ClassVisitor(ASM9, classVisitor) {
    override fun visitField(
        access: Int,
        name: String?,
        descriptor: String?,
        signature: String?,
        value: Any?
    ): FieldVisitor {
        return VersionControlFieldVisitor(super.visitField(access, name, descriptor, signature, value), currentVersion)
    }

    override fun visitMethod(
        access: Int,
        name: String?,
        descriptor: String?,
        signature: String?,
        exceptions: Array<out String>?
    ): MethodVisitor {
        return VersionControlMethodVisitor(super.visitMethod(access, name, descriptor, signature, exceptions), currentVersion)
    }
}

class VersionControlMethodVisitor(methodVisitor: MethodVisitor, private val currentVersion: String) : MethodVisitor(ASM9, methodVisitor) {
    override fun visitTypeInsn(opcode: Int, type: String) {
        super.visitTypeInsn(opcode, type.modifyVersion(currentVersion))
    }

    override fun visitMethodInsn(
        opcode: Int,
        owner: String,
        name: String,
        descriptor: String,
        isInterface: Boolean
    ) {
        super.visitMethodInsn(opcode, owner.modifyVersion(currentVersion), name, descriptor, isInterface)
    }
}

class VersionControlFieldVisitor(fieldVisitor: FieldVisitor, val currentVersion: String) : FieldVisitor(ASM9, fieldVisitor) {

}

val nms = "net/minecraft/server/v1_.*?/".toRegex()
val obc = "org/bukkit/craftbukkit/v1_.*?/".toRegex()

fun String.modifyVersion(version: String): String {
    return this.replace(nms, "net/minecraft/server/$version/")
        .replace(obc, "org/bukkit/craftbukkit/$version/")
}

@Suppress("UNCHECKED_CAST")
inline fun <reified T> createProxyClass(impl: String = T::class.java.name + "Impl"): Class<T> {
    val input = VersionControlClassVisitor::class.java.classLoader.getResourceAsStream(impl.replace(".", "/") + ".class")
    val classReader = ClassReader(input)
    val classWriter = ClassWriter(ClassWriter.COMPUTE_MAXS)
    classReader.accept(VersionControlClassVisitor(classWriter, "v1_16_R3"), 0)
    return MyClassLoader.defineClass(impl, classWriter.toByteArray()) as Class<T>
}

inline fun <reified T> createProxyInstance(impl: String = T::class.java.name + "Impl"): T {
    return createProxyClass<T>(impl).getDeclaredConstructor().newInstance()
}

interface NMSHandler {
    fun callTest()
}

class NMSHandlerImpl : NMSHandler {
    override fun callTest() {
        Test().test()
    }
}

fun main() {
    val proxy = createProxyInstance<NMSHandler>()
    proxy.callTest()
}
~~~

上面这段代码的运行结果是`execute successfully v1.16`,证明我们成功替换了代理类中的包名。

其实gradle插件shadowJar重定向(relocate)包名的功能的实现也大同小异，大家有兴趣可以课下自己去实现一下。

##### 字节码插桩

前面几个其实并不是我们安卓开发经常遇到的问题，只是它们解决起来相对简单。安卓开发中asm框架主要是用来字节码插桩的。

字节码插桩其实是hook的一种。

这个我们就不自己写了，我们分析一下大佬写的案例——用字节码插桩实现双击防抖。

先贴下源码链接: [leavesCZY/ASM_Transform: ASM Transform 字节码插桩实战 (github.com)](https://github.com/leavesCZY/ASM_Transform)

谷歌为android量身定制了安卓字节码插桩的解决方案`transform api`来配合gradle使用，***不过它现在已经即将废弃了，最新的解决方案是Gradle提供的TransformAction***，不过这里我们要看的源码仍然是使用transform api来实现字节码插桩，不过问题不大。

###### gradle插件编写

> 字节码插桩一般都是通过自定义gradle插件干预编译实现的
>
> 准确来说是在编译后再对编译产物处理一遍

首先我们新建一个`buildSrc`模块，`buildSrc`模块中的代码可以在其他模块的build.gradle中直接引入使用。

然后创建一个插件类

~~~kotlin
/**
 * @Author: leavesCZY
 * @Date: 2021/12/2 16:02
 * @Desc:
 */
class DoubleClickPlugin : Plugin<Project> {

    override fun apply(project: Project) {
        val config = DoubleClickConfig()
        val appExtension: AppExtension = project.extensions.getByType()
        appExtension.registerTransform(DoubleClickTransform(config))
    }

}
~~~

其中apply是在你导入这个插件时执行的逻辑，我们在apply方法中注册了我们写的Transform，在编译时便会执行Transform的对应逻辑。

然后我们只需要在需要使用这个插件的模块导入并apply就可以了

~~~groovy
import github.leavesczy.asm.plugins.doubleClick.DoubleClickPlugin

apply plugin: DoubleClickPlugin
~~~

###### transform逻辑

我们先来看看`DoubleClickTransform`中的内容

~~~kotlin
class DoubleClickTransform(private val config: DoubleClickConfig) : BaseTransform() {

    private companion object {

        private const val ViewDescriptor = "Landroid/view/View;"

        private const val OnClickViewMethodDescriptor = "(Landroid/view/View;)V"

        private const val ButterKnifeOnClickAnnotationDesc = "Lbutterknife/OnClick;"

        private val MethodNode.onlyOneViewParameter: Boolean
            get() = desc == OnClickViewMethodDescriptor

        private fun MethodNode.hasCheckViewAnnotation(config: DoubleClickConfig): Boolean {
            return hasAnnotation(config.formatCheckViewOnClickAnnotation)
        }

        private fun MethodNode.hasUncheckViewOnClickAnnotation(config: DoubleClickConfig): Boolean {
            return hasAnnotation(config.formatUncheckViewOnClickAnnotation)
        }

        private fun MethodNode.hasButterKnifeOnClickAnnotation(): Boolean {
            return hasAnnotation(ButterKnifeOnClickAnnotationDesc)
        }

    }

    override fun modifyClass(byteArray: ByteArray): ByteArray {
        val classReader = ClassReader(byteArray)
        val classNode = ClassNode()
        classReader.accept(classNode, ClassReader.EXPAND_FRAMES)
        val methods = classNode.methods
        if (!methods.isNullOrEmpty()) {
            val shouldHookMethodList = mutableSetOf<String>()
            for (methodNode in methods) {
                //静态、包含 UncheckViewOnClick 注解的方法不用处理
                if (methodNode.isStatic ||
                    methodNode.hasUncheckViewOnClickAnnotation(config)
                ) {
                    continue
                }
                val methodNameWithDesc = methodNode.nameWithDesc
                if (methodNode.onlyOneViewParameter) {
                    if (methodNode.hasCheckViewAnnotation(config)) {
                        //添加了 CheckViewOnClick 注解的情况
                        shouldHookMethodList.add(methodNameWithDesc)
                        continue
                    } else if (methodNode.hasButterKnifeOnClickAnnotation()) {
                        //使用了 ButterKnife，且当前 method 添加了 OnClick 注解
                        shouldHookMethodList.add(methodNameWithDesc)
                        continue
                    }
                }
                if (classNode.isHookPoint(config, methodNode)) {
                    shouldHookMethodList.add(methodNameWithDesc)
                    continue
                }
                //判断方法内部是否有需要处理的 lambda 表达式
                val invokeDynamicInsnNodes = methodNode.findHookPointLambda(config)
                invokeDynamicInsnNodes.forEach {
                    val handle = it.bsmArgs[1] as? Handle
                    if (handle != null) {
                        shouldHookMethodList.add(handle.name + handle.desc)
                    }
                }
            }
            if (shouldHookMethodList.isNotEmpty()) {
                for (methodNode in methods) {
                    val methodNameWithDesc = methodNode.nameWithDesc
                    if (shouldHookMethodList.contains(methodNameWithDesc)) {
                        val argumentTypes = Type.getArgumentTypes(methodNode.desc)
                        val viewArgumentIndex = argumentTypes?.indexOfFirst {
                            it.descriptor == ViewDescriptor
                        } ?: -1
                        if (viewArgumentIndex >= 0) {
                            val instructions = methodNode.instructions
                            if (instructions != null && instructions.size() > 0) {
                                val list = InsnList()
                                list.add(
                                    VarInsnNode(
                                        Opcodes.ALOAD, getVisitPosition(
                                            argumentTypes,
                                            viewArgumentIndex,
                                            methodNode.isStatic
                                        )
                                    )
                                )
                                list.add(
                                    MethodInsnNode(
                                        Opcodes.INVOKESTATIC,
                                        config.formatDoubleCheckClass,
                                        config.doubleCheckMethodName,
                                        config.doubleCheckMethodDescriptor
                                    )
                                )
                                val labelNode = LabelNode()
                                list.add(JumpInsnNode(Opcodes.IFNE, labelNode))
                                list.add(InsnNode(Opcodes.RETURN))
                                list.add(labelNode)
                                instructions.insert(list)
                            }
                        }
                    }
                }
                val classWriter = ClassWriter(ClassWriter.COMPUTE_MAXS)
                classNode.accept(classWriter)
                return classWriter.toByteArray()
            }
        }
        return byteArray
    }

    private fun ClassNode.isHookPoint(config: DoubleClickConfig, methodNode: MethodNode): Boolean {
        val myInterfaces = interfaces
        if (myInterfaces.isNullOrEmpty()) {
            return false
        }
        val extraHookMethodList = config.hookPointList
        extraHookMethodList.forEach {
            if (myInterfaces.contains(it.interfaceName) && methodNode.nameWithDesc == it.methodSign) {
                return true
            }
        }
        return false
    }

    private fun MethodNode.findHookPointLambda(config: DoubleClickConfig): List<InvokeDynamicInsnNode> {
        val onClickListenerLambda = findLambda {
            val nodeName = it.name
            val nodeDesc = it.desc
            val find = config.hookPointList.find { point ->
                nodeName == point.methodName && nodeDesc.endsWith(point.interfaceSignSuffix)
            }
            return@findLambda find != null
        }
        return onClickListenerLambda
    }

    override fun getInputTypes(): Set<QualifiedContent.ContentType> {
        return TransformManager.CONTENT_CLASS
    }

    override fun getScopes(): MutableSet<in QualifiedContent.Scope> {
        return mutableSetOf(
            QualifiedContent.Scope.PROJECT,
            QualifiedContent.Scope.SUB_PROJECTS,
//            QualifiedContent.Scope.EXTERNAL_LIBRARIES
        )
    }

}
~~~

他自己封装了一个`BaseTransform`，把修改class的过程封装成了一个`modifierClass(byteArray: ByteArray): ByteArray`方法，让我们能更专注于修改类信息的过程。至于他是怎么封装的也可以课下了解，这里我们着重讲他如何使用asm。

我们首先分析他的逻辑，无外乎两点：

- 找到hook点（ButterKnife的onClick注解，View#setOnClickListener）
- 在hook点插入逻辑代码

> 这里自由发挥吧，随便讲点就差不多了。

## 虚拟机类加载机制

![13202633-3cb11d1712a9efc9](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/13202633-3cb11d1712a9efc9.webp)

### 类的生命周期

#### 加载 Loading

> 虚拟机从io流读取类文件到内存中。
>
> 加载过程主要完成三件事情：
>
> 1. 通过类的全限定名来获取定义此类的二进制字节流
> 2. 将这个类字节流代表的静态存储结构转为方法区的运行时数据结构
> 3. 在堆中生成一个代表此类的java.lang.Class对象，作为访问方法区这些数据结构的入口。
>
> 这个过程主要就是类加载器完成。

#### 验证 Verification

> 此阶段主要确保Class文件的字节流中包含的信息符合当前虚拟机的要求，并且不会危害虚拟机的自身安全。
>
> 1. 文件格式验证：基于字节流验证。
> 2. 元数据验证：基于***方法区***的存储结构验证。
> 3. 字节码验证：基于方法区的存储结构验证。
> 4. 符号引用验证：基于方法区的存储结构验证。

#### 准备 Preparation

> 为类变量分配内存，并将其初始化为默认值。（此时为默认值，在初始化的时候才会给变量赋值）即在方法区中分配这些变量所使用的内存空间

例如

~~~java
public class Main {
    public static int value = 12345;
}
~~~

虽说value在代码中被初始化为5，但这时value的值仍然为0，变量要在初始化阶段才会被赋初值（如果有）。

#### 解析 Resolution

> 把类型中的符号引用转换为直接引用。
>
> - 符号引用与虚拟机实现的布局无关，引用的目标并不一定要已经加载到内存中。各种虚拟机实现的内存布局可以各不相同，但是它们能接受的符号引用必须是一致的，因为符号引用的字面量形式明确定义在Java虚拟机规范的Class文件格式中。
> - 直接引用可以是指向目标的指针，相对偏移量或是一个能间接定位到目标的句柄。如果有了直接引用，那引用的目标必定已经在内存中存在
>
> 主要有以下四种：
>
> - 类或接口的解析
> - 字段解析
>
> - 类方法解析
>
> - 接口方法解析

#### 初始化 Initialization

> 初始化阶段是执行类构造器<client>方法的过程。<client>方法是由编译器自动收集类中的类变量的赋值操作和静态语句块中的语句合并而成的。虚拟机会保证<client>方法执行之前，父类的<client>方法已经执行完毕。如果一个类中没有对静态变量赋值也没有静态语句块，那么编译器可以不为这个类生成<client>()方法。
>
> java中，对于初始化阶段，有且只有以下五种情况才会对要求类立刻“初始化”（加载，验证，准备，自然需要在此之前开始）：
>
> - 使用new关键字实例化对象、访问或者设置一个类的静态字段（被final修饰、编译器优化时已经放入常量池的例外）、调用类方法，都会初始化该静态字段或者静态方法所在的类。
>
> - 初始化类的时候，如果其父类没有被初始化过，则要先触发其父类初始化。
>
> - 使用java.lang.reflect包的方法进行反射调用的时候，如果类没有被初始化，则要先初始化。
>
> - 虚拟机启动时，用户会先初始化要执行的主类（含有main）
>
> - jdk 1.7后，如果java.lang.invoke.MethodHandle的实例最后对应的解析结果是 REF_getStatic、REF_putStatic、REF_invokeStatic方法句柄，并且这个方法所在类没有初始化，则先初始化。

#### 卸载 Unloading

> 在栈中不存在该类的实例与Class对象，且加载该类的classLoader失去gc roots时，换言之该类已经失去了gc roots，被gc回收，此时可以称作该类成功从jvm中卸载了，这条机制也是一些热修复方案的实现原理(其实现在大部分的热修复都是用JavaAgent实现类的热替换）。

### 类加载器 (ClassLoader)

#### 各司其职

JVM 运行实例中会存在多个 ClassLoader，不同的 ClassLoader 会从不同的地方加载字节码文件。它可以从不同的文件目录加载，也可以从不同的 jar 文件中加载，也可以从网络上不同的服务地址来加载。

JVM 中内置了三个重要的 ClassLoader，分别是 BootstrapClassLoader、ExtensionClassLoader 和 AppClassLoader。

BootstrapClassLoader 负责加载 JVM 运行时核心类，这些类位于 JAVA_HOME/lib/rt.jar 文件中，我们常用内置库 java.xxx.* 都在里面，比如 java.util.*、java.io.*、java.nio.*、java.lang.* 等等。这个 ClassLoader 比较特殊，它是由 C 代码实现的，我们将它称之为「根加载器」。

ExtensionClassLoader 负责加载 JVM 扩展类，比如 swing 系列、内置的 js 引擎、xml 解析器 等等，这些库名通常以 javax 开头，它们的 jar 包位于 JAVA_HOME/lib/ext/*.jar 中，有很多 jar 包。

AppClassLoader 才是直接面向我们用户的加载器，它会加载 Classpath 环境变量里定义的路径中的 jar 包和目录。我们自己编写的代码以及使用的第三方 jar 包通常都是由它来加载的。

那些位于网络上静态文件服务器提供的 jar 包和 class文件，jdk 内置了一个 URLClassLoader，用户只需要传递规范的网络路径给构造器，就可以使用 URLClassLoader 来加载远程类库了。URLClassLoader 不但可以加载远程类库，还可以加载本地路径的类库，取决于构造器中不同的地址形式。ExtensionClassLoader 和 AppClassLoader 都是 URLClassLoader 的子类，它们都是从本地文件系统里加载类库。

AppClassLoader 可以由 ClassLoader 类提供的静态方法 getSystemClassLoader() 得到，它就是我们所说的「系统类加载器」，我们用户平时编写的类代码通常都是由它加载的。当我们的 main 方法执行的时候，这第一个用户类的加载器就是 AppClassLoader。

#### ClassLoader 传递性

程序在运行过程中，遇到了一个未知的类，它会选择哪个 ClassLoader 来加载它呢？虚拟机的策略是使用调用者 Class 对象的 ClassLoader 来加载当前未知的类。何为调用者 Class 对象？就是在遇到这个未知的类时，虚拟机肯定正在运行一个方法调用（静态方法或者实例方法），这个方法挂在哪个类上面，那这个类就是调用者 Class 对象。前面我们提到每个 Class 对象里面都有一个 classLoader 属性记录了当前的类是由谁来加载的。

因为 ClassLoader 的传递性，所有延迟加载的类都会由初始调用 main 方法的这个 ClassLoader 全全负责，它就是 AppClassLoader。

#### 双亲委派

双亲委派模型的工作过程为：如果一个类加载器收到了类加载的请求，它首先不会自己去尝试加载这个类，而是把这个请求委派给父类加载器去完成，每一个层次的加载器都是如此，因此所有的类加载请求都会传给顶层的启动类加载器，只有当父加载器反馈自己无法完成该加载请求（该加载器的搜索范围中没有找到对应的类）时，子加载器才会尝试自己去加载。

使用双亲委派模型的好处在于**Java类随着它的类加载器一起具备了一种带有优先级的层次关系**。例如类java.lang.Object，它存在在rt.jar中，无论哪一个类加载器要加载这个类，最终都是委派给处于模型最顶端的Bootstrap ClassLoader进行加载，因此Object类在程序的各种类加载器环境中都是同一个类。相反，如果没有双亲委派模型而是由各个类加载器自行加载的话，如果用户编写了一个java.lang.Object的同名类并放在ClassPath中，那系统中将会出现多个不同的Object类，程序将混乱。因此，如果开发者尝试编写一个与rt.jar类库中重名的Java类，可以正常编译，但是永远无法被加载运行。

![类加载器的双亲委派模型](https://img-blog.csdn.net/20160506184936657)

**双亲委派模型的系统实现**

在java.lang.ClassLoader的loadClass()方法中，先检查是否已经被加载过，若没有加载则调用父类加载器的loadClass()方法，若父加载器为空则默认使用启动类加载器作为父加载器。如果父加载失败，则抛出ClassNotFoundException异常后，再调用自己的findClass()方法进行加载。

```java
protected synchronized Class<?> loadClass(String name,boolean resolve)throws ClassNotFoundException{
    //check the class has been loaded or not
    Class c = findLoadedClass(name);
    if(c == null){
        try{
            if(parent != null){
                c = parent.loadClass(name,false);
            }else{
                c = findBootstrapClassOrNull(name);
            }
        }catch(ClassNotFoundException e){
            //if throws the exception ,the father can not complete the load
        }
        if(c == null){
            c = findClass(name);
        }
    }
    
    if(resolve){
        resolveClass(c);
    }
    return c;
}
```

注意，双亲委派模型是Java设计者推荐给开发者的类加载器的实现方式，并不是强制规定的。大多数的类加载器都遵循这个模型，但是JDK中也有较大规模破坏双亲模型的情况，例如线程上下文类加载器（Thread Context ClassLoader）的出现，具体分析可以参见《深入理解Java虚拟机》。

## Hook

### 什么是Hook

hook我认为更像是一种思想，而非一门单独的技术，其实就是通过一些旁门左道去通过代理修改别人的代码来达成一些意想不到的功能。而通过这些旁门左道其实是没办法随心所欲的修改代码的，所以我们需要从某些地方入手，这些地方被称作**hook点**。

### 怎么实现Hook

![img](https://pic2.zhimg.com/80/v2-58f3800446ebb35fa8f38de1449a6af5_1440w.jpg)

那我就讲讲最基础的反射/动态代理Hook吧。

假如我们导入的外部库的网络请求部分有这么一段代码:

~~~kotlin
object ServiceHolder {
    val apiService: IWebServiceRepository = WebServiceRepository()
    // ...
}

// WebServiceRepository
class WebServiceRepository : IWebServiceRepository {
    private val BASE_URL = "https://api.bifrost.kim"
    
    override fun getJsonData(): Data {
        // ...
    }
}
~~~

然而它的接口改了，我们需要修改一下请求的方式

最简单的方法就是我们直接动态代理apiService，然后反射放进去。

但InvocationHandler提供的动态代理也许不是很方便，只能在头部或者尾部插入逻辑。即便我们只需要修改部分字符串，就得重写整个网络请求方法的逻辑。

那么更好的方法是什么呢，正是字节码插桩，我们使用字节码生成一个一样的类，再用asm稍微的修改这其中的部分逻辑即可。

### 利用LSposed实现全局Hook (有时间再研究)

> 有时间再说吧 我没研究（
