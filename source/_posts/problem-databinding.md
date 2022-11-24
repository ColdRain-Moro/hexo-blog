---
title: 在DataBinding的使用过程中踩的坑
date: 2021-11-22
author: 寒雨
hide: false
summary: DataBinding可能会导致Kotlin编译器无法smart cast, 而IDE不会标红
categories: 笔记
tags:
  - Android
  - Kotlin
---

# 在DataBinding的使用过程中踩的坑

今天初次尝试了DataBinding，之前一直在用ViewBinding。今天欣喜的发现DataBinding包含了ViewBinding的全部功能，绝绝子。

DataBinding对于基于MVVM架构理念设计的Android程序来说非常有意义，它可以进一步解耦。

不说了，来看看我今天遇到的具体问题

> DataBinding可能会导致Kotlin编译器无法smart cast, 而IDE不会标红

我在布局文件activity_login.xml中给布局绑定了这样一个变量

~~~xml
    <data>
        <variable
            name="viewModel"
            type="kim.bifrost.coldrain.wanandroid.viewmodel.LoginViewModel" />
    </data>
~~~

如你所见，我在代码中准备使用它

~~~kotlin
binding.viewModel.postLogin()
~~~

这行代码在IDE中并没有标红，但无法通过编译

~~~
e: E:\ColdRain_Moro\AndroidProject\WanAndroid\app\src\main\java\kim\bifrost\coldrain\wanandroid\view\activity\LoginActivity.kt: (31, 13): Smart cast to 'LoginViewModel' is impossible, because 'binding.viewModel' is a complex expression
~~~

遇事不决问度娘，于是在百度上找到了答案 ([在Kotlin中无法进行Smart Cast - Javaer101](https://www.javaer101.com/article/52202734.html))

原来这个viewModel变量的类型实际上是LoginViewModel?，也就是它是允许为空的。而我获取的时候是直接以LoginViewModel的形式获取，它没有办法从LoginViewModel?类型smart cast为LoginViewModel。

那么在调用的时候后面加个?就解决了。

~~~kotlin
binding.viewModel?.postLogin()
~~~

之所以记录下来，是因为Android Studio没有给之前错误的用法标红，我觉得这个还是应该标个红的。

