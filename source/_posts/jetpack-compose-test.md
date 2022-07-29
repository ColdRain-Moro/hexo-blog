---
title: 初试Jetpack Compose
author: 寒雨
hide: false
summary: 用Jetpack Compose尝试仿写了Github App的部分内容
categories: 杂谈
tags:
  - Kotlin
  - Compose
  - Android
---

# 初试Jetpack Compose

今天写WanAndroid写得头晕目眩，便想换换脑子学点别的东西，于是我去了解了一下***Jetpack Compose***。并尝试用它仿写了Github App的部分内容。

我一向是对DSL风格的编程十分向往的，因为我感觉这样写代码就跟写诗一样优雅。而UI编程其实一直是我的痛点。曾经在Minecraft插件开发中，我是很不擅长编写UI的。所幸Android提供了一套xml语法糖来将大部分UI逻辑与逻辑代码分离，让我对Android的ui开发还算得心应手，但我仍然十分向往使用逻辑代码来构造UI界面。于是我听说了Jetpack Compose，一种使用DSL风格的Jetpack UI框架，直接戳爆了我。

于是在一个上午，我被我写的WanAndroid的代码恶心得死去活来，气得关闭了Android Studio。想着刷刷掘金，看到了一篇Compose的文章，于是就学了一上午的Compose，然后有了这个demo。

## 代码

~~~kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ComposeTestTheme() {
                Main()
            }
        }
    }

    @Composable
    fun Main(
        avatar: String = "https://gitee.com/coldrain-moro/images_bed/raw/master/images/chino.jpg",
    ) {
        var selectedItem by remember { mutableStateOf(0) }
        val items = listOf("主页", "通知", "搜索")
        Scaffold(
            bottomBar = {
                BottomNavigation(
                    backgroundColor = Color.White,
                    modifier = Modifier.height(50.dp)
                ) {
                    items.forEachIndexed { index, item ->
                        BottomNavigationItem(
                            icon = {
                                when(index){
                                    0 -> Icon(Icons.Filled.Home, contentDescription = null)
                                    1 -> Icon(Icons.Filled.Notifications, contentDescription = null)
                                    else -> Icon(Icons.Filled.Search, contentDescription = null)
                                }
                            },
                            label = { Text(item) },
                            selected = selectedItem == index,
                            onClick = { selectedItem = index },
                        )
                    }
                }
            }
        ) {
            Column(
                Modifier.padding(10.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Surface(
                        shape = CircleShape,
                    ) {
                        Image(
                            painter = rememberImagePainter(data = avatar),
                            contentDescription = null,
                            modifier = Modifier.size(40.dp),
                            contentScale = ContentScale.Crop
                        )
                    }
                    Text(
                        text = "主页",
                        style = TextStyle(
                            fontWeight = FontWeight.Bold,
                            fontSize = 20.sp
                        ),
                        modifier = Modifier.padding(15.dp)
                    )
                }
                Text(
                    text = "我的工作",
                    style = TextStyle(
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp
                    ),
                    modifier = Modifier.padding(top = 30.dp, bottom = 20.dp)
                )
                WorkSelection(icon = R.drawable.ic_issue_opened, text = "议题", Color(0xFF25CA25))
                WorkSelection(icon = R.drawable.ic_pull_request, text = "拉取请求", Color(0xFF11ABF1))
                WorkSelection(icon = R.drawable.ic_git_repository_line, text = "仓库", Color(0xFF8811F1))
                WorkSelection(icon = R.drawable.ic_organization, text = "组织", Color(0xFFF18C11))
                Divider(
                    color = Color.Gray,
                    modifier = Modifier.padding(top = 10.dp)
                )
                    Column(
                        Modifier.padding(vertical = 10.dp)
                    ) {
                        Text(
                            text = "收藏夹",
                            style = TextStyle(
                                fontWeight = FontWeight.Bold,
                                fontSize = 16.sp
                            ),
                            modifier = Modifier.padding(bottom = 10.dp)
                        )
                        Text(
                            text = "将仓库加入收藏夹以便随时快速访问，而无需搜索",
                            style = TextStyle(
                                fontSize = 16.sp
                            ),
                            modifier = Modifier.padding(top = 10.dp)
                        )
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 10.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Card(
                                modifier = Modifier.padding(horizontal = 20.dp),
                                shape = RoundedCornerShape(20)
                            ) {
                                Button(
                                    onClick = { /*TODO*/ },
                                    elevation = null,
                                    modifier = Modifier.fillMaxWidth(),
                                    shape = RoundedCornerShape(20),
                                    colors = ButtonDefaults.buttonColors(
                                        backgroundColor = Color.Transparent
                                    )
                                ) {
                                    Text(
                                        text = "添加收藏",
                                        style = TextStyle(
                                            fontSize = 14.sp,
                                            color = Color(0xFF229DD5)
                                        ),
                                        modifier = Modifier.padding(10.dp)
                                    )
                                }
                            }
                        }
                    }
            }
        }
    }

    @Composable
    fun WorkSelection(
        icon: Int,
        text: String,
        color: Color
    ) {
        Row(
            Modifier.padding(vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 圆角icon
            Surface(
                shape = RoundedCornerShape(10),
                modifier = Modifier.padding(end = 20.dp)
            ) {
                Image(
                    painter = painterResource(id = icon),
                    contentDescription = null,
                    modifier = Modifier
                        .size(30.dp)
                        .background(color),
                    colorFilter = ColorFilter.tint(Color.White)
                )
            }
            Text(
                text = text,
                style = TextStyle(
                    fontSize = 15.sp
                )
            )
        }
    }

    @Preview
    @Composable
    fun Preview() {
        Main()
    }
}
~~~

## 效果

感觉还行，学习一上午Compose的成果

![](https://gitee.com/coldrain-moro/images_bed/raw/master/images/Screenshot_2021-12-24-22-32-59-446_kim.bifrost.co.jpg)