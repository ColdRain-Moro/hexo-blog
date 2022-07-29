---
title: 了解了一下Kotlin的协程
date: 2021-08-15 00:13:31
author: 寒雨
hide: false
summary: 简单的了解了一下协程，写了篇比较浅薄的协程笔记
categories: 笔记
tags:
  - Kotlin
  - Coroutine
---

# 了解了一下Kotlin的协程

确实非常舒服，个人感觉比CompletableFuture方便

所以我想把今天学到的协程相关的知识都记录下来

## 协程是什么？能做什么? 跟多线程有什么不一样?

### 摘自简书

[原地址](https://www.jianshu.com/p/76d2f47b900d)

> **[协程](https://coldrain-moro.github.io/content.html?id=8)** - 也叫微线程，是一种新的多任务并发的操作手段(也不是很新，概念早就有了)

> - 特征：协程是运行在单线程中的并发程序
> - 优点：省去了传统 Thread 多线程并发机制中切换线程时带来的线程上下文切换、线程状态切> > 换、Thread 初始化上的性能损耗，能大幅度唐提高并发性能
> - 漫画版概念解释：[漫画：什么是协程？](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.sohu.com%2Fa%2F236536167_684445)
> - 简单理解：在单线程上由程序员自己调度运行的并行计算

> 下面是关于协程这个概念的一些描述：

> > 协程的开发人员 Roman Elizarov 是这样描述协程的：协程就像非常轻量级的线程。线程是由系统调度的，线程切换或线程阻塞的开销都比较大。而协程依赖于线程，但是协程挂起时不需要阻塞线程，几乎是无代价的，协程是由开发者控制的。所以协程也像用户态的线程，非常轻量级，一个线程中可以创建任意个协程。

> > Coroutine，翻译成”协程“，初始碰到的人马上就会跟进程和线程两个概念联系起来。直接先说区别，Coroutine是编译器级的，Process和Thread是操作系统级的。Coroutine的实现，通常是对某个语言做相应的提议，然后通过后成编译器标准，然后编译器厂商来实现该机制。Process和Thread看起来也在语言层次，但是内生原理却是操作系统先有这个东西，然后通过一定的API暴露给用户使用，两者在这里有不同。Process和Thread是os通过调度算法，保存当前的上下文，然后从上次暂停的地方再次开始计算，重新开始的地方不可预期，每次CPU计算的指令数量和代码跑过的CPU时间是相关的，跑到os分配的cpu时间到达后就会被os强制挂起。Coroutine是编译器的魔术，通过插入相关的代码使得代码段能够实现分段式的执行，重新开始的地方是yield关键字指定的，一次一定会跑到一个yield对应的地方

> > 对于多线程应用，CPU通过切片的方式来切换线程间的执行，线程切换时需要耗时（保存状态，下次继续）。协程，则只使用一个线程，在一个线程中规定某个代码块执行顺序。协程能保留上一次调用时的状态，不需要像线程一样用回调函数，所以性能上会有提升。缺点是本质是个单线程，不能利用到单个CPU的多个核

> **[协程和线程的对比：](https://coldrain-moro.github.io/content.html?id=8)**

> - **[Thread](https://coldrain-moro.github.io/content.html?id=8)** - 线程拥有独立的栈、局部变量，基于进程的共享内存，因此数据共享比较容易，但是多线程时需要加锁来进行访问控制，不加锁就容易导致数据错误，但加锁过多又容易出现死锁。线程之间的调度由内核控制(时间片竞争机制)，程序员无法介入控制(`即便我们拥有sleep、yield这样的API，这些API只是看起来像，但本质还是交给内核去控制，我们最多就是加上几个条件控制罢了`)，线程之间的切换需要深入到内核级别，因此线程的切换代价比较大，表现在：
>   \* 线程对象的创建和初始化
>   \* 线程上下文切换
>   \* 线程状态的切换由系统内核完成
>   \* 对变量的操作需要加锁

[![img](https://coldrain-moro.github.io/content.html?id=8)](https://coldrain-moro.github.io/content.html?id=8)

> - **[Coroutine](https://coldrain-moro.github.io/content.html?id=8)** 协程是跑在线程上的优化产物，被称为轻量级 Thread，拥有自己的栈内存和局部变量，共享成员变量。传统 Thread 执行的核心是一个while(true) 的函数，本质就是一个耗时函数，Coroutine 可以用来直接标记方法，由程序员自己实现切换，调度，不再采用传统的时间段竞争机制。在一个线程上可以同时跑多个协程，同一时间只有一个协程被执行，在单线程上模拟多线程并发，协程何时运行，何时暂停，都是有程序员自己决定的，使用： `yield/resume` API，优势如下：

> - 因为在同一个线程里，协程之间的切换不涉及线程上下文的切换和线程状态的改变，不存在资源、数据并发，所以不用加锁，只需要判断状态就OK，所以执行效率比多线程高很多

> - 协程是非阻塞式的(也有阻塞API)，一个协程在进入阻塞后不会阻塞当前线程，当前线程会去执行其他协程任务

```
![img](https:////upload-images.jianshu.io/upload_images/1785445-57bc06c143e5fcc9.jpeg?imageMogr2/auto-orient/strip|imageView2/2/w/724/format/webp)
```

> 程序员能够控制协程的切换，是通过`yield` API 让协程在空闲时（比如等待io，网络数据未到达）放弃执行权，然后在合适的时机再通过`resume` API 唤醒协程继续运行。协程一旦开始运行就不会结束，直到遇到`yield`交出执行权。`Yield`、`resume` 这一对 API 可以非常便捷的实现`异步`，这可是目前所有高级语法孜孜不倦追求的

> 拿 python 代码举个例子，在一个线程里运行下面2个方法：

> ```
> def A():
> 	print '1'
> 	print '2
> 	print '3'
> ```

> ```
> def B():
>  print 'x'
>  print 'y'
>  print 'z'
> ```

> 假设由协程执行，每个方法都用协程标记，在执行A的过程中，可以随时中断，去执行B，B也可> > 能在执行过程中中断再去执行A，结果可能是：1 2 x y 3 z

### 协程优点之我见

- 协程操作在大多数情况下比多线程操作性能好

- 写起来很爽，配合await你写异步操作就跟写同步操作一样

- 相比于CompletableFuture更厉害的地方在于它可以中断线程，一会儿过后再继续执行，**操作方式更加自由**

- > 协程是非阻塞式的(也有阻塞API)，**一个协程在进入阻塞后不会阻塞当前线程，当前线程会去执行其他协程任务**
  >
  > 这就很舒服了

## Kotlin中协程的使用方法

### 依赖库

kotlin的协程api并不包含在kotlin-stdlib中，跟kotlin的反射api一样，我们需要自行导入依赖

其实最新版本已经迭代到1.5.1了，只是最新版本必须要java16才能兼容，所以用了老版本

```
compileOnly("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.3.3")
```

### 如何创建一个协程

引用: [kotlin - Coroutine 协程 - 简书 (jianshu.com)](https://www.jianshu.com/p/76d2f47b900d)

> kotlin 里没有 new ，自然也不像 JAVA 一样 new Thread，另外 kotlin 里面提供了大量的高阶函数，所以不难猜出协程这里 kotlin 也是有提供专用函数的。kotlin 中 GlobalScope 类提供了几个携程构造函数：

> - [launch](https://coldrain-moro.github.io/content.html?id=8) - 创建协程
> - [async](https://coldrain-moro.github.io/content.html?id=8) - 创建带返回值的协程，返回的是 Deferred 类
> - [withContext ](https://coldrain-moro.github.io/content.html?id=8)- 不创建新的协程，在指定协程上运行代码块
> - [runBlocking](https://coldrain-moro.github.io/content.html?id=8) - 不是 GlobalScope 的 API，可以独立使用，区别是 runBlocking 里面的 delay 会阻塞线程，而 launch 创建的不会

> kotlin 在 1.3 之后要求协程必须由 CoroutineScope 创建，CoroutineScope 不阻塞当前线程，在后台创建一个新协程，也可以指定协程调度器。比如 CoroutineScope.launch{} 可以看成 new Coroutine

#### launch

```kotlin
 GlobalScope.launch {
     println("123")
 }
```

如此便创建了一个最简单的协程，这个协程是在主线程上创建的，换句话说，**是同步的**

> - CoroutineContext

> \- 可以理解为协程的上下文，在这里我们可以设置 CoroutineDispatcher 协程运行的线程调度器，有 4种线程模式：

> - Dispatchers.Default
> - Dispatchers.IO -
> - Dispatchers.Main - 主线程
> - Dispatchers.Unconfined - 没指定，就是在当前线程

> 不写的话就是 Dispatchers.Default 模式的

它有一个返回值Job。**可以把 Job 看成协程对象本身，协程的操作方法都在 Job 身上了**

> job.start() - 启动协程，除了 lazy 模式，协程都不需要手动启动

> job.join() - 等待协程执行完毕

> job.cancel() - 取消一个协程

> job.cancelAndJoin() - 等待协程执行完毕然后再取消

#### async

```kotlin
GlobalScope.async {
    // 在异步线程中创建一个协程
    // 堵塞协程1s （即挂起协程）
    delay(1000L)
    println("123")
 }.invokeOnCompletion {
    // 完成后执行(同步)
    println("456")
}
```

这个方法是在异步线程中创建协程，不同于launch返回Job，async返回的是Deferred类型

Deferred是Job的子类，包含Job的一切方法，除此之外，还新添了一个非常有用的方法 **await**

这个方法用起来非常舒服，多线程操作用这个方法处理就跟处理同步操作一样

例子: (摘自简书)

```kotlin
GlobalScope.launch(Dispatchers.Unconfined) {
  val deferred = GlobalScope.async{
  delay(1000L)
  Log.d("AA","This is async ")
  return@async "taonce"
  }

  Log.d("AA","协程 other start")
  val result = deferred.await()
  Log.d("AA","async result is $result")
  Log.d("AA","协程 other end ")
}

Log.d("AA", "主线程位于协程之后的代码执行，时间:  ${System.currentTimeMillis()}")
```

#### runBlocking

**该部分全部摘自简书**

runBlocking 和 launch 区别的地方就是 runBlocking 的 delay 方法是可以阻塞当前的线程的，和Thread.sleep() 一样，看下面的例子:

```kotlin
fun main(args: Array<String>) {
  runBlocking {
    // 阻塞1s
    delay(1000L)
    println("This is a coroutines ${TimeUtil.getTimeDetail()}")
  }

  // 阻塞2s
  Thread.sleep(2000L)
  println("main end ${TimeUtil.getTimeDetail()}")
  }

~~~~~~~~~~~~~~log~~~~~~~~~~~~~~~~
This is a coroutines 11:00:51
main end 11:00:53
```

runBlocking 通常的用法是用来桥接普通阻塞代码和挂起风格的非阻塞代码，在 runBlocking 闭包里面启动另外的协程，协程里面是可以嵌套启动别的协程的。

### suspend 关键字

被修饰的函数可以称作**挂起函数**

**没用suspend标记的方法不能参加协程任务，suspend修饰的方法只能与另一个被suspend修饰的方法进行交流**

**协程本身也是挂起函数**

## 实际运用

代码来自我的SacredBank

之前玩家仓库翻页时更新数据库就是很普通的async task，而翻到下一页这个操作是同步的

这可能会导致玩家仓库数据尚未及时更新就翻到下一页，可能会出现玩家打开仓库中的物品与数据库中储存的玩家仓库物品不一致

运用协程巧妙的解决了这个问题

```kotlin
// 返回一个Deffered实例    
fun saveWarehouse(inv: Inventory, holder: BankHolder): Deferred<Unit> {
        return GlobalScope.async {
            inv.removeItem(item_previous_page, item_next_page, item_current_page, SacredBank.lockItem)
            val profile = Database.selectedDB.select(Bukkit.getOfflinePlayer(holder.target)) ?: PlayerProfile(Bukkit.getOfflinePlayer(holder.target).uniqueId)
            inv.forEachIndexed { i, item ->
                if (i < 45 && item.isNotAir()) profile.warehouseItems[i + 45 * (holder.warehouse_page - 1)] = item
                if (i < 45 && item.isAir()) profile.warehouseItems.remove(i + 45 * (holder.warehouse_page - 1))
            }
            Database.selectedDB.update(Bukkit.getOfflinePlayer(holder.target), profile)
        }
    }

// 翻页操作代码片段
// 对Deffered实例进行操作，使其在数据上传完毕后再进行翻页操作
Warehouse.saveWarehouse(e.inventory, holder).invokeOnCompletion {
   	Warehouse.open(e.whoClicked as Player, holder.also {
		it.warehouse_page += 1
		})
	}
```