---
title: 记观察者模式(Observer Pattern) & Android LifeCycle
date: 2021-11-6 00:55:06
author: 寒雨
hide: false
summary: 主要还是谈谈观察者模式
categories: 杂谈
tags:
  - Android
  - Kotlin
  - 设计模式
---

其实今天我才听说这种设计模式（之前把这个跟visitor模式搞混了），但以前不知不觉已经用过很多这样设计的api了。

上周的红岩作业甚至手搓了个eventbus（不过没搓成注解那种形式，不过确实无意中用到了观察者模式的设计方式）

感觉最牛逼的是，我是自己悟出观察者模式的设计方式去实现了eventbus，思路与观察者模式别无二致。（突然感觉自己也许没那么废物）

今天这篇博文主要是记录一下Android Jetpack组件LifeCycle的用法捏

## LifeCycle

与TabooLib里的Awake注解比较类似，让我们不用把每个组件生命周期需要执行的代码都写在MainActivity （

有助于降低代码耦合度

同时它也使用了观察者模式的设计模式XD

草，不想写了，就这样吧