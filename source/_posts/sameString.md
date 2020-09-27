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

### 进一步的思考（作业）

在上面的算法中，我们使用固定长度对查找域`toFind`和查找目标`target`进行切割，但使用这种方法，可能会出现某些子串出现过于频繁的情况。因此，我们可以考虑优化字符串分割算法，对出现频率过高的字符串进行顺延（即取该子串后的字符拼接到该子串后）。举例如下：

```java
// 按长度为3切割该字符串
"abcedfabcqweabcertabctyu"
// 得到结果，可以看到abc出现频率过高，对其进行顺延
"abc|edf|abc|qwe|abc|ert|abc|tyu"
// 顺延后，abc分化为了abce|abcq|abct，降低了某一子串的出现频率
"abce|edf|abcq|qwe|abce|ert|abct|tyu"
```

#### 算法的注意点

1. 如何定义“频率过高”？

   很明显，我们需要设置一个比例来标明我们允许的子串最大的出现频率，当有子串的出现频率大于这一阈值时，我们对该子串进行顺延，尝试“分化”这一子串到一个更低的频率。重复该过程以达到最终的“所有子串出现频率均低于这一阈值”的结果。

2. 字符串切割算法的整体性。

   在该题目中，我们使用的方法是使用同样的规则切割查找域的每个字符串和目标字符串，对应位置进行比较，最后将对应位置相等的行数取交集得到结果。

   在普通的按确定长度进行切割的情况下，我们可以对所有的串单独处理。但在如今的算法框架下，如果对字符串分别处理，很可能会出现切割方式不统一的情况。因此，我们在进行子串频率统计、子串顺延等操作时，需要把{查找域，查找目标}这个字符串的整体集合作为整体，确保每个操作都能成功作用于查找域中的每个字符串和目标字符串。

### 我的Java代码实现（使用递归且复杂度较高）

```java
import java.util.*;

class Main {
    // 用于全局统计子串需要顺延的长度
    private static Map<String, Integer> globalCount = new HashMap<>();
    // 用于统计每次切割中子串的出现次数
    private static Map<String, Integer> count = new HashMap<>();

    public static void main(String[] args) {
        String[] range = new String[] { "abcabcedf", "abeabeefg", "bcdbcabec" };
        String target = "abcabcedf";
        // target和range的切割方式应该相同，故需要同时处理
        List<List<String>> list = cutStrings(range, target, 3, 0.2);
        System.out.println(list);
    }

    // 得到切割后的列表，参数分别为查找域，查找目标，切割的原始长度，子串的最高出现频率
    private static List<List<String>> cutStrings(String[] range, String target, int width, double pro) {
        // 总子串个数等于（字符串长度/切割长度）向上取整再乘以字符串个数
        int totalCount = ((int) Math.ceil((double) target.length() / width)) * (range.length + 1);
        // 最高出现频率小于（1/总子串个数）是不可能的情况，在这种情况下直接返回空的二维数组
        // （尽管进行了限制，但在特定情况下如果设置pro过低仍然可能出现stack overflow）
        if (pro < 1.0 / totalCount) {
            return new ArrayList<List<String>>();
        }
        count.clear();
        List<List<String>> result = new ArrayList<>();
        // 遍历查找域，按指定长度切割字符串
        for (var item : range) {
            result.add(cutString(item, width));
        }
        // 按指定长度切割查找目标
        result.add(cutString(target, width));
        // 切割完所有串后，我们在count内得到了所有子串的出现次数
        // 接下來需要遍历count,将出现频率大于限制频率的子串进行标记，在下次切割时将该种子串后延
        boolean flag = false; // flag用于标记是否有出现频率大于限制的字符串
        for (var item : count.entrySet()) {
            if ((double) item.getValue() / totalCount > pro) {
                addForGlobalCount(item.getKey().substring(0, width));
                flag = true;
            }
        }
        // 如果所有子串出现频率都小于限制则满足要求，直接返回
        if (!flag) {
            return result;
        }
        // 否则重新进行切割
        return cutStrings(range, target, width, pro);
    }

    // 统计str出现的次数
    private static void addForCount(String str) {
        if (count.get(str) != null) {
            count.put(str, count.get(str) + 1);
        } else {
            count.put(str, 1);
        }
    }

    // 统计子串需要顺延的长度（基本逻辑是如果顺延后仍然出现频率较高，则继续顺延）
    private static void addForGlobalCount(String str) {
        if (globalCount.get(str) != null) {
            globalCount.put(str, globalCount.get(str) + 1);
        } else {
            globalCount.put(str, 1);
        }
    }

    // 切割str并统计所有子串出现的次数(切割方法在每次循环都会通过globalCount进行校正而逐步逼近正确结果)
    private static List<String> cutString(String str, int width) {
        List<String> result = new ArrayList<>();
        int start = 0;
        String sub;
        while (start < str.length()) {
            // 如果到达结尾则切割到结尾
            if (start + width > str.length()) {
                sub = str.substring(start);
                result.add(sub);
                addForCount(sub);
                break;
            }
            Integer extraWidth;
            // 判断是否需要顺延
            if ((extraWidth = globalCount.get(str.substring(start, start + width))) != null) {
                // 如果需要顺延，需要判断顺延后是否到达结尾
                int tmp = start + width + extraWidth > str.length() ? str.length() : start + width + extraWidth;
                sub = str.substring(start, tmp);
            } else {
                sub = str.substring(start, start + width);
            }
            result.add(sub);
            addForCount(sub);
            start += width;
        }
        return result;
    }
}
```

