---
title: 解决某些linux程序缺少动态链接库的问题
date: 2022-12-27
author: 寒雨
hide: false
categories: 笔记
tags:
  - linux
---

# 解决某些linux程序缺少动态链接库的问题

> 记录一下解决`gdb`依赖问题的过程

今天突然想琢磨琢磨`gdb`，但发现 gdb 缺少动态链接库`libunistring.so.5`的依赖。

![image-20221227173436085](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/image-20221227173436085.png)

然后我又脑残了，更新了 libunistring。

> yay -S libunistring

这一更果然出事了，直接连 pacman 和 vscode 都没法用了，但之前好歹经历过类似的事情，知道可以给这个包降级

![image-20221227173025853](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/image-20221227173025853.png)

去 https://archive.archlinux.org 找到了老版本的软件包，用之前搞到的 `pacman-static ` 执行了降级操作，这样就完成了版本的降级

![image-20221227173237073](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/image-20221227173237073.png)

虽说解决了自己手残弄出来的滚挂，但是 gdb 还是不能用。先用`lddtree`看看缺少哪些依赖

![image-20221227173624732](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/image-20221227173624732.png)

看来只缺 `libunistring.so.5` 。于是到 `usr/lib` 目录下面看了一下 只找到了 `libunistring.so.2` 和 `libunistring.so.2.2.0`

于是突发奇想，干脆 `ln` 一下 `libunistring.2.2.0.so`，看看能不能用？

![image-20221227173857960](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/image-20221227173857960.png)

成功解决，看来这些依赖只有名字上的区别。