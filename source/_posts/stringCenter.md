---
title: python中文字符串居中问题
date: 2019-12-22 22:40:01
tags: python
categories: 问题解决
photos: /img/banner/images/13.jpg
description: 中文字符串居中
---

最近在实现一个小功能的时候遇到了问题：字符串的居中输出。

虽然python有内置的字符串方法`string.center()`，使字符串可以居中输出，但它并不能顺利地处理中文字符串，一直无法达到让中文字符串居中的效果。

<!--more-->

后来我突然醒悟，是不是因为python字符串长度的问题？用以下代码测试：

```python
str1='哈哈哈'
str2='hhh'
print(len(str1),'+',len(str2))
```

输出结果居然是`3+3`，也就是说python将一个汉字/字母都记作一个字符，但其实它们的宽度并不相同。这样计算的话必然会导致无法正常居中，关键是要把汉字区别出来，于是我手动写了个居中函数：

```python
def strCenter(str, len):
    lst = list(str)
    length = 0
    for item in lst:
        if item in string.printable:
            length += 1
        else:
            length += 2
    count = int((len - length) / 2)
    result = count * ' ' + str + count * ' '
    return result
```

就可以正常居中啦！

追加以下内容测试一下：

```python
a = '哈a哈a哈a哈a'
b = '12345678901234567890'
print(a.center(20))
print(b.center(20))
print(20 * '-')
print(strCenter(a, 20))
print(strCenter(b, 20))
```

运行结果：

```shell
      哈a哈a哈a哈a      
12345678901234567890
--------------------
    哈a哈a哈a哈a    
12345678901234567890
```

任务成功完成！