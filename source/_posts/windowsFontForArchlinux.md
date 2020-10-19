---
title: arch系发行版安装windows字体
date: 2020-07-16 23:54:28
tags: [archlinux,font]
categories: 系统优化
photos: /img/banner/images/18.jpg
description: 为单系统arch系发行版安装windows字体
---

## 背景

日常生活中，总是会有一些奇奇怪怪的需求需要使用到`office`。对`linux`用户来说，虽然可以用`wps`代替`ms office`办公套件，但还会面临一个很大的问题：**没有windows的字体库！**

试想一下，作业要求提交使用微软雅黑字体的word文档，而`linux`上根本没有这个字体，你要怎么办？打开老师做的ppt课件，结果因为缺少字体而处处错位，又要怎么办？…

无数次面临这种问题之后，我萌生了安装windows字体的想法。

<!-- more -->

> 注：本文记录了整个打包流程，如果想要直接获取打包好的软件包，请[点击此处](https://drive.allwens.work:10000/#/s/bDsY)。

## 安装

查了查，网上的解决方法大部分是把windows的字体目录挂载过来，然而像我这种linux单系统用户肯定就不能这么操作了XD

于是，我打开了万能的[arch wiki](https://wiki.archlinux.org/index.php/Microsoft_fonts)，根据指引来到了`ttf-ms-win10`的`aur`界面，在安装前首先看一下作者的置顶评论：

> FAQ, please read before posting:
>
> 1. I get an error that the sources cannot be downloaded: Please read the instructions on the top of the PKGBUILD.
> 2. Some fonts are missing in my copy of Windows (e.g., holomdl2, corbel, chandra, …): It seems that Microsoft distributes some fonts only with some Windows versions. You can just comment out the corresponding line in the PKGBUILD and then build with “makepkg –skipchecksums”.
> 3. Some fonts have different checksums: We keep the checksums synchronized with our own Windows installations that are regularly updated. Different Windows versions, different ISOs etc. may contain fonts in different versions/variants. Just build the package using “makepkg –skipchecksums”.
> 4. Why does the version not correspond to the latest Windows 10 build: If fonts have not changes between builds, there is no reason to change the version number of this package.
> 5. Why are some fonts (e.g., traditional chinese, japanese etc.) not included here, not even in the corresponding split packages: We currently only include fonts that are installed on a standard Windows installation, without additional feature-on-demand packages (see: https://docs.microsoft.com/en-us/typography/fonts/windows_10_font_list).

嗯嗯..说的已经很明白啦，接着就先克隆一下项目：

```bash
git clone https://aur.archlinux.org/ttf-ms-win10.git
cd ttf-ms-win10
```

听他的，先看一下`PKGBUILD`：

```bash
vim PKGBUILD
```

首先是一段版权声明，在windows系统以外的地方使用`Microsoft fonts`是违法的。

估计是为了避免法律问题，它并没有自带`windows`的字体，而是给出了两种方法：

1. 从当前已有的windows系统获取（如果有的话我就直接挂载了啊喂！）
2. 从windows的安装包中提取

所以就按着他的步骤来吧：

- 到[这里](http://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)下载windows10安装包

- 打开`iso`镜像，解压出`sources/install.wim`

- 安装`wimlib`并解压`wim`格式

  ```bash
  sudo pacman -S wimlib
  # 切换到install.wim所在的目录
  wimextract install.wim 1 /Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf} --dest-dir fonts
  ```

- 将解压出的字体全都放到`PKGBUILD`所在目录，执行：

  ```bash
  makepkg
  ```

  不出所料，果然出现了他说的第三点问题，不同windows版本可能会含有同一字体的不同版本，导致哈希值检验出错，脚本检验失败自动退出。

  解决办法也像他说的，只需要跳过检验就好了：

  ```bash
  makepkg –skipchecksums
  ```

经过漫长的等待，应该已经打包了很多种语言的包出来，接着只需要：

```bash
sudo pacman -U ./ttf-ms-win10-zh_cn-version.pkg.tar.xz
```

就成功啦！
