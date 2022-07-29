---
title: 为Rust写的后端配置docker
author: 寒雨
hide: false
summary: 直到你开始用rust写后端，发现需要在运行平台编译后才能部署，才明白java跨平台的可贵
categories: 笔记
tags:
  - rust
  - docker
---

# 为Rust写的后端配置docker

最近尝试用rust写了一个后端服务，想部署到服务器上。当然是用docker部署，自从接触了docker，我很快便爱上了它~

然后我发现rust的docker配置似乎与java不同..?java只需要把编译出来的jar扔到docker里面，然后直接java -jar便可以运行，但rust似乎需要把整个代码全部copy到docker中在编译环境编译然后才能部署，然而rust的编译又极其消耗性能，导致我第一次部署时直接把服务器给卡崩了。

后来花了50块给服务器升级成了2c4g，再次尝试部署，这次又出现了经典问题

![2022052901](https://persecution-1301196908.cos.ap-chongqing.myqcloud.com/image_bed/2022052901.png)

怎么办呢，当然是给cargo换镜像源咯。

~~~dockerfile
RUN touch /usr/local/cargo/config.toml

# cargo 上海交大镜像源
RUN sed -e a\[source.crates-io] /usr/local/cargo/config.toml;\
    sed -e a\registry=\"https://github.com/rust-lang/crates.io-index\" /usr/local/cargo/config.toml; \
    sed -e a\replace-with=\'sjtu\' /usr/local/cargo/config.toml; \
    sed -e a\[source.sjtu] /usr/local/cargo/config.toml; \
    sed -e a\registry=\"https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/\"
~~~

这下子就部署成功了

吐槽一下，每次部署都要花大概半个小时，而且cpu占用率能吃到99.75%，编译成功后的镜像大小能达到6个G，实在是不太行。

全部代码

~~~dockerfile
FROM rust

WORKDIR /usr/src/collection-api
COPY . .

RUN touch /usr/local/cargo/config.toml

# cargo 上海交大镜像源
RUN sed -e a\[source.crates-io] /usr/local/cargo/config.toml;\
    sed -e a\registry=\"https://github.com/rust-lang/crates.io-index\" /usr/local/cargo/config.toml; \
    sed -e a\replace-with=\'sjtu\' /usr/local/cargo/config.toml; \
    sed -e a\[source.sjtu] /usr/local/cargo/config.toml; \
    sed -e a\registry=\"https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/\"

# Rustup 清华镜像源
ENV RUSTUP_DIST_SERVER https://mirrors.tuna.tsinghua.edu.cn/rustup

ENV DATABASE_URL *

RUN cargo install --path .

CMD ["collection-api"]
~~~

## 交叉编译

> 在本地编译对应目标系统的产品

如果能用这个的话，那就只需要把产品扔到docker里面，docker源也只需要用最小的airplane了吧。

下次研究。