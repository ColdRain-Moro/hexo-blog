---
title: Android开发笔记其一
date: 2021-10-24 21:06:57
author: 寒雨
hide: false
summary: 一些安卓的笔记
categories: 笔记
tags:
  - Android
---

# Android开发笔记其一

# RecyclerView的onItemClick回调函数在onBindViewHolder中调用会导致性能问题

**反例**

会导致不断的创建匿名类，从而导致大量的性能浪费

```kotlin
   private var itemClickListener: (Int) -> Unit = { }
	
   override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val fruit = data[position]
        holder.fruitImage.setImageResource(fruit.image)
        holder.fruitName.text = fruit.name
        holder.itemView.setOnClickListener {
            itemClickListener(position)
        }
    }

    /**
     * 回调传参
     */
    fun onItemClick(func: (Int) -> Unit) {
        itemClickListener = func
    }
```

**正确的做法**

将回调函数在ViewHolder中调用

```kotlin
    private var itemClickListener: (Int) -> Unit = { }

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {

        init {
            view.setOnClickListener {
                itemClickListener(bindingAdapterPosition)
            }
        }

        val fruitImage: ImageView = view.fruitImage
        val fruitName: TextView = view.fruitName
    }
    
   /**
     * 回调传参
     */
    fun onItemClick(func: (Int) -> Unit) {
        itemClickListener = func
    }
```