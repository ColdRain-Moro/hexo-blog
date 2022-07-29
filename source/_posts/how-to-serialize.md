---
title: 序列化的两种常见做法
date: 2021-07-20 23:52:12
author: 寒雨
hide: false
summary: 记录下Java/Kotlin序列化对象的两种做法
categories: 笔记
tags:
  - Kotlin
  - Java
  - 外部库
---

最常见的做法无非两种：序列化成**json**或者**base64**

## Json

要将一个实例序列化成Json信息一般都需要借助**外部库**

比较常用的库有两种：谷歌的**gson**，阿里的**fastjson**

由于我接触的开发者们都比较青睐gson，而且Spigot核心甚至内置了一个gson库（虽然版本有点老了）

所以对我个人而言，使用gson进行序列化操作更加容易

只需要短短数行代码，便能轻松的序列化/反序列化一个实例

```kotlin
// 序列化实例
val string: String = Gson().toJson(instance)
// 反序列化
val obj: Any = Gson().fromJson(string, Any::class.java)
// 集合操作
val str: String = Gson().toJson(arrayListOf("1","2"))
val list: ArrayList<String> = Gson().fromJson(str,object : TypeToken<ArrayList<String>>{}.type)
```



但我最开始利用gson序列化的都是一些里面都塞的是原生数据类型的集合或者Map，所以理所当然的认为gson可以直接序列化所有类型的实例

于是我吃了个大亏

在尝试序列化我自己写的类实例化出来的实例时，我发现它们序列化出来都是{}，这导致了我之后反序列化操作造成的**NullPointerException**

要命的是，因为这个空指针，我各种检查自己的代码，检查到怀疑人生，所有的非空检测都做了，就还是会抛出这个异常

说好的**Kotlin**干翻空指针呢！（笑）

直到最后的最后，我检查了数据库中储存的序列化之后储存的数据，才发现这个错误

**原来，Gson序列化自己建的类的实例，是需要做一些操作，将这些类注册到Gson实例中的**

具体操作

```kotlin
// 代码来自 TabooLib io.izzel.taboolib.kotlin.Serializer
// 注册对应类的TypeHierarchAdapter才能序列化这个类的实例
    val gson = GsonBuilder().setPrettyPrinting().excludeFieldsWithoutExposeAnnotation().also {
        it.registerTypeHierarchyAdapter(Location::class.java, TypeLocation())
        it.registerTypeHierarchyAdapter(ItemStack::class.java, TypeItemStack())
        it.registerTypeHierarchyAdapter(SecuredFile::class.java, TypeSecuredFile())
        it.registerTypeHierarchyAdapter(YamlConfiguration::class.java, TypeYamlConfiguration())
        SerializerAdapter.map.forEach { (k, v) ->
            it.registerTypeHierarchyAdapter(k, v)
        }
    }.create()!!

// TypeAdapter
// 这里以Location的TypeAdapter为例
    class TypeLocation : JsonSerializer<Location>, JsonDeserializer<Location> {

        override fun serialize(a: Location, p1: Type, p2: JsonSerializationContext): JsonElement {
            return JsonObject().also {
                it.addProperty("world", a.world!!.name)
                it.addProperty("x", a.x)
                it.addProperty("y", a.y)
                it.addProperty("z", a.z)
                it.addProperty("yaw", a.yaw)
                it.addProperty("pitch", a.pitch)
            }
        }

        override fun deserialize(a: JsonElement, p1: Type?, p2: JsonDeserializationContext): Location {
            return Location(
                Bukkit.getWorld(a.asJsonObject.get("world").asString),
                a.asJsonObject.get("x").asDouble,
                a.asJsonObject.get("y").asDouble,
                a.asJsonObject.get("z").asDouble,
                a.asJsonObject.get("yaw").asFloat,
                a.asJsonObject.get("pitch").asFloat
            )
        }
    }


```

在GsonBuilder中注册类和Adapter后构造出来的Gson实例便可以序列化/反序列化对应的类

操作算不上复杂，但也不算轻松

对于只是想把实例存数据库的我来说，这些操作还是有些繁琐了

所以，如果只是想把实例扔数据库里储存，使用**Base64**更加合适

## Base64

base64不需要像gson那样做繁琐的操作，就可以对一个实例进行轻松的序列化/反序列化操作

并且，在现有的Java版本中，使用Base64不再需要借助任何外部库

**唯一的缺点是，它序列出来的字符串并不像Json字符串，可以用肉眼看出来其中蕴含的信息**

但在数据库操作中，我们并不需要让用户知道这些字符的含义，并修改它们

所以，用它序列化实例再扔进SQL实在是再合适不过了

上代码

```kotlin
// 代码来自SacredHUD
// Base64 encode
fun HashMap<String, BitMapData.Personal>.toBase64(): String {
    ByteArrayOutputStream().use { byteArrayOutputStream ->
        BukkitObjectOutputStream(byteArrayOutputStream).use { bukkitObjectOutputStream ->
            bukkitObjectOutputStream.writeObject(this)
            return Base64.getEncoder().encodeToString(byteArrayOutputStream.toByteArray())
        }
    }
}

// Base64 decode
@Suppress("UNCHECKED_CAST")
fun String.base64ToBitmapData(): HashMap<String, BitMapData.Personal> {
    ByteArrayInputStream(Base64.getDecoder().decode(this)).use { byteArrayInputStream ->
        BukkitObjectInputStream(byteArrayInputStream).use { bukkitObjectInputStream ->
            return bukkitObjectInputStream.readObject() as HashMap<String, BitMapData.Personal>
        }
    }
}
```