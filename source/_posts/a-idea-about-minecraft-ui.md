---
title: 一个Minecraft Chest UI框架的灵感
author: 寒雨
hide: false
summary: 我在想，Minecraft的GUI，是不是也可以沿用Compose的那套设计思路...
categories: 杂谈
tags:
  - Minecraft
  - Compose
  - Kotlin
---

# 一个Minecraft Chest UI框架的灵感

我在想，Minecraft的GUI，是不是也可以沿用Compose的那套设计思路...

于是说干就干，我会放一些思路在下面

## 一些Minecraft本土化措施

当然不能搞教条主义，毕竟Minecraft GUI与Android UI之间差距不可谓不大，不可能照搬照抄。

### 多平台实现

MinecraftCompose提供接口供其他开发者实现，同时提供一套基于TabooLib框架下的默认实现

如果你希望基于其他UI框架使用MinecraftCompose，可以自行实现

### @Composable实现

我认为对我来说搞出@Composable那种效果有点不现实，那么我们便退而求其次，使用下面的方式达到函数组合的效果。

~~~kotlin
val composeApi = MinecraftCompose.newAPIInst(TabooLibImpl::class.java)

// 为玩家打开UI
fun openFor(player: Player) {
    composeApi.open(player) { /**this: ComposeScope **/
        mainUI(this)
    }
}

// Compose Function
fun mainUI(scope: ComposeScope) {
    with(scope) {
        // 剩下的留着我之后想
	}
}
~~~

### MVI思想

~~~kotlin
val state by viewModel.databaseFlow.observeAsState()
// ObserveAsState后,ComposeUI会随订阅的Flow更新而重构
~~~



