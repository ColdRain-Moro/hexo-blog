---
title: Kotlin 泛型协变/逆变学习笔记
date: 2021-11-13
author: 寒雨
hide: false
summary: Kotlin协变/逆变笔记
categories: 笔记
tags:
  - Kotlin
---

# Kotlin 泛型协变/逆变学习笔记

## 协变

### 我的理解

设想以下情况: Student是Person的子类

我们定义了一个Data\<T>(val data: T)作为容器来存放他们

函数test接受一个类型为Data\<Person>的参数,我们手上有一个类型为Data\<Student>的实例

我们理所当然的把它作为参数传入test函数，却发现编译无法通过

这时你傻眼了，原来Data\<Student>跟本无法作为一个Data\<Person>的参数传入函数，也就是没法隐式向下转型

但我们发现，使用List这样的容器是允许这样做的

~~~kotlin
open class Person(val name: String)
class Student(name: String, val level: Int) : Person(name)
class Data<T>(val data: T)

fun test(people: List<Person>) {
    TODO()
}

fun test(people: Data<Person>) {
    TODO()
}

fun main() {
    val studentList = arrayListOf(
        Student("xxx", 6),
        Student("xxx", 6)
    )
    val data = Data(Student("xxx", 6))
    test(data) // 编译不能通过
    test(studentList) // 编译可以通过
}
~~~



这是因为List这个类型用到了泛型的协变，这类问题我们应该使用泛型的协变来处理

实际上Java为了杜绝安全隐患，是不允许这样传递参数的。换句话说，即使 Student是Person的子类，SimpleData并不是SimpleData的子 类。

但稍作思考，像crossinline那样，我们可以做一个约定来避免类型转换的安全隐患。如果我们约定泛型T是只读的话（也就是不能改变)，也就能避免类型转换的安全隐患，但那样就意味着我们这个类的参数中不能含有泛型。这样持有泛型的类型便会拥有泛型类型的继承关系。

这里引用一下《第一行代码: 第三版》中对泛型协变的定义

> 假如定义了一个MyClass的泛型类，其中A 是B的子类型，同时MyClass<A>又是MyClass<B>的子类型，那么我们就可以称MyClass在T这个泛型上是协变的。

### 屁话多！如何使用

只需要在声明泛型时在前面加上out修饰符即可，之后你便需要遵守协变的约定

~~~kotlin
open class Person(val name: String)
class Student(name: String, val level: Int) : Person(name)
// 声明泛型时在前面加个out即可规定这个类在这个泛型上是协变的
class Data<out T>(val data: T) {

    // 不合法，因为外部可以访问并修改这个变量
    // 编译不通过
    var value: T = TODO()
    // 合法，外部无法访问这个变量
    private var value2: T = TODO()
    // 合法，因为这是常量，常量值无法被修改
    val value3: T = TODO()

    // 不合法，因为协变规定了不能在方法参数中使用泛型
    // 编译不通过
    fun func(input: T) {
        TODO()
    }

    // 这样做是合法的，方法的返回值可以使用泛型
    fun func(): T {
        TODO()
    }
}

fun test(people: List<Person>) {
    TODO()
}

fun test(people: Data<Person>) {
    TODO()
}

fun main() {
    val studentList = arrayListOf(
        Student("xxx", 6),
        Student("xxx", 6)
    )
    val data = Data(Student("xxx", 6))
    test(data) // 使用协变后 编译通过
    test(studentList) // 编译可以通过
}
~~~

## 逆变

协变让我们可以将Data\<Student>隐式向上转型变成Data\<Person>

那么逆变自然是让我们可以向下转型，并且它是隐式的

只要我们约定泛型不会在返回值中使用，就可以让持有泛型的类**隐式的**向下转型 (隐式的向上转型意味着这可能不会像协变那样安全)

### 使用示例

~~~kotlin
open class Person(val name: String)
class Student(name: String, val level: Int) : Person(name)

interface Transformer<in T> {
    fun transform(t: T): String
}

fun main() {
    val trans = object : Transformer<Person> {
        override fun transform(t: Person): String {
            return t.name
        }
    }
    handleTransformer(trans) // 如果不声明逆变 这行代码无法通过编译
}

fun handleTransformer(trans: Transformer<Student>) {
    val student = Student("Tom", 6)
    val result = trans.transform(student)
}

~~~



## @UnsafeVariance注解

在你违反了协变/逆变的约定时，可以使用这个注解让编译通过

但正如它的字面意思，**它不安全**

在迫不得已要使用它的情况下，你必须清楚你在做什么

### 使用示例

~~~kotlin
class Data<out T>(val data: T) {

    // 不合法，因为外部可以访问并修改这个变量
    // 使用@UnsafeVariance注解，编译通过
    var value: @UnsafeVariance T = TODO()
    // 合法，外部无法访问这个变量
    private var value2: T = TODO()
    // 合法，因为这是常量，常量值无法被修改
    val value3: T = TODO()

    // 不合法，因为协变规定了不能在方法参数中使用泛型
    // 使用@UnsafeVariance注解，编译通过
    fun func(input: @UnsafeVariance T) {
        TODO()
    }

    // 这样做是合法的，方法的返回值可以使用泛型
    fun func(): T {
        TODO()
    }
}
~~~



