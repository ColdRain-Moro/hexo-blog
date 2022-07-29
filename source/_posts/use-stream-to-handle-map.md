---
title: 使用stream对map进行操作
date: 2021-07-21 13:39:41
author: 寒雨
hide: false
summary: 使用java stream api快捷的对map进行一些繁琐的操作
categories: 笔记
tags:
  - Kotlin
  - Java
---

# 使用stream对map进行操作

实在是太方便了

**Kotlin**代码:

```kotlin
// 从一个Map<String,String>中得到一个Map<String,Pattern>
// 只需一行代码
(it["match"] as Map<String,String>).entries.stream().collect(
                        Collectors.toMap(Map.Entry<String,String>::key) { e ->
                            Pattern.compile(
                                e.value.replace("[NUMBER]", "<value>(\\d+(\\.\\d+)?)")
                                    .replace("<NUMBER>", "<value>(\\d+(\\.\\d+)?)")
                            )
                        }
```

**Java**代码

```java
map.entries.stream().collect(Collectors.toMap(Map.Entry<String,String>::getKey, entry -> Pattern.compile(entry.getValue().replace("[NUMBER]", "<value>(\\d+(\\.\\d+)?)").replace("<NUMBER>", "<value>(\\d+(\\.\\d+)?)"))))
```

