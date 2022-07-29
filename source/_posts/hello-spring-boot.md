---
title: Hello Spring Boot!
author: 寒雨
hide: false
summary: 用spring boot简单的实现了路姐姐的聊天室后端
categories: 杂谈
tags:
  - Kotlin
  - SpringBoot
  - 后端
---

# Hello Spring Boot

其实之前也有了解过其他的后端实现方式，比如Go的后端（还没学到怎么写接口就放弃了），Node.js的后端（还是整得稀里糊涂的），发现都学不太会。（其实是没时间去仔细琢磨，学习这些语言的后端同时也需要学习这些语言，学习成本较大）

于是我还是选择了最传统的Spring Boot后端。不过我使用了我喜欢的Kotlin语言来编写，使用Gradle工具来管理依赖库。

刚上手时便惊讶的发现，Spring Boot框架对java后端的封装真的特别彻底，基本就是几个注解便帮你处理了大部分工作，写起来真的特别的舒服。

像这样便能实现一个简单的返回json信息的api接口

~~~kotlin
@RestController
class TestController {

    @GetMapping("/greeting")
    fun greeting(@RequestParam(value = "name", defaultValue = "World") name: String) = BaseResponseBean("Hello $name")

}

data class BaseResponseBean<T>(
    val data: T?,
    val errorCode: Int = 0,
    val errorMsg: String = ""
)
~~~

然后我便想写个项目练练手，于是就想到了路姐姐的聊天室后端。路姐姐是用的TypeScript实现的聊天室后端，我便想用Spring Boot实现一个功能类似的。

代码如下

~~~kotlin
data class ChatWsMessageBean(
    val type: String,
    val username: String,
    val data: String?,
    val avatar: String
)

object WebSocketMessageType {
    const val OPEN = "OPEN"
    const val CLOSE = "CLOSE"
    const val MESSAGE = "MESSAGE"
}

@Component
class ChatRoomWsHandler : TextWebSocketHandler() {

    private val objectMapper = ObjectMapper()
    private val connectedSessions = arrayListOf<WebSocketSession>()

    override fun afterConnectionEstablished(session: WebSocketSession) {
        connectedSessions.add(session)
        val username = session.attributes["username"] ?: "unnamed"
        val avatar = session.attributes["avatar"] ?: "https://i0.hdslb.com/bfs/face/member/noface.jpg@240w_240h_1c_1s.webp"
        connectedSessions.forEach { it.sendMessage(TextMessage(ChatWsMessageBean(WebSocketMessageType.OPEN, username.toString(), null, avatar.toString()).stringify())) }
        println("[ChatRoom] $username connect with avatar $avatar")
    }

    override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
        val username = session.attributes["username"] ?: "unnamed"
        val avatar = session.attributes["avatar"] ?: "https://i0.hdslb.com/bfs/face/member/noface.jpg@240w_240h_1c_1s.webp"
        connectedSessions.forEach {
            it.sendMessage(TextMessage(ChatWsMessageBean(WebSocketMessageType.MESSAGE, username.toString(),
                message.payload, avatar.toString()).stringify()))
        }
        println("[ChatRoom] $username send message ${message.payload} with avatar $avatar")
    }

    override fun afterConnectionClosed(session: WebSocketSession, closeStatus: CloseStatus) {
        connectedSessions.remove(session)
        val username = session.attributes["username"] ?: "unnamed"
        val avatar = session.attributes["avatar"] ?: "https://i0.hdslb.com/bfs/face/member/noface.jpg@240w_240h_1c_1s.webp"
        connectedSessions.forEach { it.sendMessage(TextMessage(ChatWsMessageBean(WebSocketMessageType.CLOSE, username.toString(), null, avatar.toString()).stringify())) }
        println("[ChatRoom] $username disconnect with avatar $avatar")
    }

    private fun ChatWsMessageBean.stringify() = objectMapper.writeValueAsString(this)
}

@Configuration
@EnableWebSocket
class WebSocketConfig : WebSocketConfigurer {

    @Autowired
    private lateinit var chatRoomWsHandler: ChatRoomWsHandler

    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry) {
        registry.addHandler(chatRoomWsHandler, "chatroom")
            .setAllowedOrigins("*")
    }
}
~~~

对其效果个人还是非常满意的，改天有时间写一个Android端的聊天室

在全栈的道路上越走越远XD