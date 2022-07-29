---
title: 格 局 打 开
date: 2021-10-17 19:45:42
author: 寒雨
hide: false
summary: 见识到了睡眠排序这种牛逼的算法
categories: 笔记
tags:
  - Golang
  - Coroutine
  - 算法
---

# 格 局 打 开

今天见识到了大佬的牛逼睡排

这个思路震撼到我了，我第一次见识到这种排序方法。虽然是很久以前就有的算法，但是第一次见识到我还是被震惊到了。

再配合上go的协程来实现这个功能，真是妙极了！短短15行代码，让我如醍醐灌顶

我超，这就是同年级的卷王，这位更是红岩之光

代码（不是大佬的代码，是我按照他的代码自己码了一遍，跟大佬代码有部分出入)

```go
// 从真正的大佬那里抄来的代码
// 睡排，开睡！
// 虽然确实是一种非常棒的思路，但由于数字差距较小时较容易产生误差，所以在这里并不太实用
// 或者...我们可以牺牲更多的排序时间来换取它的精确性,即把元睡眠时间增大
func sortSleep(origin []int) []int {
	// 不初始化也可以append
	var edited []int
	var wg sync.WaitGroup
	wg.Add(len(origin))
	for _, i := range origin {
		go func(num int) {
			time.Sleep(time.Duration(num) * time.Millisecond * 10) // 这里如果改为一百，结果就非常准确了，但如果是10，还是非常容易产生误差
			edited = append(edited, num)
			wg.Done()
		}(i)
	}
	wg.Wait()
	return edited
}
```

草，发明睡眠排序的那个人，真寄吧是个天才