---
title: 记一次严重滚挂——不要滚动更新openssl
date: 2022-11-23
author: 寒雨
hide: false
summary: 算是踩了个大坑吧，电脑差点变成砖没救回来
categories: 笔记
tags:
  - linux
  - arch linux
---

# 记一次严重滚挂——不要滚动更新openssl

首先从事情的来源说起吧，因为linux上文明6一个更新补丁导致游戏版本回退到远古版本没法跟朋友们联机，哥们准备自寻出路，最后产生了用wine运行windows版本的想法。恰好了解到Steam有一个非常棒的基于wine的开源工具 `proton` 能够兼容绝大部分游戏，于是我满心欢喜的尝试在aur上安装软件包。

![image-20221124005106899](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bedimage-20221124005106899.png)

这是怎么会是呢？我简单看了一下报错信息，看来是依赖冲突了。怎么办呢？于是我脑内产生了一个愚蠢的想法，更新openssl。

~~~bash
yay -S openssl
~~~

这一更新可就出大问题了😱，我发现几乎所有的指令都不能使用了（包括 pacman / yay 等管理软件包的指令，甚至还包括sudo）

![图像](https://pbs.twimg.com/media/FiPUNNNVEAEn7e_?format=jpg&name=large)

提示是缺少了动态链接库的依赖

所幸 su 还能用，用 su 进到 root 用户的 bash 里 ldd 看看到底缺少了哪些依赖:

![图像](https://pbs.twimg.com/media/FiPURVJVIAE99Ou?format=png&name=large)

大概就是各种版本的 libssl 和 libcrypto 找不到了，当时真挺绝望的，电脑很多功能都直接用不了了，甚至连文件夹的图像界面也打不开了。

咋办？还能咋办，求救啊

![图像](https://pbs.twimg.com/media/FiPUTmIVUAAXLc4?format=jpg&name=large)

去 telegram 问了一下，大佬发了一个 `pacman-static`，二进制可执行文件版本的pacman，通过它至少能调用pacman了。

大佬估计是嫌麻烦，直接让我 -Syu 。但这样实在太慢，实际上我只需要回滚 openssl 一个包就行了。然后发现 pacman 其实是可以回滚 aur 包的（之前一直以为不能回滚）

![图像](https://pbs.twimg.com/media/FiPUdVtVQAEYmXh?format=jpg&name=large)

~~~bash
./pacman-static -U openssl-1.1-1.1.1s-2-x86_64.pkg.tar.zst
~~~

回滚后一切功能恢复正常，有惊无险。