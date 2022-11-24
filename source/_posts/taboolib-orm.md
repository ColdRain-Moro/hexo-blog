---
title: 写了个Kotlin ORM框架
date: 2022-01-12
author: 寒雨
hide: false
summary: 用动态代理实现了一套基于TabooLib的Kotlin ORM框架
categories: 杂谈
tags:
  - Kotlin	
  - TabooLib
  - MySQL
  - 动态代理
---

# 写了个Kotlin ORM框架

嘛，一直想写框架，又发现TabooLib的数据库虽然有跟ktorm比起来也不差的sql-dsl支持，但却缺少ORM的支持。

虽说直接用ktorm也不是不行，但这可是个绝佳的练手项目。我早八百年前就想写框架了。

## 设计

一个框架也许最重要的就是它的设计，这将决定开发者用得爽不爽。事实证明，好用才是第一位，哪怕效率都得靠边站。

**开发效率第一**

于是为了设计好这个框架，我那天从凌晨1点构思到3点半，最终确定了一套个人觉得非常不错的设计

最开始借鉴了很多Android Jetpack Room的设计，然后结合实际情况改了不少，还顺带给TabooLib的DSL做了支持

如今感觉这套设计青出于蓝，甚至比Room更胜一筹 （个人感觉）

```kotlin
data class ExampleEntity(
    // PrimaryKey 不用写option
    @PrimaryKey(autoGenerate = true)
    @Column(name = "id", type = ColumnTypeSQL.INT)
    val id: Int? = null,
    @Column(name = "type", type = ColumnTypeSQL.TEXT, options = [ColumnOptionSQL.NOTNULL])
    val type: String,
    @Column(name = "user", type = ColumnTypeSQL.TEXT, options = [ColumnOptionSQL.NOTNULL])
    val user: String,
    @Column(name = "user", type = ColumnTypeSQL.TEXT, def = "null")
    val data: String?
)

interface ExampleDAO : IDao<ExampleEntity> {
    @Query("SELECT * FROM {table}")
    fun queryAll(): List<ExampleEntity>

    @Insert
    fun insert(entity: ExampleEntity)
    
    @Query("DELETE FROM {table}")
    fun delete()
    
    @Query("SELECT WHERE id > {id} FROM {table}")
    fun querySome(id: Int): List<ExampleEntity>
    
    // 使用TabooLib DSL语句控制
    @DSL
    fun selectUser(name: String): ExampleEntity? {
        return table.workspace(datasource) {
            select { where { "user" eq name } }
        }.firstOrNull {
            adaptResultSet()
        }
    }
}

object AppDatabase {
    /**
     * 也可通过ORMBuilder#buildFromConf(ConfigurationSection, String)直接构建
     */
    private val builder by lazy {
        ORMBuilder.newBuilder()
            .host("localhost")
            .port(3306)
            .user("root")
            .password("root")
            .database("database")
            .buildHost()
    } 
    
    
    val exampleTableDao by lazy {
        // 表名 DAO类
        builder.build("exampleTable" ,ExampleDAO::class.java)
    }
}
```

## 实现

### 平台

最开始其实我是想做成跨平台项目的，然后提供TabooLib的实现。

然后我发现说实话我对跨平台设计还不是特别了解，于是最后一气之下换成了TabooLib单平台实现。

### 动态代理

最开始其实我是完全没有头绪的，后面看了一下Room的使用方法，麻木的仿写出了一套写法

后来再看了一遍这个写法，联想到了Retrofit，然后想到了Retrofit的底层实现是动态代理

说实话以前没有用过动态代理，于是就去了解了一下子

最后发现这个项目的灵魂就在动态代理，而且其实代码量并不多

### 坑

- Kotlin接口方法默认实现不是基于JDK8以后的default关键字，而是在接口里生成了一个静态内部类以静态方法的形式存放
- ResultSet应该以迭代器的方式使用
- 获取父类/接口的泛型应该使用genericSuperClass/Interfaces
- 返回值类型为void或Unit的方法的returnType不是Void::class.java,也不是Unit::class.java。但它可以用returnType.name == "void"这种形式进行判断