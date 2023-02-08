---
title: Dangling else (悬空else)
date: 2023-02-09 00:26:00
author: 寒雨
hide: false
categories: 笔记
tags:
  - 编译原理
---

试过在网上找一些文章，发现全是答辩。最后翻了翻龙书就差不多看懂了，在这里谈谈我的理解，顺便水篇博文:D

## 什么是 Dangling else

算是一个经典的上下文无关文法产生二义性的问题。

~~~
stmt -> "if" expr "then" stmt
	|	"if" expr "then" stmt "else" stmt
	|	other
~~~

这是一个言简意骇的一个描述 if else 语句的文法，一眼就能看懂。但它到底能不能使用呢？答案是不能，因为这个文法产生了**二义性**

(同样的一段文字可能被解析为两种或更多不一样的AST)。

举个例子

~~~
if E1 then if E2 then S2 else S3
~~~

这段代码可以被解析成

~~~
if E1 then (if E2 then S2) else S3
~~~

也可以被解析成

~~~
if E1 then (if E2 then S2 else S3)
~~~

这样就在语法上产生了歧义，那肯定不行。

这里我们发现这个 else 并没有一个确定匹配的 if，所以我们把这个问题称为 Dangling else ( 悬空 else )

## 怎么解决 Dangling else

一句话，改写。我们需要改写这个文法，让每个 else 都匹配上一个唯一的 if 。

> 基本思想是在一个 then 和一个 else 之间出现的语句必须是**已匹配的**。也就是说，中间的语句不能以一个尚未匹配的（或者说是开放的）then 结尾。一个已匹配的语句要么是一个不包含开放语句的 if-then-else 语句，要么是一个非条件语句。
>
> 摘自龙书

这个已匹配可能有点不好理解，其实就是这个 if 能不能匹配上一个 else。当然也存在没有 else 的 if 语句，这个语句就被称为未匹配或者开放的。

基于这个思想，我们就能把 if 语句区分为两种类型，已匹配的和未匹配的

~~~
stmt -> matched_stmt
	|	open_stmt
matched_stmt -> "if" expr "then" matched_stmt "else" matched_stmt
	| 	other
open_stmt -> "if" expr "then" stmt
	|	"if" expr "then" matched_stmt "else" open_stmt
~~~

上面的文法会起到把 if 和最近的 else 进行匹配的作用。在网上看到这种文法时十分的蒙圈，看了龙书才逐渐理解。
