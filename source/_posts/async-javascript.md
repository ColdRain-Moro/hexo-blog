---
title: 对异步概念上的理解以及JavaScript异步操作实现方式
date: 2021-11-29
author: 寒雨
hide: false
summary: 今天红岩前端上课的笔记
categories: 笔记
tags:
  - javascript
  - 知识梳理
---

# 对异步概念上的理解

> 对异步这个单词我早已不陌生了，从去年开始做bukkit开发开始就一直在接触这个词。然而我却从来没有真正理解过异步的含义，之前我实际上是把多线程与异步混淆了。异步操作实际上是完全可以在单线程上执行的

## 什么是异步？

很简单，正所谓**连续**的操作就叫**同步**，**不连续**的操作就叫**异步**。

这样一看，就很好理解了。在多线程的执行环境中，我们启动一个子线程，这个子线程是**串行**执行的，自然是不连续的。

那么单线程中的异步操作时怎么实现的？

答案是，先执行完同步代码，最后逐个执行异步队列中的回调函数。

例如javascript中的异步 （单线程）

~~~javascript
console.log("Hello")
// 最后执行
setTimeout(() => {
   // 操作
   console.log("Hello World")
}, 500)
console.log("World")
~~~

输出结果:

~~~
Hello
World
Hello World
~~~

## JavaScript中的异步实现方式

> JavaScript中的异步除了Web Worker均为单线程实现

### 回调

小心**回调地狱**

回调函数不断嵌套，导致代码可读性大幅下降

~~~javascript
setTimeout(function () {
  console.log("超哥起床");
  if(超哥睡回笼觉==true){
  setTimeout(function(){
       console.log("超哥回到床上超哥睡觉)
  },500)
  else(超哥睡回笼觉==false){
   setTimeout(function () {
    console.log("超哥刷牙");
    setTimeout(function () {
      console.log("超哥洗脸");
      setTimeout(function () {
        超哥上厕所;
      }, 3000);
    }, 500);
  }, 500);
  }
}, 500);
~~~

### Promise

> Promise本意是承诺，在程序中的意思就是承诺我过一段时间后会给你一个结果。 什么时候会用到过一段时间？答案是异步操作，异步是指可能比较长时间才有结果的才做，例如网络请求、读取本地文件等

使用Promise进行异步操作会提高代码可读性 （摆脱回调地狱）

#### then/catch 链式调用

用法类似Java的CompletableFuture，进行链式调用，可以传参。

不一样的是多了一个异常处理的回调，个人感觉比CompletableFuture好使。

~~~javascript
let p = new Promise((resolve, reject) => {
    //做一些异步操作
    setTimeout(() => {
        console.log('执行完成');
       if （我找到对象了==true）resolve("好耶");
       else reject("也许你可以把标准放开一点")
    }, 2000);
}).then((data)=>{
     console.log(data)
     return data
     //此时输出data为resolve传入的参数
},(error)=>{
     console.log(error)
     //此时输出error为reject传入的参数
}).then((data)=>{
   console.log(data)
   return data 
   //好耶
}).then((data)=>{
   console.log(data)
   //好耶
}).then((data)=>{
   console.log(data)
   //undefined
}).catch((error)=>{
    console.log(data)
})
~~~

#### all/race 多个异步操作的同步处理

- all 全部任务执行完毕后执行下一个任务

  >Promise的all方法提供了并行执行异步操作的能力，并且在所有异步操作执行完后才执行回调。

  ~~~javascript
  let Promise1 = new Promise(function(resolve, reject){})
  let Promise2 = new Promise(function(resolve, reject){})
  let Promise3 = new Promise(function(resolve, reject){})
  
  let p = Promise.all([Promise1, Promise2, Promise3])
  
  p.then(funciton(){
    // 三个都成功则成功  
  }, function(){
    // 只要有失败，则失败 
  })
  ~~~

- race 多个任务进行比赛

  ***我选择最快的那个！***

  > race方法传入多个promise参数，返回值为其中最快执行完成的promise

  ~~~javascript
   //请求某个图片资源
      function requestImg(){
          var p = new Promise((resolve, reject) => {
              var img = new Image();
              img.onload = function(){
                  resolve(img);
              }
              img.src = '图片的路径';
          });
          return p;
      }
      //延时函数，用于给请求计时
      function timeout(){
          var p = new Promise((resolve, reject) => {
              setTimeout(() => {
                  reject('图片请求超时');
              }, 5000);
          });
          return p;
      }
      Promise.race([requestImg(), timeout()]).then((data) =>{
          console.log(data);
      }).catch((err) => {
          console.log(err);
      });
  ~~~

### async/await

实际上他们是基于promise实现的，它们的作用就是让你异步执行的代码同步

> async用来修饰一个方法，在async修饰的方法中可以使用await来修饰一个方法的调用。
>
> 有点类似于kotlin协程中的suspend 挂起函数 与 Deffered#await方法
>
> 但js可没有什么乱七八糟的协程作用域和上下文，毕竟这些实际上都是在单线程环境下运行的

**举个栗子**

~~~javascript
// await修饰符只能影响像这样返回一个promise的函数和被async修饰的函数
const step = (size, time, ele) => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            ele.style.marginLeft = `${size}px`
            resolve(size)
        }, time)
    })
}

// 这里await会让原本异步的方法同步，也就是这里step方法彻底执行完毕才会进入下一次循环
async function asyncAnimation(id) {
    const ele = document.getElementById(id)
    for (let i = 1; i <= 200; i++) {
        await step(i + 100, 10, ele)
    }
}

// 顺序执行任务队列
// 让异步队列同步执行
async function awaitAll() {
    await asyncAnimation("one")
    await asyncAnimation("two")
    await asyncAnimation("three")
}

awaitAll()
~~~

#### 一点小彩蛋

##### top await

来自路姐姐的指导（

> 在引用时加一串type="module" 
>
> 可以导入JS模块（下学期内容），还可以使用一些其他JS的新特性，比如 top await，这时 await 就不需要放在 async 函数里才能执行了
>
> 路姐的优雅代码 彳亍

~~~html
<script src="optimize/script.js" type="module" defer></script>
~~~

然后就可以直接在外部调用await

让我们看看路姐的优雅のcode

~~~javascript
const p = document.querySelector('p')
const content = `元丰六年十月十二日夜，解衣欲睡，月色入户
，欣然起行。念无与为乐者，遂至承天寺寻张怀民。怀民亦未寝，相与步于中庭。
庭下如积水空明，水中藻、荇交横，盖竹柏影也。何夜无月？何处无竹柏？但少闲人如吾两人者耳。
`

// 这个函数可以达到类似Java在子线程中调用Thread.sleep的效果
async function sleep(ms) {
    return new Promise(resolve => {
        setTimeout(() => resolve(), ms)
    })
}

for (let i = 0; i < content.length; i++) {
    p.textContent = content.substring(0, i)
    await sleep(200)
}
~~~

这样写就非常彳亍了

##### css自带的动画

~~~css
.circle {
    width: 100px;
    height: 100px;
    border-radius: 100%;
    transition: all 1s;
}

.circle.at-end {
    transform: translateX(200px);
}
~~~

transition: all 1s; 被加上了这一条，位置的改变会有一个丝滑的动画，而1s这个参数决定了移动的时间。
