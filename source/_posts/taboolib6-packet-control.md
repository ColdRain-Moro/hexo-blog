---
title: 利用TabooLib6发送/拦截/修改数据包以实现梦想中的特性
date: 2021-9-28 09:20:43
author: 寒雨
hide: false
summary: 写了一篇TabooLib数据包控制技巧的教程
categories: 教程
tags:
  - TabooLib
  - Kotlin
---

## 前言

在如今的插件开发者社区中，利用NMS底层的数据包功能实现一些游戏特性已经不再稀奇。例如坏黑大佬的Adyeshach和Arasple的TrMenu，它们的功能全部依靠数据包实现。

本文将尝试让读者从一定程度上理解数据包，而不是仅仅扔出一段一段的代码...

由于文章作者很少涉猎1.17版本的插件开发，所以这篇文章的部分内容只对1.16.5及以下版本适用

由于文章作者是个菜逼，所以部分内容甚至是整片文章对于数据包的论述可能十分片面，大佬轻喷

**文章作者也是菜鸟，文章内容如有谬误烦请各位大佬指正**

## 从一定程度上理解数据包

你也许听说过数据包这个东西，但是你真的知道它是什么吗？

那么你有没有想过，**服务器**是如何控制玩家**客户端**的显示效果的呢？

答案是向玩家客户端发送数据包，然后客户端按照数据包的内容执行游戏效果。

举个例子:

> 玩家因为某种原因扣血了
>
> 1. 服务端将内存中储存的玩家血量修改为扣血后的值
> 2. 向客户端发送一个PacketPlayOutUpdateHealth数据包
> 3. 客户端按照数据包中的内容修改了玩家屏幕上显示的血量

那么你应该已经想到这个环节我们可以怎么操作了

> 1.我们自己手动向玩家的客户端发送数据包，让玩家看到假的效果 （比如上面的例子，我们可以给玩家制造一个扣血的“假象”）
>
> 2.我们修改服务端发送的数据包，修改里面的字段，让玩家看到我们想让他们看到的效果 (比如玩家扣了10点血，但是我可以让他看起来只扣了1点血，但是服务端里记录的玩家真实生命值仍然扣除了10点)
>
> 3.拦截数据包，直接让玩家看不到这个效果 （玩家被打了，可玩家客户端上显示没有扣血，实际上扣了）

### 数据包的命名规则

每一种数据包都是NMS底层的一个类，他们的位置都在net.minecraft.server.<版本号>这个包下

我们来拆分一下PacketPlayOutUpdateHealth这个数据包的名称

Packet(Play)(Out)(UpdateHealth)

Play: 数据包的发送的四种状态之一 （HandShake, Status, Login, Play）

Out: Out/In -> Out即为服务端向客户端发送的数据包，In则相反

UpdateHealth: 这个数据包的作用，这里是指更新玩家客户端的健康状态

由此我们便大致可以猜测数据包的作用

当然，如果你不是很确定的话，还是查查[Protocol - wiki.vg](https://wiki.vg/Protocol#Interact_Entity)吧

### 数据包字段

在我们通过反编译查看数据包类的内容时，一般我们会发现一些字段。这些字段的字段名一般都是a，b，c之类的字母，我们无法从字段名中推测这个字段的值代表的东西。

而无论是发包还是修改数据包，我们都必须理解这个数据包的字段所代表的意义才行。

[![image-20210928084148586](https://camo.githubusercontent.com/97fa12ece9deff1a46bd47da6b99a25e982091f1c2b4e46c7ff3526620ceb9f3/68747470733a2f2f67697465652e636f6d2f636f6c647261696e2d6d6f726f2f696d616765735f6265642f7261772f6d61737465722f696d616765732f696d6167652d32303231303932383038343134383538362e706e67)](https://camo.githubusercontent.com/97fa12ece9deff1a46bd47da6b99a25e982091f1c2b4e46c7ff3526620ceb9f3/68747470733a2f2f67697465652e636f6d2f636f6c647261696e2d6d6f726f2f696d616765735f6265642f7261772f6d61737465722f696d616765732f696d6167652d32303231303932383038343134383538362e706e67)

一般这种情况下，我们会查阅[Protocol - wiki.vg](https://wiki.vg/Protocol#Interact_Entity)

[![image-20210928084449744](https://camo.githubusercontent.com/dc70d6784e1e59e2a5423b583c9ef90dae6f59ff3db7246d579aa3f45a1aa40b/68747470733a2f2f67697465652e636f6d2f636f6c647261696e2d6d6f726f2f696d616765735f6265642f7261772f6d61737465722f696d616765732f696d6167652d32303231303932383038343434393734342e706e67)](https://camo.githubusercontent.com/dc70d6784e1e59e2a5423b583c9ef90dae6f59ff3db7246d579aa3f45a1aa40b/68747470733a2f2f67697465652e636f6d2f636f6c647261696e2d6d6f726f2f696d616765735f6265642f7261772f6d61737465722f696d616765732f696d6167652d32303231303932383038343434393734342e706e67)

于是通过查询wiki，我们基本确定了数据包中字段代表的意义 a -> 生命值 b -> 饱食度 c -> 食物饱和度

请注意，**少数时候反编译出来的字段并不按wiki中表格的顺序排列**（例如PacketPlayOutExperience），你需要结合字段类型来判断字段在wiki上对应的字段

有时多个字段类型一样，千万要多试。

虽然wiki是个很方便的东西，但wiki上也不是什么都有的。事实上，有很多数据包的字段，还有一些DataWatcher之类的杂七杂八的东西没有被wiki标注字段名称和Notes。这时候我们不能怕困难，怼着NMS代码啃就完事了！

Tips: 有针对性的去寻找NMS代码，从跟你想要实现的功能有一定关系的BukkitAPI方法入手，顺藤摸瓜草到CraftBukkit再溯源到NMS

### 使用TabooLib6发送/修改/拦截数据包

#### 发送

使用TabooLib的牛逼NMS版本控制工具，直接写NMS代码来发送数据包

**接口部分**

```kotlin
interface NMS {
    
    /**
     * 刷新饱食度条
     *
     * @param p 玩家
     */
    fun updateFoodBar(p: Player)

    companion object {
        // 经过版本控制的实例，可以在任意版本放心使用
        // 在同一个包下创建一个实现类，取名为<接口名>Impl即可
        val handle by lazy {
            nmsProxy<NMS>()
        }
    }
}
```

**实现部分**

```kotlin
class NMSImpl : NMS {
    
    // 没错，直接用nms，不用担心版本的问题
    override fun updateFoodBar(p: Player) {
        val foodData = (p as CraftPlayer).handle.foodData
        p.handle.playerConnection.sendPacket(PacketPlayOutUpdateHealth(p.scaledHealth, foodData.foodLevel, foodData.saturationLevel))
    }
    
}
```

#### 拦截/修改

TabooLib6将服务器数据包通讯包装为了两个事件，我们直接通过监听这个事件即可实现数据包的拦截与修改

监听名称中含有Out这个单词的数据包就用PacketSendEvent，In就用PacketReceiveEvent

接下来我给段实例代码，自己去悟吧

```kotlin
@SubscribeEvent
fun e(e: PacketSendEvent) {
	// 对数据包类型的判断
    if (e.packet.name == "PacketPlayOutExperience") {
        val v = expTempValue[e.player.name]
        // 读取数据包中字段的值
        val level = e.packet.read<Int>("c")
        // 将值写入数据包中的字段
        e.packet.write("a", v ?: 0.0f)
        e.packet.write("c", 0)
        // 取消事件，意思是直接把这个数据包拦截下来了
        e.isCancelled = true
    }
}
```