---
title: MMVM七宗罪
author: 寒雨
hide: false
summary: 对掘金上关于MMVM常见错误用法的总结
categories: 笔记
tags:
  - Android
  - MVVM
---

# MVVM七宗罪

## 其一 拿Fragment当LifecycleOwner

Livedata之所以可以防止泄露，是因为它所持有的lifecycleowner走到`DESTORYED`时就会自动取消所有订阅。

然而Fragment在某些情况下并不会销毁，由于创建一个Fragment代价高昂，在Fragment的跳转过程中，如果使用返回栈，在返回这个fragment时并不会创建一个新的fragment，而是会复用老的Fragment，也就是Fragment的生命周期此时还未结束，但在之前离开这个fragment时，这个fragment中的view确实已经摧毁了。一般我们比较通常的写法是在`onViewCreated`中进行观察，而不是在`onCreate`,也就是说，我们在fragment中的view的生命周期开始时我们订阅了一个可订阅的东西，但却在fragment的生命周期结束时才取消订阅，这就导致了一个问题，我们退出界面时，fragment的view确实已经销毁了，但fragment没有销毁，于是再次进入fragment又会调用一次`onViewCreated`，就会导致我们重复订阅了两次。

解决方式就是使用`viewLifecycleOwner`，这样在view被销毁时就能取消订阅。

## 其二 在launchWhenX中启用协程

### Flow vs. LiveData

Flow总体上看确实功能比LiveData要更加强大，但由于LiveData是android jetpack的一部分，是专为android设计的，所以它在安卓应用场景下至少带来了两个好处

- 生命周期管理 - lifecycleOwner进入destory阶段时，会自动取消订阅，防止内存泄漏
- 节省资源 - lifecycleOwner在进入STARTED时才会接收数据，避免在后台的无效计算

如果想使用Flow来替代LiveData，那么至少需要做到这两点才行

第一点其实比较好实现，我们很多时候观察的Flow都是一个冷流，冷流的生命周期由订阅它的CoroutineScope决定。而官方的`lifecycle-runtime-ktx`已经为我们的所有lifecycleOwner添加了一个`lifecycleScope`，只要在lifecycleScope启动的协程中订阅就能保证第一点，而即使是热流也会自动取消订阅。我认为在这方面Flow取代LiveData是基本没有问题的，因为只要是个人就能想到使用lifecycleScope启动协程进行流的收集。

那么第二点要如何保证呢？

很多人就会想到所谓的`launchWhenX`，它能让开启的协程在`PAUSED`时挂起，在`STARTED`,`RESUMED`时恢复，似乎看起来很完美，对吗？

可惜的是，这样做只挂起了下游我们收集这个flow的协程，而上游的数据还在持续发送，如果这样做的话，第二点解决的其实很不彻底。

那么，解决方法是什么呢

### repeatOnLifecycle

> lifecycle-runtime-ktx 自 `2.4.0-alpha01` 起，提供了一个新的协程构造器 `lifecyle.repeatOnLifecycle`， 它在离开 X 状态时销毁协程，再进入 X 状态时再启动协程。从其命名上也可以直观地认识这一点，即**围绕某生命周期的进出反复启动新协程**。

是的，不再是挂起，而是直接销毁。这样做的话collect就不是被挂起，而是直接被取消订阅，如果我们这里订阅的是一个冷流，那么上游就会跟着被取消。这是不是就完美的解决了第二点？

同时一旦使用这个方法启动的协程来订阅Flow，这个Flow就也会具有LiveData的重要特性之一: 数据倒灌。这样看来，是不是只要用好这个方法，Flow就完全可以替代LiveData，对吧。

但其实LiveData和Flow还有一些不同之处，我们也不能完全抛弃LiveData，而是要因地制宜。

当然，使用它来收集flow还有一个快捷的写法`flowWithLifecycle(LifecycleOwner)`

## 其三 在onViewCreated中请求数据

在 MVVM 中, ViewModel 的重要职责是解耦 View 与 Model。

- View 向 ViewModel 发出指令，请求数据
- View 通过 DataBinding 或 LiveData 等订阅 ViewModel 的数据变化

关于订阅 ViewModel 的时机，大家一般放在 `onViewCreated` ，这是没有问题的。但是一个常犯的错误是将 ViewModel 中首次的数据加载也放到 `onViewCreated` 中进行。如果 ViewModel 在 `onViewCreated` 中请求数据，当 View 因为横竖屏等原因重建时会再次请求，而我们知道 ViewModel 的生命周期长于 View，数据可以跨越 View 的生命周期存在，所以没有必要随着 View 的重建反复请求。

> ViewModel 的初次数据加载推荐放到 `init{}` 中进行，这样可以保证 `ViewModelScope` 中只加载一次

## 其四 使用LiveData & StateFlow发送Events

LiveData和StateFlow被设计来保存一个状态，单从这个角度来说，它们设计得非常到位，完美的符合我们的需求。但如果我们的需求不是保存一个状态，而只是希望它在收到一个值时能够通知观察者，也许它们就不太适合了。

LiveData在设计时被赋予了数据倒灌的特性，回到界面时会再次通知一次观察者，事件应该是具有时效性的，这样与我们的需求不符。

LiveData和StateFlow都会产生丢值的问题，因为LiveData和StateFlow设计的时候都只考虑了保留一个值的情况，所以对他们而言，最新的值才是最重要的，已经过期的值就没有必要通知，减少下游的处理逻辑，节省性能，所以这并不是bug，而是一种特性。StateFlow还会忽略重复发送的相同的值，这个特性被称为**防抖**。

## 其五 在Repository层中使用LiveData

我们应该经常在仓库层使用RxJava或者Flow，但其实很少见到说在仓库层使用LiveData，在我印象中这三者应该至少是比较类似的东西，那么为什么LiveData不行呢？有两点点原因:

- 重度依赖lifecycle，仓库层获取不到lifecycleOwner，只能使用observeForever这种可能造成内存泄漏的方法来进行
- 不支持线程切换 故所有操作符实际上默认都是在主线程上运行

## 其六 ViewModel接口暴露不合理

- 暴露Mutable状态
- 暴露suspend方法
