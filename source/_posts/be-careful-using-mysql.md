---
title: 在使用SQL时的一些注意事项
date: 2021-07-22 23:14:42
author: 寒雨
hide: false
summary: 记录一下使用MySQL的一些注意事项
categories: 笔记
tags:
  - MySQL
---

## 尽量避免将大量数据序列化扔一个列里

**尤其是在需要频繁获取/更新这些数据的情况下**
这样一旦数据库储量到达一定级别，**数据库极可能丢失数据**
神域的地牢孤剑便是前车之鉴
**储存方式**

[![7e8c1fed3737e6ab](https://user-images.githubusercontent.com/69996135/126663341-3692ff72-388d-4dea-a216-4021943b5437.png)](https://user-images.githubusercontent.com/69996135/126663341-3692ff72-388d-4dea-a216-4021943b5437.png)

**后果**

[![-2bf7c04dec497124](https://user-images.githubusercontent.com/69996135/126663530-030ca6e0-e7eb-456c-88d0-3ea803a609c0.jpg)](https://user-images.githubusercontent.com/69996135/126663530-030ca6e0-e7eb-456c-88d0-3ea803a609c0.jpg)

[![-3e6ca3264d9d5b3a](https://user-images.githubusercontent.com/69996135/126663547-64e62179-46ca-4696-9fa6-044f57c804f7.jpg)](https://user-images.githubusercontent.com/69996135/126663547-64e62179-46ca-4696-9fa6-044f57c804f7.jpg)

[![54e384ac658f35d9](https://user-images.githubusercontent.com/69996135/126663565-d42a10e9-b5fd-42d6-bb34-edc6aef0d993.jpg)](https://user-images.githubusercontent.com/69996135/126663565-d42a10e9-b5fd-42d6-bb34-edc6aef0d993.jpg)

**知乎**
[![1c4ec094fffaaa6a](https://user-images.githubusercontent.com/69996135/126663612-d738f9d0-ea64-4a05-bc5d-eb6d5917c496.png)](https://user-images.githubusercontent.com/69996135/126663612-d738f9d0-ea64-4a05-bc5d-eb6d5917c496.png)
[![-1edc645b674852e1](https://user-images.githubusercontent.com/69996135/126663622-aea138f4-716b-4186-9ce1-7e531b8e57ce.png)](https://user-images.githubusercontent.com/69996135/126663622-aea138f4-716b-4186-9ce1-7e531b8e57ce.png)
[![-5462c585fd3183db](https://user-images.githubusercontent.com/69996135/126663631-0c50a072-f1c2-4fc9-9d39-887138cb3048.png)](https://user-images.githubusercontent.com/69996135/126663631-0c50a072-f1c2-4fc9-9d39-887138cb3048.png)