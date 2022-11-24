---
title: Android 笔记
date: 2021-12-02
author: 寒雨
cover: true
hide: false
summary: Android中个人常用控件/组件/外部库用法整理 (更新中)
categories: 笔记
tags:
  - Android
  - 知识梳理
  - Kotlin
---

# Android 笔记

## 控件

### RecyclerView

### ViewPager2

### DrawerLayout (侧滑栏)

### CoordinatorLayout （协调者布局)

### Toolbar

### x     private var itemClickListener: (Int) -> Unit = { }​    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {​        init {            view.setOnClickListener {                itemClickListener(bindingAdapterPosition)            }        }​        val fruitImage: ImageView = view.fruitImage        val fruitName: TextView = view.fruitName    }       /**     * 回调传参     */    fun onItemClick(func: (Int) -> Unit) {        itemClickListener = func    }kotlin

### TabLayout

## 组件

### DataBinding

### Paging3

### Room

### LiveData/ViewModel

### LifeCycle

## 外部库

### OkHttp/Retrofit

### Glide

### Flow

### Kotlinx.Corountine (Kotlin协程)

### Kotlinx.Serialization

### LitePal

