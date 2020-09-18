---
title: 查找相同字符串
tags: [java,algorithm]
date: 2020-09-17 15:16:11
categories: 算法分析
photos: /img/banner/images/22.jpg
description: 对java老师课上算法的总结
---

## 问题描述

给定n个长度为m的字符串数组和一个长度为m的目标字符串，编写程序得到字符串数组中与目标字符串相同的字符串角标。

举例：

```java
String[] toFind = new String[]{"abca","abab","abba","abca"};
String target = "abca";
// 结果 [0,3]
```

## 解决方法

### 遍历

最简单的方法，遍历字符串数组，与目标字符串进行对比，如果与目标字符串相等则将其角标加入到结果中，最后返回结果。

```java
List<Integer> result = new ArrayList<>();
for (int i = 0; i < toFind.length; i++) {
    if (target.equals(toFind[i])) {
        result.add(i);
    }
}
```

### 字典树

使用待查找字符串数组构建字典树，在根节点存储该字符串的角标。使用目标字符串到字典树中进行查找，得到结果。

> ~~代码较为复杂，暂且省略 ，用张图表示一下吧233~~

![photo_2020-09-18_17-26-52](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/photo_2020-09-18_17-26-52.jpg)

### 哈希表

使用`String->List<Integer>`的哈希表，将字符串作为key，对应的角标作为value。直接通过查表返回结果。

```java
Map<String, List<Integer>> map = new HashMap<>();
for (int i = 0; i < toFind.length; i++) {
    if (map.get(toFind[i]) == null) {
        map.put(toFind[i], new ArrayList<Integer>());
    }
    map.get(toFind[i]).add(i);
}
return map.get(target);
```

### 切割字符串后使用哈希表（作业）

当给定的字符串过长、规模过大时，直接应用哈希表会造成较多的空间浪费。在这种情况下，我们可以将字符串进行切割，将每一个子串作为key，字符串的角标和子串位置构成的二元组列表（<i,j>）作为value。

在查找目标字符串时，同样切割目标字符串得到子串，将每一段子串作为key查询得到二元组列表。如果二元组列表中的某个二元组（<i,j>）的子串位置（j）与当前子串在目标字符串中的位置相同，则说明toFind[i]的该段子串与目标字符串相同，将i加入到该子段的角标集合中。最后对目标字符串的所有字段的角标集合求交得到结果。

>  对于结果中的每个元素i，都有toFind[i]的所有子串与目标字符串的对应子串相同。即toFind[i]与目标字符串相同。

![photo_2020-09-18_18-33-27](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/photo_2020-09-18_18-33-27.jpg)

代码实现同样略为复杂，略去不表。