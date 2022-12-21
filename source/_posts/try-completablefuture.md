---
title: 初试CompletableFuture
date: 2021-08-28 13:21:28
author: 寒雨
hide: false
summary: 初次尝试java的CompletableFuture
categories: 笔记
tags:
  - Kotlin
  - Java
---

这个东西其实是在看了海螺大佬的博客([如何问玩家“吾与徐公孰美？” | IzzelAliz's Blog](https://izzel.io/2020/02/12/chat-with-future/))后才了解的，但在今天之前我其实一直只是在用它的回调函数来确保某些操作在一些耗时动作执行完后执行。

直到昨天为了做一个玩家按键跳过登入动画的功能，我又去看了这篇文章。不得不说，**海螺是真的牛逼**

## 代码

按照海螺在他博客里提供的思路，我照猫画虎整了一个监听玩家按键的功能。

在需要与玩家交流时注册一个监听器，交流完或者超时时关闭这个想法真的牛逼。我真想不到

**监听器类**

```kotlin
class AskSkipOrNot(private val uuid: UUID,
                   private val future: CompletableFuture<Boolean>) : Listener {

    @EventHandler
    fun e(e: PlayerInteractEvent) {
        if (e.player.uniqueId != uuid) return
        if (SacredAuth.conf.getString("auth.display.skip-button")?.uppercase() == "RIGHT"
            && e.action == Action.RIGHT_CLICK_AIR) {
            future.complete(true)
            HandlerList.unregisterAll(this)
        }
        if (SacredAuth.conf.getString("auth.display.skip-button")?.uppercase() == "LEFT"
            && e.action == Action.LEFT_CLICK_AIR) {
            future.complete(true)
            HandlerList.unregisterAll(this)
        }
    }

    @EventHandler
    fun e(e: PlayerSwapHandItemsEvent) {
        if (e.player.uniqueId != uuid) return
        if (SacredAuth.conf.getString("auth.display.skip-button")?.uppercase() == "F") {
            future.complete(true)
            HandlerList.unregisterAll(this)
        }
    }
}
```

**功能**

```kotlin
    // 展示登录动画
    fun toIconDisplayAnimation(player: Player, func: () -> Unit = { }) {
        player.setMetadata("SacredAuth:icon-display", FixedMetadataValue(SacredAuth.plugin, true))
        val future = CompletableFuture<Boolean>()
        val time = conf.getLong("auth.display.time")
        KetherShell.eval(conf.getString("auth.display.script.display")!!) {
            sender = player
        }
        // 方法
        fun end() {
            player.removeMetadata("SacredAuth:icon-display", SacredAuth.plugin)
            KetherShell.eval(conf.getString("auth.display.script.after-display")!!) {
                sender = player
            }
        }
        future.thenRun {
            end()
            func.invoke()
        }
        val listener = AskSkipOrNot(player.uniqueId, future)
        Bukkit.getPluginManager().registerEvents(listener, SacredAuth.plugin)
        Tasks.task(true) {
            try {
                future.get(time * 50L, TimeUnit.MILLISECONDS)
            } catch (ignored: TimeoutException) {
                // 这里貌似future已经被中断了，因为超时了，所以future即使complete也不会执行他的回调函数
                // future.complete(true)
                end()
                func.invoke()
            }
        }
    }
```

