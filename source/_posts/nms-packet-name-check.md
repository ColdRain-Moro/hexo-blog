---
title: NMS蛋疼的非法包检测
date: 2021-07-18 17:07:39
author: 寒雨
hide: false
summary: 尝试利用继承NMS包来对数据包进行标识，结果出人意料
categories: 杂谈
tags:
  - Bukkit
  - Kotlin
  - TabooLib
---
故事起因大概是这样的...
昨天我需要做一个拦截本插件以外所有Actionbar信息的功能
最开始我自然而然的想到了监听**PacketPlayOutChat**数据包，通过判断它的内容是否符合条件来辨别这个Actionbar是否为我插件发送的Actionbar信息
**但这样实在是太low了**，我不喜欢利用其发送的文本内容进行判断。就像做GUI，比起判断GUI的title，当然是判断InventoryHolder的做法更好。
于是我转向研究能否给这个数据包本身加上一个标记，进而方便我们辨识这个数据包
于是我想到了让一个类继承PacketPlayOutChat，用这个类来发包的办法
并且利用Taboolib的**ASMVersionControl**，还可以实现这个对这个类的版本控制
只需要对监听到的数据包的类进行判断，便可以轻易辨别
当时我想到的时候感觉自己真是牛逼坏了
大致做法如下
**继承PacketPlayOutChat**

```
class LegalActionBarPacket(iChatBaseComponent: IChatBaseComponent, chatMessageType: ChatMessageType, uuid: UUID) : PacketPlayOutChat(iChatBaseComponent,chatMessageType,uuid)
```
**ASMVersionControl**
```
val legalPacketClass = AsmVersionControl.createNMS("me.asgard.coldrain.hud.module.nms.LegalActionBarPacket").mapping().translate(SacredHUD.plugin) 
```
**数据包监听**
```
    @TPacket(type = TPacket.Type.SEND)
    private fun send(player: Player, packet: Packet): Boolean {
        if (packet.equals("PacketPlayOutChat")
                && packet.read("b").reflex<Byte>("d") == 2.toByte()
                && packet.get().javaClass != legalPacketClass){
            return false
        }
        return true
    }
```

然后我洋洋得意的编译出来扔进服务器里，对自己发了一个legalPacket
可笑的是，这个我取名的legalPacket，被服务端认为是一个ilegal packet，我直接掉线
