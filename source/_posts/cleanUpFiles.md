---
title: manjaro常用的垃圾清理命令
date: 2019-08-12 15:17:25
tags: [linux,manjaro]
categories: 系统优化
photos: /img/banner/images/3.png
description: 清除系统垃圾
---

+ 清除系统中无用的包

  ```
  sudo pacman -R $(pacman -Qdtq)
  ```

+ 清除已下载的安装包

  <!--more-->

  ```
  sudo pacman -Scc
  ```

+ 日志垃圾

  + 查看日志文件

    ```
    du -t 100M /var
    or
    journalctl --disk-usage
    ```

  + 删除指定大小日志文件

    ```
    sudo journalctl --vacuum-size=50M
    ```

    