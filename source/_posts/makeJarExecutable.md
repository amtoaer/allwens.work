---
title: 让.jar程序“可执行”
date: 2020-08-07 20:12:52
tags: [linux,java]
categories: 便捷使用
photos: /img/banner/images/9.jpg
description: 让.jar在linux下“可执行”
---

最近用`java`写了一个命令行版小牛翻译，通过`maven`构建生成`.jar`文件。但众所周知，`.jar`程序不能直接运行，而是需要使用`JVM`解释：

```bash
java -jar filename.jar ...arguments
```

这导致其使用体验并不友好。那有没有什么方法让`.jar`程序“可执行”（不用带上`java -jar`）的方法呢？我去查了查，发现是有的。

<!--more-->

> 内容主要参考自[这篇文章](https://stackoverflow.com/questions/44427355/how-to-convert-jar-to-linux-executable-file)。

`Linux`下可执行的程序有两种，二进制程序和脚本文件。前者是机器码，可以直接运行，后者则需要一个解释器，通过解释器对代码解释执行。在脚本文件中，可以通过在文件头加入`hashbang`指定解释器，这样在执行脚本文件时，系统会使用`hashbang`中指定的解释器解释脚本内容。

以`python`为例：正常情况下，我们需要通过`python filename.py`来执行程序，而如果在`filename.py`首行加入`#!/usr/bin/python`并给予其可执行权限，它便可直接通过`./filename.py`执行。

回到`java`，`.jar`文件本身是字节码的集合，`java -jar`表明需要用`JVM`去解释它。因此其实我们的处理方法和`python`类似：

1. 新建文件，在其开头写入`hashbang`

   ```bash
   touch a
   echo "#!/usr/bin/java -jar" > a
   ```

2. 将需要解释的内容（整个`.jar`文件）追加到文件后

   ```bash
   cat /path/to/.jar >> a
   ```

3. 给予该文件可执行权限

   ```bash
   chmod +x ./a
   ```

之后就可以将其作为普通的可执行文件使用啦！

