---
title: Hello Ktor!
date: 2022-01-03
author: 寒雨
hide: false
summary: 用Ktor实现了路姐姐聊天室的后端
categories: 杂谈
tags:
  - Kotlin
  - Ktor
  - 后端
---

# Hello Ktor!

> Ktor是JetBrains官方团队开发的一款基于Kotlin语言的后端框架
>
> 不同于Spring Boot牺牲性能换取开发效率的做法，在Kotlin语言优美的DSL语法与协程特性的加持下，Ktor兼顾了并发性能与开发效率
>
> 更为重要的是，作为一名使用Kotlin语言进行开发的Android开发者，同样使用大量Kotlin语言高级特性与协程的Ktor属实是我们走向全栈之路的不二法门呢

其实接触这个主要是因为我用Spring Boot写的那个WebSocket无论如何都没法用OKHttp连上（浏览器就可以）

不多废话，直接贴代码，感受一下Kotlin DSL的优雅简洁

**Sockets.kt**

~~~kotlin
val logger = LogManager.getLogManager().getLogger("ChatRoom")
val gson: Gson = GsonBuilder().create()

fun Application.configureSockets() {
    install(WebSockets) {
        pingPeriod = Duration.ofSeconds(15)
        timeout = Duration.ofSeconds(15)
        maxFrameSize = Long.MAX_VALUE
        masking = false
    }

    routing {
        val connections = Collections.synchronizedSet<Connection?>(LinkedHashSet())
        webSocket("/chatroom") { // websocketSession

            val thisConnection = Connection(
                this,
                call.request.queryParameters["username"] ?: "nameless",
                call.request.queryParameters["avatar"]
                    ?: "https://i0.hdslb.com/bfs/face/member/noface.jpg@240w_240h_1c_1s.webp"
            )
            connections += thisConnection
            println("${thisConnection.name} join with avatar: ${thisConnection.avatar}")
            connections.forEach {
                it.session.outgoing.send(
                    Frame.Text(
                        gson.toJson(
                            ChatMessageBean(
                                "OPEN",
                                thisConnection.name,
                                null,
                                thisConnection.avatar
                            )
                        )
                    )
                )
            }
            try {
                for (frame in incoming) {
                    when (frame) {
                        is Frame.Text -> {
                            val text = frame.readText()
                            println("${thisConnection.name} chat with avatar: ${thisConnection.avatar} : $text")
                            connections.forEach {
                                it.session.outgoing.send(
                                    Frame.Text(
                                        gson.toJson(
                                            ChatMessageBean(
                                                "MESSAGE",
                                                thisConnection.name,
                                                text,
                                                thisConnection.avatar
                                            )
                                        )
                                    )
                                )
                            }
                        }
                    }
                }
            }  catch (t: Throwable) {
                println(t.localizedMessage)
            } finally {
                connections -= thisConnection
                println("${thisConnection.name} exit with avatar: ${thisConnection.avatar}")
            }
        }
    }
}
~~~

**ChatMessageBean**

~~~kotlin
data class ChatMessageBean(
    val type: String,
    val username: String,
    val data: String?,
    val avatar: String
)
~~~

**Connection**

~~~kotlin
class Connection(val session: DefaultWebSocketSession, val name: String, val avatar: String) {
    companion object {
        var lastId = AtomicInteger(0)
    }
}
~~~

