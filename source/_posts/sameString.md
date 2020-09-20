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
return result;
```

### 字典树

使用待查找字符串数组构建字典树，在根节点存储该字符串的角标。使用目标字符串到字典树中进行查找，得到结果。

#### 示意图

![photo_2020-09-18_17-26-52](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/photo_2020-09-18_17-26-52.jpg)

#### 代码实现

```java
class Main {
    public static void main(String[] args) {
        String[] toFind = new String[] { "abca", "abab", "abba", "abca" };
        String target = "abca";
        TrieTreeNode root = new TrieTreeNode();
        for (int i = 0; i < toFind.length; i++) {
            root.addStringToTree(toFind[i], i);
        }
        System.out.println(root.searchInTree(target));
    }
}

// 字典树节点的简单实现
class TrieTreeNode {
    // 子节点
    private List<TrieTreeNode> list;
    // 存储角标
    private List<Integer> result;
    // 该点字符
    private char ch;

    // 空构造函数(构造根节点)
    public TrieTreeNode() {
    }

    // 构造子节点
    private TrieTreeNode(char ch) {
        this.ch = ch;
    }

    // 判断该点字符是否为ch
    private boolean isChar(char ch) {
        if (this.ch == ch) {
            return true;
        }
        return false;
    }

    // 获取字符为ch的子节点(如果没有字符为ch的子节点则自动添加)
    private TrieTreeNode getNext(char ch) {
        if (list == null) {
            list = new ArrayList<>();
        }
        for (var item : list) {
            if (item.isChar(ch)) {
                return item;
            }
        }
        var tmp = new TrieTreeNode(ch);
        list.add(tmp);
        return tmp;
    }

    // 使用上述private函数将字符串添加到字典树中
    public void addStringToTree(String str, int index) {
        var tmp = this;
        for (var item : str.toCharArray()) {
            tmp = tmp.getNext(item);
        }
        if (tmp.result == null) {
            tmp.result = new ArrayList<>();
        }
        tmp.result.add(index);
    }

    // 在字典树中查询目标字符串
    public List<Integer> searchInTree(String target) {
        var tmp = this;
        for (var item : target.toCharArray()) {
            if (tmp.list == null || tmp.list.isEmpty()) {
                return new ArrayList<Integer>();
            }
            tmp = tmp.getNext(item);
        }
        return tmp.result;
    }
}
```

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

#### 解释

当给定的字符串过长、规模过大时，直接应用哈希表会造成较多的空间浪费。在这种情况下，我们可以将字符串进行切割，将每一个子串作为key，字符串的角标和子串位置构成的二元组列表（<i,j>）作为value。

在查找目标字符串时，同样切割目标字符串得到子串，将每一段子串作为key查询得到二元组列表。如果二元组列表中的某个二元组（<i,j>）的子串位置（j）与当前子串在目标字符串中的位置相同，则说明toFind[i]的该段子串与目标字符串相同，将i加入到该子段的角标集合中。最后对目标字符串的所有字段的角标集合求交得到结果。

>  对于结果中的每个元素i，都有toFind[i]的所有子串与目标字符串的对应子串相同。即toFind[i]与目标字符串相同。

#### 示意图

![photo_2020-09-18_18-33-27](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/photo_2020-09-18_18-33-27.jpg)

#### 代码实现（包含输入输出，上文的String[]使用List&lt;String&gt;代替）

```java
import java.util.List;
import java.util.ArrayList;
import java.util.Scanner;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.Map;

class Main {
    public static void main(String[] args) {
        // 输入的待查找的字符串
        List<String> list = new ArrayList<>();
        String target;
        try (var scanner = new Scanner(System.in)) {
            System.out.print("Please input target String:");
            // 目标字符串
            target = scanner.nextLine();
            System.out.println("Please input String array to find(end with space):");
            String tmp;
            // 输入非空则读入list
            while (!"".equals(tmp = scanner.nextLine())) {
                list.add(tmp);
            }
        }
        // 输出查找结果
        System.out.println(find(target, getMap(list)));

    }

    // 字符串分割函数
    private static List<String> split(String src, int size) {
        List<String> result = new ArrayList<>();
        int begin = 0;
        while (begin < src.length()) {
            // 如果开始位置加截断长度大于源字符串长度，则只截断到字符串末尾并跳出循环
            if (begin + size > src.length()) {
                result.add(src.substring(begin));
                break;
            }
            result.add(src.substring(begin, begin + size));
            begin += size;
        }
        return result;
    }

    private static Map<String, List<Pair>> getMap(List<String> list) {
        Map<String, List<Pair>> map = new HashMap<>();
        for (int i = 0; i < list.size(); i++) {
            String item = list.get(i);
            // 对待查找字符串进行分割得到List<String>
            var array = split(item, 10);
            // 遍历所有分割结果
            for (int j = 0; j < array.size(); j++) {
                String key = array.get(j);
                // 将分割结果作为key对map取value,如果为空则加入空List
                if (map.get(key) == null) {
                    map.put(key, new ArrayList<Pair>());
                }
                // 为List加入二元组<i,j>（其中i为待查找字符串的编号，j为在该字符串内的位置）
                map.get(key).add(new Pair(i, j));
            }
        }
        return map;
    }

    private static Set<Integer> find(String target, Map<String, List<Pair>> map) {
        // target为空则返回空集合
        if (target == null) {
            return new HashSet<Integer>();
        }
        List<Set<Integer>> list = new ArrayList<>();
        // 对需查找的字符串进行分割
        var array = split(target, 10);
        // 遍历分割后的字符串数组
        for (int i = 0; i < array.size(); i++) {
            var key = array.get(i);
            // 与该分割段在对应位置相等的行数集合
            Set<Integer> set = new HashSet<>();
            // 如果该段匹配，则将行数加入到set中
            for (var item : map.get(key)) {
                if (item.getLast() == i) {
                    set.add(item.getFirst());
                }
            }
            // 将set加入list
            list.add(set);
        }
        // 如果list为空则返回空集合
        if (list.isEmpty()) {
            return new HashSet<Integer>();
        }
        // 取list中的第一个集合
        Set<Integer> result = list.get(0);
        // 将该集合对所有集合取交
        for (var item : list) {
            result.retainAll(item);
        }
        // 得到结果，返回
        return result;
    }
}

// 一个简单的Pair实现（<Integer,Integer>）
class Pair {
    private final Integer first;
    private final Integer last;

    public Pair(Integer first, Integer last) {
        this.first = first;
        this.last = last;
    }

    public Integer getFirst() {
        return this.first;
    }

    public Integer getLast() {
        return this.last;
    }

    @Override
    public boolean equals(Object compare) {
        if (compare == null) {
            return false;
        }
        Pair tmp = (Pair) compare;
        if (this.first == tmp.first && this.last == tmp.last) {
            return true;
        }
        return false;
    }
}
```

