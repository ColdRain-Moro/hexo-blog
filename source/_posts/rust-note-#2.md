---
title: Rust笔记其二
date: 2022-05
author: 寒雨
hide: false
summary: 流程控制&模式匹配&方法&泛型&trait
categories: 笔记
tags:
  - Rust
  - Rust学习笔记
---

# Rust笔记其二

## 流程控制

比较类似go吧，if for这些后面跟的表达式都不用用括号包起来

~~~rust
// 这里比较像kotlin，没有采用传统的三元运算符
let condition = true;
let number = if condition {
        5
    } else {
        6
    };

// 多分支
let n = 6;

if n % 4 == 0 {
    println!("number is divisible by 4");
} else if n % 3 == 0 {
    println!("number is divisible by 3");
} else if n % 2 == 0 {
    println!("number is divisible by 2");
} else {
    println!("number is not divisible by 4, 3, or 2");
}

// for循环
// 有点类似kt, 支持区间
for i in 1..=5 {
   println!("{}", i);
}

// 遍历集合
// 注意所有权的转移，不取引用的话下面就用不了container了
for item in &container {
  // ...
}

// 遍历时修改
for item in &mut collection {
  // ...
}

// 遍历index和值
let a = [4, 3, 2, 1];
// `.iter()` 方法把 `a` 数组变成一个迭代器
for (i, v) in a.iter().enumerate() {
   println!("第{}个元素是{}", i + 1, v);
}

// 无限循环 等价于while(true)
loop {
   println!("again!");
}
~~~

> 值得注意的是，rust的break既可以单独使用，也可以让他返回一个值
>
> loop是一个表达式，因而可以返回一个值

## 模式匹配

> 画重点，rust的模式匹配非常强大，以至于其他语言都在抄

### match

~~~rust
// 这里是比较类似于其他语言switch的用法
// 但match比switch强大得多
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny =>  {
            println!("Lucky penny!");
            1
        },
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}

// match是一个表达式，可以用来赋值
enum IpAddr {
   Ipv4,
   Ipv6
}

fn main() {
    let ip1 = IpAddr::Ipv6;
    let ip_str = match ip1 {
        IpAddr::Ipv4 => "127.0.0.1",
        _ => "::1",
    };

    println!("{}", ip_str);
}

// 模式绑定 （有点像解构）
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState), // 25美分硬币
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        // 这里可以通过这样的写法直接拿到state
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        },
    }
}

// 有时会遇到只有一个模式的值需要被处理，其它值直接忽略的场景，如果用 match 来处理就要写成下面这样
let v = Some(3u8);
match v {
   Some(3) => println!("three"),
   _ => (),
}

// 这种情况下可以直接用语法糖简化
if let Some(3) = v {
    println!("three");
}
~~~

> match的匹配必须穷尽所有的情况，也就是如果不列出所有的可能，必须定义_ =>分支

### matches!宏

> 跟java中的String#matches比较类似，如果我只是想知道某个实例是否匹配上了我给与的模式，可以不用特意去macth,直接调用matches!宏。

~~~rust
// 使用match
let foo = 'f';
let matched = match foo {
    'A'..'Z' | 'a'..'z' => true,
    _ => false,
}

// 使用matches!
let foo = 'f';
let matched = matches!(foo, 'A'..'Z' | 'a'..'z');
~~~

### 解构

解构其实也是模式匹配实现的，在上一节笔记中已经写过了，不做详细介绍

### 匹配守卫

> 在要匹配的模式后面可以加上if condition，来对模式匹配进行进一步限制

~~~rust
fn main() {
    let x = Some(5);
    let y = 10;

    match x {
        Some(50) => println!("Got 50"),
        Some(n) if n == y => println!("Matched, n = {}", n),
        _ => println!("Default case, x = {:?}", x),
    }

    println!("at the end: x = {:?}, y = {}", x, y);
}
~~~

> **匹配守卫的条件会作用于所有的模式**

~~~rust
let x = 4;
let y = false;

match x {
    4 | 5 | 6 if y => println!("yes"),
    _ => println!("no"),
}
~~~

> 这个例子中看起来好像 `if y` 只作用于 `6`，但实际上匹配守卫 `if y` 作用于 `4`、`5` **和** `6` ，在满足 `x` 属于 `4 | 5 | 6` 后才会判断 `y` 是否为 `true`：

### @绑定

> 说白了就是我们即想要模式匹配，匹配成功后又想通过解构的形式拿到对应的值
>
> 小孩子才做选择 大人全都要！

~~~rust
enum Message {
    Hello { id: i32 },
}

let msg = Message::Hello { id: 5 };

match msg {
    Message::Hello { id: id_variable @ 3..=7 } => {
        println!("Found an id in range: {}", id_variable)
    },
    Message::Hello { id: 10..=12 } => {
        println!("Found an id in another range")
    },
    Message::Hello { id } => {
        println!("Found some other id: {}", id)
    },
}
~~~

上面这个例子的第一个分支中，我们既通过解构拿到了id，又对他进行了模式匹配: 在3..=7范围内才能通过。

注意:

> 考虑下面一段代码:
>
> ```rust
> fn main() {
>     match 1 {
>         num @ 1 | 2 => {
>             println!("{}", num);
>         }
>         _ => {}
>     }
> }
> ```
>
> 编译不通过，是因为 `num` 没有绑定到所有的模式上，只绑定了模式 `1`，你可能会试图通过这个方式来解决：
>
> ```rust
> num @ (1 | 2)
> ```
>
> 但是，如果你用的是 Rust 1.53 之前的版本，那这种写法会报错，因为编译器不支持。

## 方法

Rust使用`impl`块来定义方法，多说无益，先来一段示例代码

~~~rust
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Circle {
    // new是Circle的关联函数，因为它的第一个参数不是self
    // 这种方法往往用于初始化当前结构体的实例
    fn new(x: f64, y: f64, radius: f64) -> Circle {
        Circle {
            x: x,
            y: y,
            radius: radius,
        }
    }

    // Circle的方法，&self表示借用当前的Circle结构体
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
~~~

与java的不同在于，要实现一个类似于java类的结构，我们需要定义struct和它的impl，相当于字段的声明和方法的声明被分开了。

并且，impl可以有很多个

~~~rust
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Circle {
    fn new(x: f64, y: f64, radius: f64) -> Circle {
        Circle {
            x: x,
            y: y,
            radius: radius,
        }
    }
}

impl Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
~~~

这样做的好处在于可以让方法的声明更加清晰，我们可以把为完成同一种职能的方法声明在一个impl块中，这样比起塞在一块会有条理得多。

### 关联函数&方法

看到`函数`和`方法`二字我们便可以知晓他们的不同。函数不会绑定在一个对象上，而方法会。

我们先来看一下如何声明关联函数与方法

~~~rust
struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Circle {
    // new是Circle的关联函数，因为它的第一个参数不是self
    // 这种方法往往用于初始化当前结构体的实例
    fn new(x: f64, y: f64, radius: f64) -> Circle {
        Circle {
            x: x,
            y: y,
            radius: radius,
        }
    }

    // Circle的方法，&self表示借用当前的Circle结构体
    fn area(&self) -> f64 {
        std::f64::consts::PI * (self.radius * self.radius)
    }
}
~~~

可以看到，所谓的方法，就是传入了一个`&self`的函数，这是一个语法糖，实际上是 `self: &Self` 的简写。意思是我们传入了一个这个类型的实例的引用。这样在调用时便可以直接`circle.area()`。

而没有传入自身引用的关联函数又是什么呢？我只说四个字——**静态方法**。

### 为枚举实现方法

~~~rust
#![allow(unused)]
fn main() {
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

impl Message {
    fn call(&self) {
        // 在这里定义方法体
    }
}

	let m = Message::Write(String::from("hello"));
	m.call();
}
~~~

## 泛型&特征(trait)

### 声明一个基础的泛型

~~~rust
fn add<T>(a:T, b:T) -> T {
    a + b
}

fn main() {
    println!("add i8: {}", add(2i8, 3i8));
    println!("add i32: {}", add(20, 30));
    println!("add f64: {}", add(1.23, 1.23));
}
~~~

当然可以看出来，这串代码是跑不了的，不是所有类型都允许相加的

### 使用trait约束泛型的类型

那我们就尝试对他的类型进行约束

这里语法比较类似kotlin

~~~rust
fn add<T: std::ops::Add<Output = T>>(a:T, b:T) -> T {
    a + b
}
~~~

这里的`std::ops::Add<Output = T>`是不是比较类似于kotlin的接口？在rust中它叫做`trait `,特征。而实现了`std::ops::Add<Output = T>`,就支持了相加，泛型output就是相加后结果的类型。

> 这些都说明一个道理，特征定义了**一个可以被共享的行为，只要实现了特征，你就能使用该行为**。

### 在枚举中使用泛型

~~~rust
enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
~~~

### 在方法中使用泛型

~~~rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x = {}", p.x());
}
~~~

> 这个例子中，`T,U` 是定义在结构体 `Point` 上的泛型参数，`V,W` 是单独定义在方法 `mixup` 上的泛型参数，它们并不冲突，说白了，你可以理解为，一个是结构体泛型，一个是函数泛型。

### 为具体的泛型类型实现方法

> 对于 `Point<T>` 类型，你不仅能定义基于 `T` 的方法，还能针对特定的具体类型，进行方法定义：
>
> ```rust
> impl Point<f32> {
>     fn distance_from_origin(&self) -> f32 {
>         (self.x.powi(2) + self.y.powi(2)).sqrt()
>     }
> }
> ```
>
> 这段代码意味着 `Point<f32>` 类型会有一个方法 `distance_from_origin`，而其他 `T` 不是 `f32` 类型的 `Point<T> `实例则没有定义此方法。这个方法计算点实例与坐标`(0.0, 0.0)` 之间的距离，并使用了只能用于浮点型的数学运算符。
>
> 这样我们就能针对特定的泛型类型实现某个特定的方法，对于其它泛型类型则没有定义该方法。

### const 泛型

~~~rust
fn display_array<T: std::fmt::Debug>(arr: &[T]) {
    println!("{:?}", arr);
}
fn main() {
    let arr: [i32; 3] = [1, 2, 3];
    display_array(&arr);

    let arr: [i32;2] = [1,2];
    display_array(&arr);
}
~~~

首先看看这段代码，如果我们想要约束传入切片的大小该怎么做呢

const泛型其实就是针对常量值的泛型

~~~rust
fn display_array<T: std::fmt::Debug, const N: usize>(arr: [T; N]) {
    println!("{:?}", arr);
}
fn main() {
    let arr: [i32; 3] = [1, 2, 3];
    display_array(arr);

    let arr: [i32; 2] = [1, 2];
    display_array(arr);
}
~~~

这里我们声明了一个常量泛型usize，这个usize可以放到入参处切片的类型中去，这便是常量泛型的用法。

### 泛型的性能

> 在 Rust 中泛型是零成本的抽象，意味着你在使用泛型时，完全不用担心性能上的问题。
>
> 但是任何选择都是权衡得失的，既然我们获得了性能上的巨大优势，那么又失去了什么呢？Rust 是在编译期为泛型对应的多个类型，生成各自的代码，因此损失了编译速度和增大了最终生成文件的大小。
>
> 具体来说：
>
> Rust 通过在编译时进行泛型代码的 **单态化**(*monomorphization*)来保证效率。单态化是一个通过填充编译时使用的具体类型，将通用代码转换为特定代码的过程。
>
> 编译器所做的工作正好与我们创建泛型函数的步骤相反，编译器寻找所有泛型代码被调用的位置并针对具体类型生成代码。

## 特征(trait)

其实对应的就是java的interface，不过似乎设计得更好

### 定义特征

~~~rust
pub trait Summary {
    fn summarize(&self) -> String;
    
    // 允许有默认实现
    // 默认实现中允许调用其他方法
    fn summarize1(&self) -> String {
        "巴拉巴拉" + self.summarize()
    }
}
~~~

### 为类型实现特征

~~~rust
pub trait Summary {
    fn summarize(&self) -> String;
}
pub struct Post {
    pub title: String, // 标题
    pub author: String, // 作者
    pub content: String, // 内容
}

impl Summary for Post {
    fn summarize(&self) -> String {
        format!("文章{}, 作者是{}", self.title, self.author)
    }
}

pub struct Weibo {
    pub username: String,
    pub content: String
}

impl Summary for Weibo {
    fn summarize(&self) -> String {
        format!("{}发表了微博{}", self.username, self.content)
    }
}
~~~

这样的设计让Rust实现Kotlin那样的拓展函数成为可能。

### 孤儿原则

> 上面我们将 `Summary` 定义成了 `pub` 公开的。这样，如果他人想要使用我们的 `Summary` 特征，则可以引入到他们的包中，然后再进行实现。
>
> 关于特征实现与定义的位置，有一条非常重要的原则：**如果你想要为类型 `A` 实现特征 `T`，那么 `A` 或者 `T` 至少有一个是在当前作用域中定义的！**。例如我们可以为上面的 `Post` 类型实现标准库中的 `Display` 特征，这是因为 `Post` 类型定义在当前的作用域中。同时，我们也可以在当前包中为 `String` 类型实现 `Summary` 特征，因为 `Summary` 定义在当前作用域中。
>
> 但是你无法在当前作用域中，为 `String` 类型实现 `Display` 特征，因为它们俩都定义在标准库中，其定义所在的位置都不在当前作用域，跟你半毛钱关系都没有，看看就行了。
>
> 该规则被称为**孤儿规则**，可以确保其它人编写的代码不会破坏你的代码，也确保了你不会莫名其妙就破坏了风马牛不相及的代码。

### 形参约束

~~~rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}

// 多重约束
pub fn notify(item: &(impl Summary + Display)) {
    //...
}

// 不使用where约束
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {
    //...
}

// 使用where约束
fn some_function<T, U>(t: &T, u: &U) -> i32
    where T: Display + Clone,
          U: Clone + Debug
{
    //...
}
~~~

> 虽然 `impl Trait` 这种语法非常好理解，但是实际上它只是一个语法糖：
>
> ```rust
> pub fn notify<T: Summary>(item: &T) {
>     println!("Breaking news! {}", item.summarize());
> }
> ```

// TODO