---
title: 禁用笔记本自带键盘的方法
date: 2019-07-03 12:13:55
tags: [windows,linux]
categories: 系统优化
photos: /img/banner/images/5.jpg
description: 禁用windows/linux笔记本自带键盘
---

## Windows

### 禁用

**用管理员权限运行cmd，在其中输入：**   

```cmd
sc config i8042prt start= disabled
```

**之后重启即可。**

<!--more-->

### 恢复

**与禁用的步骤相同，把输入的命令改为：**

```cmd
sc config i8042prt start= demand
```

## Linux

***注意：manjaro需要使用***

```sh
sudo pacman -S xorg-xinput
```
***进行安装以使用xinput命令。***

**打开终端，输入`xinput --list `获取设备列表：**

```sh
❯ xinput --list 
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ USB Optical Mouse Mouse                 	id=14	[slave  pointer  (2)]
⎜   ↳ Synaptics TM3253-001                    	id=11	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Power Button                            	id=6	[slave  keyboard (3)]
    ↳ Video Bus                               	id=7	[slave  keyboard (3)]
    ↳ Power Button                            	id=8	[slave  keyboard (3)]
    ↳ Sleep Button                            	id=9	[slave  keyboard (3)]
    ↳ Integrated_Webcam_HD: Integrate         	id=10	[slave  keyboard (3)]
    ↳ Dell WMI hotkeys                        	id=12	[slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard            	id=13	[slave  keyboard (3)]
    ↳ DELL Wireless hotkeys                   	id=15	[slave  keyboard (3)]
    ↳ USB Keyboard Consumer Control           	id=16	[slave  keyboard (3)]
    ↳ USB Keyboard System Control             	id=17	[slave  keyboard (3)]
    ↳ USB Keyboard                            	id=18	[slave  keyboard (3)]
```

**找到`AT Translated Set 2 keyboard`对应的id（本机为13）。**

### 禁用

**在终端中输入**

```bash
xinput set-prop 13 "Device Enabled" 0 
```

### 恢复

**在终端中输入**

```bash
xinput set-prop 13 "Device Enabled" 1
```