---
title: 为typora集成sm.ms图床，纵享丝滑体验
date: 2020-04-28 20:01:51
tags: [linux,image]
categories: 便捷使用
photos: /img/banner/images/14.jpg
description: typora自动上传图片
---

起因是安利一位同学使用`typora`写`markdown`，他那里上官网比较慢，所以我去帮他下载，闲来无聊顺便逛了逛。逛完才发现，原来`typora`有那么多自定义选项！（没错我这一年多一直用的默认设置XD）

以此为契机，我第一次打开了它的偏好设置，查看了各类选项， 发现里面有一个很有意思的功能：`插入图片自动上传`，觉得挺方便的，于是准备配置一波...

>   注意：笔者使用的是`linux`，`windows`请酌情参考（安装方法和配置文件路径会略有差异）

<!--more-->

## 安装

`typora`中可选的上传配置有`Picgo`，`Picgo-core`，`custom command`和`none`，本人很久前用过`Picgo`，但其使用`electron`构建的UI在`linux`上体验属实很差，所以此处我选用了命令行版的`Picgo-core`。

首先进行安装：

```bash
npm install picgo -g
# or
yarn global add picgo
```

## 插件配置

>   注意：`windows`用户请确保将`picgo`添加到环境变量，否则需要把下文中的所有`picgo`替换为`path+picgo`（例：`C:\picgo\picgo.exe`）

`Picgo`本身支持多种图床上传，我选用的是方便免费的`SM.MS`，于[项目主页](https://github.com/Molunerfinn/PicGo)我们了解到：

>   PicGo 本体支持如下图床：
>
>   -   ~~`SM.MS` v1.5.1~~ **由于官方不再支持V1版本，暂时请使用[smms-user](https://github.com/xlzy520/picgo-plugin-smms-user)插件**

也就是说我们需要额外安装插件才可以正常使用`SM.MS`图床进行上传，于是打开`terminal`，执行：

```bash
picgo install smms-user
```

安装成功后，我们仍然需要对其进行配置。执行以下命令：

```bash
picgo config plugin smms-user
? Auth 
```

你需要在此处输入你的`TOKEN`，首先到`SM.MS`网站注册一个账户，接着访问[该链接](https://sm.ms/home/apitoken)获取`TOKEN`并输入，你应该会收到以下提示信息：

```bash
[PicGo SUCCESS]: Configure config successfully!
```

接下来是最后一步，你需要把你使用的`uploader`修改为`smms-user`，在命令行中执行：

```bash
picgo config uploader
? Choose a(n) uploader (Use arrow keys)
❯ smms-user 
  smms 
  tcyun 
  github 
  qiniu 
  imgur 
  aliyun 
(Move up and down to reveal more choices)
```

移动箭头并选中`smms-user`，点击回车，此时你位于`~/.picgo/config.json`的配置文件内容应该形如：

```json
{
  "picBed": {
    "current": "smms-user",
    "uploader": "smms-user",
    "transformer": "path",
    "smms-user": {
      "Authorization": "your token"
    }
  },
  "picgoPlugins": {
    "picgo-plugin-smms-user": true
  },
  "picgo-plugin-smms-user": {
    "Authorization": "your token"
  }
}
```

图片上传服务配置成功完成！

## typora集成

配置完上传服务，接下来在`typora`对接一下即可。

打开`typora`偏好设置，在上传服务设定栏选`custom command`（这里解释一下，选择`Picgo-core`只能使用其规定的路径，我们自己指定路径还是需要用`custom command`），然后在下面的文本框输入：

```bash
picgo upload
```

对接完成！接下来可以尝试点击旁边的“验证图片上传选项”按钮，测试上传是否成功了。

## 小提示

目前仅支持把文件拖动到`typora`中完成上传，如果直接从剪切板粘贴，`typora`会自动将该图片放到`~/upload`文件夹下但不会自动上传，需要自己手动点击“上传图片”。这是`typora`本身的bug：

>   This should be a bug, there's no need to create the "upload" folder.

详见[#3331](https://github.com/typora/typora-issues/issues/3331).

## 参考

1.  [Picgo](https://github.com/Molunerfinn/PicGo)
2.  [Picgo-core](https://github.com/PicGo/PicGo-Core)
3.  [picgo-plugin-smms-user](https://github.com/xlzy520/picgo-plugin-smms-user)
4.  [Picgo-core document](https://picgo.github.io/PicGo-Core-Doc/zh/guide/config.html)
