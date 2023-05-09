---
title: 各种语言中多路复用(但不是io)机制的应用
date: 2023-05-09
author: 寒雨
hide: false
summary: 用三种语言写一个类reactor模型的文件搜索
categories: 笔记
tags:
  - rust
  - go
  - java
  - epoll
---

很久没写博客了，水一篇

昨天看CW的老视频，有一篇讲 go 并发编程的视频感觉讲得非常好，于是自己再手写了一下他的例子，并准备用 rust 重写一遍。

~~~go
package main

import (
  "fmt"
  "io/ioutil"
  "time"
)

var query = "test"
var matches int
var workerCount = 0
var maxWorkerCount = 32
var searchRequest = make(chan string)
var workerDone = make(chan bool)
var findMatch = make(chan bool)

func main() {
  start := time.Now()
  workerCount = 1
  go search("/Users/rain/", true)
  waitForWorkers()

  fmt.Println(matches, "matches")
  fmt.Println(time.Since(start))
}

func waitForWorkers() {
  for {
    select {
    case path := <-searchRequest:
      workerCount++
      go search(path, true)
    case <-findMatch:
      matches++
    case <-workerDone:
      workerCount -= 1
      if workerCount == 0 {
        return
      }
    }
  }
}

func search(path string, master bool) {
  files, err := ioutil.ReadDir(path)
  if err == nil {
    for _, file := range files {
      name := file.Name()
      if name == query {
        findMatch <- true
      }
      if file.IsDir() {
        if workerCount < maxWorkerCount {
          // 有人干，交给他
          searchRequest <- path + name + "/"
        } else {
          // 没人干，自己干
          search(path+name+"/", false)
        }
      }
    }
  }
  // err = nil的情况下也要注意关闭协程，不然要死锁
  // 有些文件读不了，没权限
  if master {
    workerDone <- true
  }
}
~~~

顺便复习了一下 tokio，久了没写 rust 复健一下。tokio 也提供了 `select!` 以便实现类似 go 的 select 操作。

~~~rust
use std::fs;
use std::sync::{Arc, Mutex};
use tokio::select;
use tokio::sync::mpsc::{channel, Sender};
use tokio::time::Instant;

const QUERY: &'static str = "test";

#[tokio::main]
async fn main() {
    let now = Instant::now();
    let mut worker_count = 1;
    let mut matches = 0;
    // 请求增加worker
    let (tx_req, mut rx_req) = channel::<String>(1);
    // worker 任务完成
    let (tx_done, mut rx_done) = channel::<()>(1);
    // 请求增加结果数
    let (tx_find, mut rx_find) = channel::<()>(1);
    let tx_req_1 = tx_req.clone();
    let tx_done_1 = tx_done.clone();
    let tx_find_1 = tx_find.clone();
    tokio::spawn(async move {
        search("/Users/rain/", tx_req_1, tx_done_1, tx_find_1).await;
    });
    loop {
        select! {
            Some(path) = rx_req.recv() => {
                worker_count += 1;
                let tx_req = tx_req.clone();
                let tx_done = tx_done.clone();
                let tx_find = tx_find.clone();
                tokio::spawn(async move {
                    search(&path, tx_req, tx_done, tx_find).await;
                });
            }
            _ = rx_done.recv() => {
                worker_count -= 1;
                if worker_count == 0 {
                    break
                }
            }
            _ = rx_find.recv() => {
                matches += 1;
            }
        }
    }
    let duration = Instant::now() - now;
    println!("{}, matches", matches);
    println!("{}ms", duration.as_millis());
}

async fn search(path: &str,
    tx_req: Sender<String>,
    tx_done: Sender<()>,
    tx_find: Sender<()>) {
    if let Ok(entries) = fs::read_dir(path) {
        for entry in entries {
            if let Ok(entry) = entry {
                if entry.file_name() == QUERY {
                    tx_find
                        .send(())
                        .await
                        .unwrap();
                }
                let path = entry.path();
                let path = path.to_str();
                if let Ok(meta) = entry.metadata() {
                    if meta.is_dir() && matches!(path, Some(str)) {
                        tx_req
                            .send(path.unwrap().to_string())
                            .await
                            .unwrap();
                    }
                }
            }
        }
    }
    tx_done
        .send(())
        .await
        .unwrap();
}
~~~

写着写着就发现，这是不是跟之前看 Java NIO 差不多？select 这个操作不是很像 linux epoll 多路复用 I/O 吗？但仔细看的话其实它复用的并不是I/O操作，而是I/O操作所在协程对应的 channel。