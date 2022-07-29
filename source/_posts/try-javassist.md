---
title: 初试Javassist
date: 2021-11-7 23:08:07
author: 寒雨
hide: false
summary: 列举了几种基本的javassist用法
categories: 笔记
tags:
  - 外部库
  - Kotlin
  - Java
---

今天看见群友做了个很有意思的东西: 拦截插件的setOp方法，彻底干掉后门插件

经过一番交谈之后，我得知这是利用Javassist做的，利用javassist将setop方法的内容替换便可实现。之前也在b站看到过有大佬用javassist利用Integer装箱的特性整病毒注入的骚操作...于是我surf the internet，了解了一下这个库的用法，发现它与asm库的作用不是一般的相似。但它不同于asm库的是它的可操作空间是没有asm库大的，但它的操作会简单许多。我们甚至不需要了解字节码便能使用javassist实现一些修改字节码的功能。

实验代码

```
fun main() {
    javassistEdit()
}

fun javassistEdit() {
    // 获取ctClass,因为是Kotlin文件所以带有Kt后缀
    val ctClass = ClassPool.getDefault().get("kim.bifrost.coldrain.partice.TestClass")
    // 从ctClass获取方法
    val ctMethod = ctClass.getDeclaredMethod("test")
    // 直接修改方法体
    ctMethod.setBody("{ System.out.println(\"修改过后的内容\"); }")
    // 在方法起始行插入代码
    ctMethod.insertBefore("""
        System.out.println("第一行");
        """)
    // 在方法最后一行插入代码
    ctMethod.insertAfter("""
        System.out.println("最后一行");
        """)
    // 通过cflow检查是否为递归调用
    ctMethod.useCflow("test")
    // 若不为递归调用则打印test
    ctMethod.insertBefore("if ($"+ "cflow(test) == 0)" +
            " System.out.println(\"test \");")
    // 将newInstance获得的实例直接cast成接口,避免反射带来的开销
    (ctClass.toClass().newInstance() as TestInterface).test()
}

class TestClass : TestInterface {
    override fun test() {
        println("测试内容1")
    }
}

interface TestInterface {
    fun test()
}
```

输出结果:

```
test 
第一行
修改过后的内容
最后一行
```

但我有些疑惑的地方在于，要怎么样才直接修改TestClass本身，让修改以后调用这个类本身的方法也是经过我们修改的方法

而不是用我们修改过的ctClass实例化出一个实例来调用其中的方法

毕竟，只有这样才能做到那位群友的 “把setOp方法删干净” 的效果呢