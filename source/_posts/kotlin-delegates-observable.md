---
title: 利用Kotlin委托快捷的创建可观察属性
date: 2021-12-18
author: 寒雨
hide: false
summary: 所以LiveData被时代抛弃的理由又多了一个
categories: 笔记
tags:
  - Kotlin
  - 委托
---

# 利用Kotlin委托快捷的创建可观察属性

废话少说，上代码

~~~kotlin
class User {
    var name: String by Delegates.observable("初始值") { prop, old, new ->
        println("旧值：$old -> 新值：$new")
    }
}
~~~

但不同于RxJava，Flow和LiveData，它只能在变量声明时指定观察的回调函数

这也使得它不能在功能上完全取代掉LiveData（没错，我是标题党），尤其是在MVVM这种分层架构的架构模式中

但这不妨碍它成为LiveData被时代抛弃的理由之一，毕竟它可是Kotlin原生库里的东西。如果不需要在变量声明之后指定回调函数，那什么RxJava，Flow都得靠边站了。