---
title: java/kotlin 方法中获得调用方的类与方法名
date: 2021-11-3 17:10:42
author: 寒雨
hide: false
summary: 整理了java/kotlin 方法中获得调用方的类与方法名的方式
categories: 笔记
tags:
  - Java
  - Kotlin
---

这也是我一直很感兴趣的一个问题。曾经在翻阅TabooLib5源码时发现过类似的功能，TabooLib5利用它来得到调用方法的插件实例。

今天在网上冲浪的时候搞明白了，便来写一篇博文。

## 从栈中获取

在方法调用中new一个Throwable实例，得到它的stackTrace（stackTraceElement数组），便可以提取出一条完整的方法调用链。

同理，在try catch抓报错的时候，抓到的报错也可以通过获取stackTrace来提取一条方法调用链。

在写一个Exception的时候，你甚至可以重写它的printStackTrace方法让它的报错更好看 （

**例子**

Parctice.kt

```kotlin
package kim.bifrost.coldrain.partice

/**
 * kim.bifrost.coldrain.partice.Partice
 * Partice
 *
 * @author 寒雨
 * @since 2021/11/3 16:45
 **/
fun main() {
    test()
}

fun test() {
    // 获取上一级调用者
    val info = Throwable().stackTrace.run {
        get(size - 2)
    }
    println("class: ${info.className} method: ${info.methodName}")
}
```

编译后运行结果为

```
class: kim.bifrost.coldrain.partice.ParticeKt method: main
```

### 获取其他线程的栈

调用Thread#getStackTrace()

该方法不建议在当前线程调用，Throwable#getStackTrace()优于该方法

理由见Log4j注释[https://github.com/apache/loggin ... l/StackLocator.java](https://github.com/apache/logging-log4j2/blob/20f9a97dbe5928c3b5077bcdd2a22ac92e941655/log4j-api/src/main/java/org/apache/logging/log4j/util/StackLocator.java)

## JDK8后弃用的Reflection.getCallerClass方法

sun.reflect.Reflection.getCallerClass()

但不建议使用，JDK8以后该内部api已经被删除