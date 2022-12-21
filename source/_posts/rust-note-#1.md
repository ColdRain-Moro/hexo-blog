---
title: Rust笔记其一
date: 2022-05-19
author: 寒雨
hide: false
summary: 变量绑定&解构语法&变量遮蔽&类型推导&异常处理
categories: 笔记
tags:
  - Rust
  - Rust学习笔记
---

# Rust笔记其一

## 变量绑定

> 在其它语言中，我们用 `var a = "hello world"` 的方式给 `a` 赋值，也就是把等式右边的 `"hello world"` 字符串赋值给变量 `a` ，而在 Rust 中，我们这样写： `let a = "hello world"` ，同时给这个过程起了另一个名字：**变量绑定**。
>
> 为何不用赋值而用绑定呢（其实你也可以称之为赋值，但是绑定的含义更清晰准确）？这里就涉及 Rust 最核心的原则——**所有权**，简单来讲，任何内存对象都是有主人的，而且一般情况下完全属于它的主人，绑定就是把这个对象绑定给一个变量，让这个变量成为它的主人（聪明的读者应该能猜到，在这种情况下，该对象之前的主人就会丧失对该对象的所有权），像极了我们的现实世界，不是吗？
>
> 摘自 《Rust Course》

## 解构语法

~~~rust
struct Struct {
    e: i32
}

fn main() {
    let (a, b);

    a = 1;
    b = 2;
    // 数组解构
    let [c,..,d,_] = [1, 2, 3, 4, 5];
    // 结构体解构
    let Struct { e, .. } = Struct { e: 5 };

    assert_eq!([1, 2, 1, 4, 5], [a, b, c, d, e]);
}
~~~

## 变量遮蔽(shadowing)

Rust 允许声明相同的变量名，在后面声明的变量会遮蔽掉前面声明的，如下所示：

```rust
fn main() {
    let x = 5;
    // 在main函数的作用域内对之前的x进行遮蔽
    let x = x + 1;

    {
        // 在当前的花括号作用域内，对之前的x进行遮蔽
        let x = x * 2;
        println!("The value of x in the inner scope is: {}", x);
    }

    println!("The value of x is: {}", x);
}
```

## 类型推导

个人感觉比较类似kt的类型推导吧，要么声明变量类型，要么指定泛型

~~~rust
let guess = "42".parse().except("Not a number"); // 报错，无法推断你想要parse的类型
let guess: i32 = "42".parse().except("Not a number"); // √
let guess = "42".parse::<i32>().expect("Not a number!"); // √
~~~

rust的泛型还要打::，挺怪，但能接受。

## 异常处理

> ## Rust 的错误哲学
>
> 错误对于软件来说是不可避免的，因此一门优秀的编程语言必须有其完整的错误处理哲学。在很多情况下，Rust 需要你承认自己的代码可能会出错，并提前采取行动，来处理这些错误。
>
> Rust 中的错误主要分为两类：
>
> - **可恢复错误**，通常用于从系统全局角度来看可以接受的错误，例如处理用户的访问、操作等错误，这些错误只会影响某个用户自身的操作进程，而不会对系统的全局稳定性产生影响
> - **不可恢复错误**，刚好相反，该错误通常是全局性或者系统性的错误，例如数组越界访问，系统启动时发生了影响启动流程的错误等等，这些错误的影响往往对于系统来说是致命的
>
> 很多编程语言，并不会区分这些错误，而是直接采用异常的方式去处理。Rust 没有异常，但是 Rust 也有自己的卧龙凤雏：`Result<T, E>` 用于可恢复错误，`panic!` 用于不可恢复错误。
>
> 摘自 《Rust Crouse》

我们可以直接使用`panic!`来抛出一个异常，让程序直接崩溃，但一般我们不会这么做。一般我们会大量的使用`Result`来进行异常的传递，毕竟Rust里是没有try catch的，而我们抛出异常的目的一般不会是直接让整个程序崩溃，而是要让其他人去处理这个异常。

讲真，我觉得rust的异常处理设计得简直一级棒，比go和java的不知道高到哪里去了，kotlin的Result API也不过是是对其拙劣的模仿（暴论）~

~~~rust
// expect 如产生错误 直接panic!
let guess = "42".parse::<i32>().expect("Not a number!");

// 比较类似go的异常处理方式，不过语法更加好看
// 不过这种方式写多了会造成多层嵌套
let guess = "42".parse::<i32>();
match guess {
    Ok(num) => println!("You guessed: {}", num),
    Err(err) => println!("Error: {}", err),
}
~~~

同时，为了避免模板代码，rust有一个`?`的语法糖，可以在返回值为Result的函数中使用

~~~rust
use core::time;
use std::{fs::OpenOptions, thread, io::Write};

fn main() -> std::io::Result<()> {
    let mut f = OpenOptions::new().write(true).open("hello.txt")?; // <-
    print!("{:?} \n", f);
    // on the moment, manually remove the file hello.txt
    let ten_millis = time::Duration::from_millis(10000);
    thread::sleep(ten_millis);
    print!("{:?} \n", f);
    let r = f.write_all(b"Hello, world!")?;
    print!("Result is {:?} \n", r);
    drop(f);
    Ok(())
}
~~~

这个`?`对应的模板代码如下

~~~rust
let f = OpenOptions::new().write(true).open("hello.txt");
let mut f = match f{
    Ok(file) => file,
    Err(e) => return Err(e),
};
~~~

如此便大幅简化了开发流程，实属厉害

那么，rust有没有办法捕获异常呢

有

> 最后，再来说个例外，`panic::catch_unwind`。
>
> 先看下它的用法：
>
> ```rust
> use std::panic;
> 
> let result = panic::catch_unwind(|| {
>     println!("hello!");
> });
> assert!(result.is_ok());
> 
> let result = panic::catch_unwind(|| {
>     panic!("oh no!");
> });
> assert!(result.is_err());
> ```
>
> 没错，它的行为几乎就是try/catch了：panic！宏被捕获了，程序并也没有挂，返回了Err。尽管如此，Rust的目的并不是让它成为try/catch机制的实现，而是当Rust和其他编程语言互动时，避免其他语言代码块throw出异常。所以呢，错误处理的正道还是用**Result**。
>
> 从catch_unwind的名字上，需要留意下unwind这个限定词，它意味着只有默认进行栈反解的panic可以被捕获到，如果是设为直接终止程序的panic，就逮不住了。
>
> 细节可进一步参考[Rust Documentation](https://link.zhihu.com/?target=https%3A//doc.rust-lang.org/beta/std/panic/fn.catch_unwind.html)。