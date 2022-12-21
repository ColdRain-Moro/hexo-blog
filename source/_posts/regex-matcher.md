---
title: 正则表达式捕获组在Java/Kotlin中的使用
date: 2021-07-21 23:21:11
author: 寒雨
hide: false
summary: 记录下java的正则表达式捕获组的使用
categories: 笔记
tags:
  - Kotlin
  - Java
---

## 传统方式：使用捕获组序数来获取捕获组捕获到的内容

上代码

```kotlin
val pattern = Pattern.compile("(//d+)(//S+)")
val matcher = pattern.matcher("2021BifrostCraft")
if (matcher.find()) {
    print(matcher.group())
    print(matcher.group(1))
    print(matcher.group(2))
}
// 输出结果是:2021BifrostCraft,2021,BifrostCraft
```

但有时我们不知道Pattern中一共有多少个捕获组，也就不知道我们需要获取的捕获组的序号

这个问题一度困扰了我很久

直到我了解到命名捕获组这种做法

## 命名捕获组

**每个以左括号开始的捕获组，都紧跟着“?”，而后才是正则表达式。**

先上代码

```kotlin
val pattern = Pattern.compile("(?<number>//d+)(?<word>//S+)")
val matcher = pattern.matcher("2021BifrostCraft")
if (matcher.find()) {
    print(matcher.group())
    print(matcher.group("number"))
    print(matcher.group("word"))
}
// 输出结果是:2021BifrostCraft,2021,BifrostCraft
```

这样做，即使我们不知道我们的pattern里面有多少捕获组，也不知道我们需要的捕获组的序号，我们仍然能获取到我们想要得到得捕获组的内容