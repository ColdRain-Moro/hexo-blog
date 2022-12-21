---
title: 给Idea的Terminal设置代理
date: 2022-12-21
author: 寒雨
hide: false
categories: 笔记
tags:
  - Idea
---

# 给Idea的Terminal设置代理

虽然idea有一个代理设置，但它基本上只作用于Plugin和Plugin Market，对于gradle或者cargo这种包管理工具并没有什么用，甚至对git也没有什么用（至少在我的linux机器上，直接打开终端跑他们都是走代理的，但在idea上跑就是不走代理）。我忍这种情况已经很久了，但一直想不到解决方案。

然后某天突然想到idea有个终端，难道这些任务其实是在idea的终端里面跑的吗？于是去试了下在idea的终端里跑命令，果然是不走代理的。

那这问题不就解决了吗，直接找到idea终端环境变量的设置，把代理设置给配置上

![image-20221221104523267](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/image-20221221104523267.png)

设置完了重启idea之后干啥都快，cargo一眨眼就跑完了，gradle也快了很多，感情我之前是一直没用上代理啊？