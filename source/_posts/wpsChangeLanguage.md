---
title: ManjaroWPS切换中文问题
date: 2020-01-15 13:39:27
tags: [linux,manjaro]
categories: 问题解决
photos: /img/banner/images/19.jpg
description: Manjaro WPS切换中文
---

> `wps`在前几天更新之后，界面语言变成了英文，本来没有很太在意，觉得可能过几天更新就好了，但等了几天好像并没有更新的迹象，于是寻找方法进行修复...

<!--more-->

1. 首先打开[AUR仓库](https://aur.archlinux.org)，查看`wps-office`有关的包，发现了`wps-office-cn`

2. 查看其依赖，发现了`wps-office-mui-zh-cn (optional) – zh_CN support for WPS Office`

3. 得到修复方法，即手动安装语言包：

   ```bash
   yay -S wps-office-mui-zh-cn
   ```

   重新打开`wps`，不出意外的话应该已经修复成功了（因为`wps`优先使用系统语言），如果没有成功的话，手动点击右上角的`A`图标，在里面选择中文语言包进行切换即可。