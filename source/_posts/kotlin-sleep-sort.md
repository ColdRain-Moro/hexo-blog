---
title: 用kotlin协程实现了睡眠排序
date: 2021-10-18 11:45:28
author: 寒雨
hide: false
summary: 用Kotlin实现了睡眠排序
categories: 杂谈
tags:
  - Kotlin
  - Coroutine
  - 算法
---

# 用kotlin协程实现了睡眠排序

```kotlin
// 睡眠排序 kotlin实现
// 需要用到协程库
// kt用多线程写多没意思
fun sleepSort(array: Array<Int?>): List<Int?> {
    val result = arrayListOf<Int>()
    val list = arrayListOf<Deferred<Unit>>()
    for (i in array) {
        list.add(GlobalScope.async {
            delay(i!! * 10L)
            result.add(i)
            Unit
        })
    }
    // 堵塞至操作完成
    runBlocking {
        list.forEach {
            it.await()
        }
    }
    return result
}
```

