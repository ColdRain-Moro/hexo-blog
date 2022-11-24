---
title: 利用Javassist & Javagent实现类的热替换
date: 2021-11-19
author: 寒雨
hide: false
summary: 之前Javassist使用中的疑惑终于被我解决了
categories: 笔记
tags:
  - Kotlin
  - Java
  - 外部库
  - 字节码操作
---

# 利用Javassist & Javagent实现类的热替换

> 几天前写红岩作业的时候，发现其中的一个level非常有意思
>
> 让我们定义一个Hero类，再定义一个Boss类。设定Boss的属性远大于Hero，Hero绝无战胜Boss的可能性
>
> 作业要求是让我们给Hero开个挂，秒杀Boss
>
> 出这个作业的学长大概只是想考察我们对反射的掌握程度，但我发现这个作业可以整花活（因为前段时间研究了ASM和Javassist）
>
> 同时我也想借这个机会解决我之前研究Javassist时碰到的疑惑
>
> 于是就有了这篇文章

## Javassist对热替换的实现方式

我之前研究了很久，到处找资料也没研究出来怎么整。不过这次我终于在网络上找到了线索，并且初步了解了它的原理。

> 正常来说，只靠Java代码是没法替换一个已经加载到SystemClassLoader里的类的。（如果是别的ClassLoader加载的类，也许可以让加载这个类的ClassLoader不可达再手动调用gc来达到让这个类被作为垃圾回收的目的来删除一个类）但一串神奇的VM Options让我们拥有了从代码层面覆写一个类的能力。

~~~
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000
~~~

对于这行options的作用我并不是很清楚，但它确实让Javassist的Hotswapper类有了连接VM的能力，从此热覆写一个类的字节码便从技术层面可行了。

美中不足的是只有加了这行Options才能达到效果

## 关键代码

~~~kotlin
/**
 * hk.asgard.rain.lesson4.Lv4
 * 4thWork
 * 三种开挂解决方案
 * 反射 javassist生成新类 热替换
 *
 * @author 寒雨
 * @since 2021/11/18 10:58
 **/
fun main() {
    var hero: Entity = Hero()
    val boss = Boss()
//    bypass(hero)
//    hero = javassistByPass(hero)
    hotSwap()
    if (boss.speed > hero.speed) {
        // Boss 先手 秒杀
        println("英雄被Boss秒杀啦")
    } else {
        // hero 先手
        if (hero.damage >= boss.health) {
            println("英雄开挂秒杀了Boss")
        } else {
            println("英雄先手没能干掉Boss，被Boss反杀")
        }
    }
}

/**
 * 开挂(反射)
 */
fun bypass(hero: Entity) {
    hero.setProperty("damage", 999999)
    hero.setProperty("speed", 400)
}

// 用javassist生成新类并加载
fun javassistByPass(hero: Entity): Entity {
    // 获取ctClass
    val ctClass = ClassPool.getDefault().get("hk.asgard.rain.lesson4.lv4.Hero")
    // 改名，否则重复加载会抛异常
    ctClass.name = "hk.asgard.rain.lesson4.lv4.HeroEdited"
    // 从ctClass获取方法
    val ctMethodDamage = ctClass.getDeclaredMethod("getDamage")
    val ctMethodSpeed = ctClass.getDeclaredMethod("getSpeed")
    ctMethodDamage.setBody("""{
        return 999999L;
    }""")
    ctMethodSpeed.setBody("""{
        return 400;
    }""")
    return ctClass.toClass().newInstance() as Entity
}

// 热替换
// 需要jvm选项 -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000 并且implementation tools.jar
fun hotSwap() {
    // 获取ctClass
    val ctClass = ClassPool.getDefault().get("hk.asgard.rain.lesson4.lv4.Hero")
    // 从ctClass获取方法
    val ctMethodDamage = ctClass.getDeclaredMethod("getDamage")
    val ctMethodSpeed = ctClass.getDeclaredMethod("getSpeed")
    ctMethodDamage.setBody("""{
        return 999999L;
    }""")
    ctMethodSpeed.setBody("""{
        return 400;
    }""")
    val swap = HotSwapper(8000)
    swap.reload("hk.asgard.rain.lesson4.lv4.Hero", ctClass.toBytecode())
}
~~~

## 注意事项

> 使用HotSwapper不止需要导入Javassist库，还需要导入tools.jar

