---
title: 用OkHttp进行一个json信息的获取
date: 2021-11-14
author: 寒雨
hide: false
categories: 笔记
tags:
  - 外部库
  - 网络操作
---

# 用OkHttp进行一个json信息的获取

获取一段json信息，用gson将它格式化，再输出到一个本地json文件里

~~~kotlin
/**
 * 从请求中获取json字符串，将其格式化输出到文件中
 * 使用Gson格式化json字符串
 */
fun getData() {
    val gson = GsonBuilder().setPrettyPrinting().create()
    val client = OkHttpClient()
    val request = Request.Builder()
        .url("https://www.wanandroid.com/article/list/0/json")
        .build()
    val response = client.newCall(request).execute()
    val json = response.body?.string()
    if (json != null) {
        val formatted = gson.toJson(gson.fromJson(json, Any::class.java))
        val file = File("E:\\data.json").apply { createNewFile() }
        FileWriter(file).apply {
            write(formatted)
            flush()
            close()
        }
    }
}
~~~

