---
title: Hello Minecraft Forge & Mixin!
author: 寒雨
hide: false
summary: 开发了自己的第一个Forge Mod,并且初步了解了Mixin这一极其实用的字节码操作框架
categories: 杂谈
tags:
  - Minecraft
  - Forge模组开发
  - 字节码操作
  - Mixin 
---

# Hello Minecraft Forge & Mixin!

> 起因经过大概是斯帕克那边需要一个模组来禁止玩家开启 强制使用Unicode字体 这一选项来确保材质包的体验效果
>
> 行吧，以前虽然完全没有了解过Forge开发，还是只有硬着头皮上了呗

## Forge环境搭建

> 老大难了，Forge Mod的开发者之所以明显少于Bukkit插件开发者也许就是因为这位拦路虎吧
>
> 不仅难，社区的有关教程也特别少 （我知道有很多1.12的环境搭建教程，但1.16版本的forge教程简直是一片荒原
>
> 而由于网络原因（众所周知），老外的那套官方教程很多地方对我们不适用
>
> 庆幸我最开始学习的是Bukkit开发，如果当时我选择学习forge mod开发，多半会倒在环境搭建这座大山前

最开始我试图使用forge官方提供的ForgeGradle mdk快速完成开发环境的搭建，最后我发现即使我能够科学上网，有的东西gradle一样拉不下来

怎么办？于是我上mcbbs寻求帮助，发现了耗子大佬的[[1.17.1-1.7.10\] Minecraft模组开发离线包 [Forge|Fabric] - 编程开发 - Minecraft(我的世界)中文论坛 - (mcbbs.net)](https://www.mcbbs.net/thread-896542-1-1.html)于是我下载并部署了耗子大佬的gradle依赖离线包。

到这里我便具备了一个Forge开发者的基本开发环境

但如果仅仅到这里就结束，我也不会说他难了

真正的重头戏，还在后头

## Mixin环境搭建

> Mixin是SpongePowered开发的一套基于javaagent和asm框架的字节码操作框架，有了Mixin，开发者可以摆脱繁琐的传统字节码插桩操作，以一种非常简洁直观的方式修改Minecraft客户端的底层逻辑代码
>
> 而不同于Bukkit API竭力阻止开发者利用服务端原生特性，主张一切插件应该完全在Bukkit API的基础上实现
>
> Forge API的设计是完全信任开发者的，鼓励开发者修改客户端底层逻辑代码来实现自己想要的特性，甚至Forge准确来说不能被称为一种API，而是模组开发者与客户端底层代码的一层兼容层。
>
> 所以说，Forge和Mixin可谓是天作之合，从Forge1.16版本开始，Forge开始原生附带Mixin环境
>
> 而这一切，得益于Mojang官方公布了客户端的混淆表。Minecraft作为一款商业游戏，公布混淆表无疑是一种巨大的牺牲。但我相信，正是这个英明的决策，刺激了广大模组开发者的开发热情，让各色Minecraft模组在社区中遍地生根，让Minecraft成为如此一款伟大的游戏。
>
> 所以在Forge开发中，我们看到的大部分客户端底层代码都是具有相当程度的可读性的。
>
> 而使用Mixin，可以让我们以最高效的方式修改底层代码，实现一些以前在做Bukkit开发时连想都不敢想的魔法般的特性
>
> 那么Mixin的环境搭建，上面我说的重头戏

最开始我以为Mixin是不需要配置，开箱即用的。结果把编译出来的模组跑了一遍又一遍，发现Mixin没有起任何作用

我尝试在网络上搜索Mixin环境搭建教程，却发现除了耗子大佬的[[未知之域\][翻译]Mixin官方文档翻译——深度修改Minecraft的利器 - 编程开发 - Minecraft(我的世界)中文论坛 - (mcbbs.net)](https://www.mcbbs.net/thread-833646-1-1.html)，一篇有价值的文章也找不出来。

我在耗子大佬的官方文档翻译中学习了Mixin的使用方法，但它并没有详细的告诉我如何搭建环境。

于是我想起来，坏黑曾经写过一个1.16的Forge Mod，我是不是可以参考他的源码来招猫画虎呢

同时我也想起来海螺的博客似乎也提到过这玩意，然后在这上面找到了官方的release note

[关于 Mixin 升级到 0.8 和 ModLauncher 的那些事 | IzzelAliz's Blog](https://izzel.io/2020/02/06/mixin-0-8-guide/)

[Release Notes Mixin 0.8 · SpongePowered/Mixin Wiki (github.com)](https://github.com/SpongePowered/Mixin/wiki/Release-Notes---Mixin-0.8)

于是依靠上面这些，我基本搭建起了一个Mixin环境

> 难点基本如下
>
> 1.MixinConnector
>
> 2.MixinRefmap文件
>
> 3.MixinAnnoationProcessor
>
> 4.Mixin配置文件
>
> 额外需要注意的是，Mixin配置文件中指定的Mixin Pakage不能指定位模组主类所在包，这样会导致模组无法加载

虽然有些晚了，但我还是把问题解决之后找到的相关资料放在这里

[mouse0w0/forge-mixin-example: An example for using Mixin in Minecraft Forge 1.12.2 (github.com)](https://github.com/mouse0w0/forge-mixin-example)

## 功能实现

毕竟也不是教程，杂谈而已，就不写使用教程了

这里只放出实现功能的Mixin代码

### 我的做法

锁掉底层选项实际boolean值，使玩家不论如何更改选项都以非强制Unicode字体方式渲染字体

~~~java

package me.asgard.rain.afu.mixin;

import com.google.common.collect.ImmutableMap;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.fonts.FontResourceManager;
import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Overwrite;
import org.spongepowered.asm.mixin.Shadow;

import java.io.IOException;

/**
 * me.asgard.rain.afu.GameSettingMixin
 * AntiForceUnicode
 *
 * @author 寒雨
 * @since 2021/12/29 13:48
 **/
@Mixin(Minecraft.class)
public abstract class MinecraftMixin {

    @Final
    @Shadow
    private FontResourceManager fontManager;

    /**
     * @author Rain
     * @reason force disable force unicode
     */
    @Overwrite
    public boolean isEnforceUnicode() {
        return false;
    }

    /**
     * @author Rain
     * @reason force disable force unicode
     */
    @Overwrite
    public void selectMainFont(boolean p_238209_1_) {
        fontManager.setRenames(ImmutableMap.of());
    }
}
~~~

### 坏黑的做法

写成一天后坏黑大概是来兴趣了，也写了一个

他直接把那个选项的按钮删掉了。毫无疑问，这个做法更好

~~~java
package me.skymc.fsb.mixin;

import net.minecraft.client.AbstractOption;
import net.minecraft.client.gui.screen.Screen;
import net.minecraft.client.gui.widget.Widget;
import net.minecraft.client.gui.widget.button.OptionButton;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

/**
 * FSB
 * me.skymc.fsb.mixin.MixinScreenLanguage
 *
 * @author 坏黑
 * @since 2021/12/29 10:54 PM
 */
@Mixin(Screen.class)
public abstract class MixinLanguageScreen {

    @Inject(method = "addButton", at = @At(value = "HEAD"), cancellable = true)
    protected <T extends Widget> void addButton(T p_230480_1_, CallbackInfoReturnable<T> c) {
        if (p_230480_1_ instanceof OptionButton && ((OptionButton) p_230480_1_).getOption() == AbstractOption.FORCE_UNICODE_FONT) {
            c.setReturnValue(p_230480_1_);
        }
    }
}
~~~