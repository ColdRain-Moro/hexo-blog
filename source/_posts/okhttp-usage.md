---
title: OKHttp/HttpURLConnection使用笔记
date: 2021-11-14
author: 寒雨
hide: false
summary: OKHttp/HttpURLConnection使用笔记
categories: 笔记
tags:
  - Kotlin
  - 网络操作
  - 外部库
---

# OKHttp/HttpURLConnection使用笔记

废话不多说，上代码

~~~kotlin
    // 使用OKHttp提交数据
    private fun okHttpPost() {
        coroutineScope.launch(Dispatchers.IO) {
            val requestBody = FormBody.Builder()
                .add("user", "admin")
                .add("password", "123456")
                .build()
            val request = Request.Builder()
                .url("https://www.baidu.com")
                .post(requestBody)
                .build()
            // 之后操作跟拉取数据一样
        }
    }

    // 使用OKHttp拉取数据
    // 比HttpUrlConnection好使多了
    private fun okHttpPull() {
        coroutineScope.launch(Dispatchers.IO) {
            try {
                val client = OkHttpClient()
                val request = Request.Builder()
                    .url("https://www.baidu.com")
                    .build()
                val response = client.newCall(request).execute()
                val data = response.body?.string()
                if (data != null) {
                    withContext(Dispatchers.Main) {
                        binding.responseText.text = data
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    // 使用HttpURLConnection提交数据
    private fun httpUrlConnectionPost() {
        val connection: HttpURLConnection? = null
        // 网络请求操作 拿到connection
        connection!!.requestMethod = "POST"
        val output = DataOutputStream(connection.outputStream)
        output.writeBytes("username=admin&password=123456")
    }

    // 使用HttpURLConnection拉取数据
    private fun httpUrlConnectionPull() {
        // 即使使用协程，网络操作也不能在主线程上运行，需要使用Dispatchers.IO
        coroutineScope.launch(Dispatchers.IO) {
            var connection: HttpURLConnection? = null
            try {
                val response = StringBuilder()
                val url = URL("https://www.baidu.com")
                connection = url.openConnection() as HttpURLConnection
                connection.connectTimeout = 8000
                connection.readTimeout = 8000
                val input = connection.inputStream
                val reader = BufferedReader(InputStreamReader(input))
                reader.use {
                    reader.forEachLine {
                        response.append(it)
                    }
                }
                // 切回主协程，这样做是因为Dispatcher.IO的协程其实不隶属于主线程
                withContext(Dispatchers.Main) {
                    binding.responseText.text = response.toString()
                }
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                connection?.disconnect()
            }
        }
    }
~~~



