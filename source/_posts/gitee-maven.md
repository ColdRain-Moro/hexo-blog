---
title: 利用Gitee搭建了自己的Maven仓库
date: 2021-09-06 00:00:21
author: 寒雨
hide: false
summary: 使用gitee搭建了一个自用maven仓库
categories: 笔记
tags:
  - maven
---

鼓捣了一晚上终于弄出来了......

[maven: 寒雨的maven仓库 (gitee.com)](https://gitee.com/coldrain-moro/maven)

也算是给自己当初偷懒没去多多了解maven补上了一课，出来混，迟早要还的

之所以选择gitee而没有选择github当然是因为速度快

## Note

### 上传jar到仓库的命令

像这样写上传了Tiphareth到本地maven仓库里

```
mvn install:install-file -Dfile=E:\ColdRain_Moro\项目\Tiphareth\build\libs\Tiphareth-1.4.0.jar -DgroupId=ink.ptms.tiphareth -DartifactId=tiphareth -Dversion=1.4.0 -Dpackaging=Jar
```

### 改变默认maven仓库路径

在 settings.xml 中下文标记位置添加如下内容

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
  <!-- localRepository
   | The path to the local repository maven will use to store artifacts.
   |
   | Default: ${user.home}/.m2/repository
  <localRepository>/path/to/local/repo</localRepository>
	下面是要添加的内容
  -->
  <localRepository>E:\ColdRain_Moro\项目\maven\repo</localRepository>
```

### 如何使用

我一般只用gradle，所以这里只标记gradle的使用方式

***gradle yyds***

```
repositories {
    mavenCentral()
    // 添加我的仓库
    maven { url = uri("https://gitee.com/coldrain-moro/maven/raw/master/repo") }
}

dependencies {
	// 导入仓库里的依赖tiphareth
    compileOnly("ink.ptms.tiphareth:tiphareth:1.4.0")
    compileOnly("public:PlaceholderAPI:2.10.9@jar")
    compileOnly("ink.ptms.core:v11605:11605")
    compileOnly(kotlin("stdlib"))
    compileOnly(fileTree("libs"))
}
```

