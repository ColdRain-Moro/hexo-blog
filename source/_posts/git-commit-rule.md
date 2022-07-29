---
title: Git Commit 规范
date: 2021-10-28 15:14:52
author: 寒雨
hide: false
summary: git commit规范
categories: 笔记
tags:
  - git
---

# Commit 规范

copy的学长的git教程。

以前都没怎么注意commit这方面的规范，以后要多加注意

> 描述写法如下：
>
> ```
> [type]title
> describtion
> ```
>
> type如下：
>
> - fix -------------> bug 修护
> - feature -------> 需求
> - optimize ------> 优化
> - release --------> 版本升级
> - style ------------> 代码格式调整，不涉及代码更改
>
> title：需求标题（对于该commit的简单描述）
>
> describtion：需求的具体描述（如果过于简单的提交可以不用写该部分）
>
> 若提交消息有说明遗漏，可以通过 [Amend](#Amend 按钮) 进行补救