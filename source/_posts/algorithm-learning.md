---
title: 算法笔记
date: 2022-9-30
author: 寒雨
hide: false
summary: 算法笔记汇总处
categories: 笔记
tags:
  - 算法
---

# 算法笔记

## 双指针

顾名思义就是维护两个指针，多说无益，看例题

> #### [剑指 Offer 22. 链表中倒数第k个节点](https://leetcode.cn/problems/lian-biao-zhong-dao-shu-di-kge-jie-dian-lcof/)
>
> 输入一个链表，输出该链表中倒数第k个节点。为了符合大多数人的习惯，本题从1开始计数，即链表的尾节点是倒数第1个节点。
>
> 例如，一个链表有 6 个节点，从头节点开始，它们的值依次是 1、2、3、4、5、6。这个链表的倒数第 3 个节点是值为 4 的节点。
>
>  
>
> 示例：
>
> >  给定一个链表: 1->2->3->4->5, 和 k = 2.
> >
> > 返回链表 4->5.

~~~js
/**
 * Definition for singly-linked list.
 * function ListNode(val) {
 *     this.val = val;
 *     this.next = null;
 * }
 */
/**
 * @param {ListNode} head
 * @param {number} k
 * @return {ListNode}
 */
var getKthFromEnd = function(head, k) {
    let [fast, slow] = [head, head]
    while (fast && k > 0) {
        [fast, k] = [fast.next, k - 1]
    }
    while (fast) {
        [fast, slow] = [fast.next, slow.next]
    }
    return slow
};
~~~

维护一快一慢两个指针，先将fast指针向前移动k+1位。再将fast与slow同步向前移动，直到fast指针抵达链表尾部空指针，然后返回slow指针。

设指针长度len，首先fast指针向前移动了k+1位，故slow指针与fast一同移动的距离为len-(k+1)，即指向倒数第k个元素。