---
title: fcitx5使用及调优
date: 2020-08-17 12:45:56
tags: [archlinux,linux,input]
categories: 便捷使用
photos: /img/banner/images/16.jpg
description: 使用fcitx5（Arch Linux + KDE Plasma）
---

最近发现`archlinuxcn`群组里有很多人在用`fcitx5`，我也试着尝了尝鲜 。

> 注意：fcitx5不支持**搜狗输入法**、**百度输入法**等等，对这些输入法情有独钟的用户请忽略此篇文章。
>
> 作者环境：`archlinux`+`kde`。

<!--more-->

## 安装

目前`archlinux`已经有了完整的`fcitx5`支持，对于arch用户，只需要：

```bash
# 卸载fcitx4相关程序
sudo pacman -Rs $(pacman -Qsq fcitx)
# 安装fcitx5框架、配置工具、输入法模块
sudo pacman -S fcitx5-im
# 安装输入法引擎，目前可选fcitx5-chinese-addons/fcitx5-rime/fcitx5-chewing
# rime配置较为复杂，chewing个人没有接触过，本文使用chinese-addons
sudo pacman -S fcitx5-chinese-addons
```

即可成功安装。

接着，如果想要在程序中正常启用`fcitx5`，需要设置一下环境变量：

```bash
# 在~/.xprofile中写入以下内容
export INPUT_METHOD=fcitx5
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
```

## 自启动

`fcitx5`默认不会自启动，想要让其自动启动，可选如下两种途径：

1. 通过桌面环境的自启设置添加`fcitx5`（以kde为例）：

   ![image-20200817131136167](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200817131136167.png)

2. 执行以下命令：

   ```bash
   sudo cp /usr/share/applications/fcitx5.desktop ~/.config/autostart/
   ```

接着重启电脑，在`fcitx5配置`中添加所需要的输入法即可（一般用户请选择Pinyin）：

![image-20200817133730806](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200817133730806.png)

## 皮肤

目前可用的皮肤有限，推荐使用较为美观的[fcitx5-material-color](https://github.com/hosxy/Fcitx5-Material-Color)：

```bash
sudo pacman -S fcitx5-material-color
```

对于其它桌面环境用户，请参照项目`README.md`修改配置文件进行配置。

KDE用户可通过`设置 -> 区域设置 -> 输入法 -> 配置附加组件 -> Classic User Inteface -> 主题` 切换：

![image-20200817132911314](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200817132911314.png)

## 词库

接着是至关重要的词库配置环节。目前仓库中提供了2个词库，分别是：

1. `fcitx5-pinyin-zhwiki`：中文维基百科词条
2. `fcitx5-pinyin-moegirl`：萌娘百科词条

对于使用`fcitx5-chinese-addons`输入法引擎的用户，安装包即可自动启用词库。

除此之外，我们还可以导入搜狗词库：

- 对于 KDE 用户来说，可以通过 `设置 -> 区域设置 -> 输入法 -> Pinyin -> 词典 -> 导入` 来导入搜狗词库。

  ![image-20200817134015025](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200817134015025.png)

- 对于其他用户，需要手动打开 “Fcitx5 配置” 这个软件，并在拼音输入法中手动配置。

## 遇到问题？

1. 参考`arch wiki`：[故障处理](https://wiki.archlinux.org/index.php/Fcitx5#Troubleshooting)。
2. 在该篇文章下留言提问，我会尽量解答。

## 总结

个人看来，配置好的`fcitx5`完全不逊色于搜狗输入法，并且更加稳定。推荐使用。

## 参考

[Fcitx5 - ArchWiki](https://wiki.archlinux.org/index.php/Fcitx5)