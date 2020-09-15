---
title: 从oh my zsh到oh my fish
date: 2020-02-29 21:32:44
tags: [manjaro,linux]
categories: 系统优化
photos: /img/banner/images/21.png
description: 增加shell性能和易用性
---

> 为什么今天连发两篇文章呢？大概是想纪念一下四年一度的`2.29`吧（笑

## 起因

众所周知，`shell`有很多种，其中最常用的有`bash`和`zsh`，而`oh my zsh`是基于`zsh`的一个拓展工具集，自从接触`linux`，我一直在使用`zsh & oh my zsh`。它易用，易拓展，但也有一个很大的缺点：**太！慢！了！**

<!--more-->

想象你需要打开`terminal`切换到`blog`路径，运行`terminal`的瞬间，你开始输入命令，你希望看到的结果：

```bash
~
⟩ j blog
/home/jeasonlau/File/blog

~/File/blog
⟩ 
```

但实际的结果却是：

```bash
j ~
⟩ blog
unknown command : blog

~
⟩ 
```

惊不惊喜？意不意外？

在多次遭遇这种状况后，我实在无法忍受，开始了更换`shell`之路...

## 更换

曾经也听说过另一款著名的`shell`：`fish`。在`NEU lug`群里吐槽`zsh`慢的时候，意外发现几位群友都在使用`fish`，于是决定更换。

搜索`fish`文档，发现`arch`系发行版可以直接安装，于是

```bash
sudo pacman -S fish
```

安装成功之后，使用

```bash
chsh -s /usr/local/bin/fish
```

将默认`shell`更换为`fish`。体验一番后感觉确实比`zsh`快了不少，同时原生支持命令高亮、命令建议等功能，不需要自己去手动配置，可以说是开箱即用了。

## 主题

更换成功之后，更重要的任务是**换主题**！秉持着***(命令行不花里胡哨怎么行！)***的基本原则，我开始搜索`fish`的主题推荐，虽然没有找到什么结果，但让我发现了另一个东西：`oh my fish`。

它是一个类似`oh my zsh`的，对`fish shell`进行拓展的工具，具体来说包括插件和主题，于是参考文档进行安装：

```bash
curl -L https://get.oh-my.fish | fish
```

安装完成之后就可以在[available themes](https://github.com/oh-my-fish/oh-my-fish/blob/master/docs/Themes.md)里进行挑选啦，找到心仪的主题后只需要执行

```bash
omf install <theme name>
```

即可成功安装。

----

把全部主题看了一遍，顺便做一下主题推荐吧。

我个人喜欢的有四款：

1. `pure（慎用）`

   该主题是我在`zsh`上使用的主题，也被移植到了`fish`上，但试用后发现其兼容并不好，总会出一些奇奇怪怪的问题，但因为日久生情，还是将其排在第一位吧。

   ![](https://ae01.alicdn.com/kf/Uffbe1e0148da4a60918f93b724af2118b.png)

   ![](https://ae01.alicdn.com/kf/Uffba5466130345d599327838d73fe6b4l.png)

2. `clearance`

   另一款极简主题，实际使用效果和`pure`相差不多，只是截图显得比较丑。

   ![](https://ae01.alicdn.com/kf/U9c08dad4f1164f7aa192bd5699a2eca11.png)

3. `tomita`

   截图很好看，但默认颜色与截图有部分不同，同时因为鱼标的颜色默认为浅黄，对亮色背景不够友好。（当然也可以自行修改配置文件来修改颜色）

   ![](https://ae01.alicdn.com/kf/U123f29408c5d44598b334cb4310963cfJ.png)

   ![](https://ae01.alicdn.com/kf/Ub3e547843155426f8e4608bc629573dcm.png)

4. `nai`

   如果上面的是极简，这个就是极度极简，但麻雀虽小五脏俱全，简简单单反而有种别样的魅力。

   ![](https://ae01.alicdn.com/kf/U40b5e261943c40aea3e811765095aaf4s.png)

