---
title: Hello-Mirai
date: 2021-12-02
author: 寒雨
hide: false
summary: 使用mirai实现了我的芙兰机器人~
categories: 笔记
tags:
  - Mirai
  - Kotlin 
---

# Hello Mirai

> Mirai 是一款十分优秀的QQ机器人框架
>
> 由于Mirai提供了一套http-api的功能实现
>
> 我们几乎可以使用任何一种语言实现QQ机器人
>
> 而其本体项目是由Kotlin开发的，这正对我胃口！

## 缘起

> 一副古怪的牛牛之风席卷了咱群

![QQ截图20211202010933](https://gitee.com/coldrain-moro/images_bed/raw/master/images/QQ%E6%88%AA%E5%9B%BE20211202010933.png)

> 撂下狠话

![QQ截图20211202011010](https://gitee.com/coldrain-moro/images_bed/raw/master/images/QQ%E6%88%AA%E5%9B%BE20211202011010.png)

## 代码

~~~kotlin
package kim.bifrost.rain.anticowemoji

import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import net.mamoe.mirai.console.plugin.jvm.JvmPluginDescription
import net.mamoe.mirai.console.plugin.jvm.KotlinPlugin
import net.mamoe.mirai.contact.MemberPermission
import net.mamoe.mirai.event.GlobalEventChannel
import net.mamoe.mirai.event.events.GroupMessageEvent
import net.mamoe.mirai.event.events.NudgeEvent
import net.mamoe.mirai.message.code.MiraiCode.deserializeMiraiCode
import net.mamoe.mirai.message.data.MessageSource.Key.recall
import java.util.concurrent.TimeUnit
import kotlin.random.Random

/**
 * kim.bifrost.rain.anticowemoji.AntiCowEmoji
 * AntiCowEmoji
 *
 * @author 寒雨
 * @since 2021/12/1 17:11
 **/

object AntiCowEmoji : KotlinPlugin(
    JvmPluginDescription(
        id = "kim.bifrost.rain.anticowemoji.AntiCowEmoji",
        version = "1.0.0"
    ) {
        name("AntiCowEmoji")
        author("Rain")
    }
) {
    override fun onEnable() {
        // 芙兰杀爆牛牛人
        GlobalEventChannel.parentScope(this).subscribeAlways<GroupMessageEvent> { event ->
            if (event.group.id == 755478639L) {
                if(event.message.contentToString().contains("\uD83D\uDC2E")
                    || event.message.contentToString().contains("\uD83D\uDC02")) {
                    if (sender.permission >= MemberPermission.ADMINISTRATOR) return@subscribeAlways let {
                        bot.getGroup(group.id)?.sendMessage("管理员也不许牛!!! [mirai:at:${sender.id}]".deserializeMiraiCode())
                    }
                    // 撤 回 消 息
                    message.recall()
                    // 暴 政 执 行
                    sender.mute(Random.nextInt(180,600))
                    // 温 柔 告 诫
                    launch {
                        delay(TimeUnit.SECONDS.toMillis(1L))
                        subject.sendMessage("不许牛!!! [mirai:at:${sender.id}]".deserializeMiraiCode())
                    }
                }
            }
        }
        // 戳一戳回应
        GlobalEventChannel.parentScope(this).subscribeAlways<NudgeEvent> {
            if (target.id == bot.id) {
                from.nudge().sendTo(this.subject)
            }
        }
    }
}
~~~

## 实际效果

> 效果很好，纠正了这股不正之风
>
> 可爱的芙兰也变得有血有肉起来

![QQ图片20211202011439](https://gitee.com/coldrain-moro/images_bed/raw/master/images/QQ%E5%9B%BE%E7%89%8720211202011439.png)

## 踩的坑

有时机器人会突然变哑巴，这时只需删除bot文件夹中的cache即可