---
title: artitalk的使用及美化
date: 2020-08-26 21:22:06
tags: [artitalk,website]
categories: 网站建设
photo: /img/banner/images/1.jpg
---

 Artitalk是一款通过leancloud实现的可实时发布说说的js。右键我的博客，点击`我的小窝`，看到的即为Artitalk界面。

本文主要记录artitalk在pjax网站的使用方法及美化过程。

<!--more -->

## 在pjax网站使用artitalk

因为artitalk并没有提供重载函数，因此目前的解决办法主要有两种：

1. 在该页面通过各种手段进行一次刷新，例如：

   + 官方文档中的方法，自动在artitalk界面刷新

     ```javascript
     $(document).ready(function () {
         if(location.href.indexOf("#reloaded")==-1){
             location.href=location.href+"#reloaded";
             location.reload();
         }
     })
     ```

   + 对于volantis主题，将artitalk页面的`window.location.pathname`加入到主题配置的pjax黑名单

2. 手动清除artitalk初始化的`AV`对象并重新加载js文件

此处我们讨论的是第二种方法，实现起来很简单，参照[该pr](https://github.com/volantis-x/hexo-theme-volantis/pull/429/files)，只需在脚本前补上一行：

```javascript
if (window.AV!= undefined){
    delete window.AV;
}
```

如果你使用的是非`valine`评论系统，到该步工作已经完成。

---

对于valine评论系统，根据inkss大佬在[#368](https://github.com/volantis-x/hexo-theme-volantis/issues/368)下的回复：

> Artitalk 和 Valine 等，或者说所有基于 Leancloud 插件，因为 AV 对象是 const 定义，不允许重复实例化，所以他们先天性冲突，这点是无解的（除非是共用 AV 对象）。

valine同样依赖`window.AV`提供服务且只加载一次。上述方法解决artitalk问题的代价是：**在加载artitalk界面过程中，artitalk将valine的`window.AV`替换成了自己的。**这样会导致两个问题：

1. artitalk页面无法使用valine（因为加载过程中artitalk把valine的`window.AV`删掉了）
2. 访问过artitalk页面后，valine可以正常使用，但是数据源会被替换为artitalk的（同理，因为valine自己的`window.AV`被替换掉了）

问题1应该可以通过调整js执行顺序解决（我没有在artitalk页面评论的需求，因此没有尝试），问题2则需要像上面提的一样：**共用AV对象**。

说起来很高大上，其实说白了就是让这两个应用使用同一个LeanCloud应用。

按照artitalk官方文档的说法：

> 因为 LeanCloud 功能的限制。若想同时使用 valine 和 artitalk，请在 `class` 中添加名为 `Comment` 的 class。不推荐在存储 valine 的应用中新建名为 `shuoshuo` 的 class，可能会出现神奇的 bug。

所以最终的解决方法是：

1. 在artitalk使用的LeanCloud应用中新建`Comment` class，如果有使用访问量功能的话还需要新建`Counter `class

2. 将原来valine应用中的`Comment`和`Counter` class导出（*吐槽一句：为什么只能在中午十二点前导出啊！维护用得着整整半天吗？！*）

   ![image-20200827151353004](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200827151353004.png)

3. 将导出的`Comment`和`Counter `class导入到artitalk使用的应用中

   ![image-20200827151808051](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200827151808051.png)

4. 将valine使用的ID和Key改成和artitalk相同的。

到这一步，artitalk应该就可以完美和valine共用，并兼容pjax啦！

## artitalk美化（自定义样式）

[这篇文章](https://blog.csdn.net/cungudafa/article/details/106224223)给出了多个自定义样式，但实际使用中会发现文中的自定义方法不能生效。

我们来看一下artitalk添加的默认样式：

```css
#artitalk_main .cbp_tmtimeline>li:nth-child(odd) .cbp_tmlabel {
    ......
}
```

再来看看自定义的样式：

```css
.cbp_tmtimeline>li:nth-child(odd) .cbp_tmlabel {
    ......
}
```

根据`css`优先级的规则：

> 内联 > ID选择器 > 类选择器 > 标签选择器。

在其他部分相同的情况下，artitalk的默认样式多使用了一个ID选择器，在优先级上是高于我们的自定义样式的，因此我们的自定义样式无法成功应用。

解决方法有三种：

1. 为自定义样式同样加上ID选择器，并保证自定义样式位于默认样式后。

   > 当优先级与多个 CSS 声明中任意一个声明的优先级相等的时候，CSS 中最后的那个声明将会被应用到元素上。

2. 为自定义样式中的每个属性加上`!important`。

   > 当在一个样式声明中使用一个 `!important` 规则时，此声明将覆盖任何其他声明。

3. 指定`cssurl`项

   根据[artitalk配置项文档]([https://artitalk.js.org/settings.html#%F0%9F%93%8Ccssurl](https://artitalk.js.org/settings.html#📌cssurl))，当我们指定`cssurl`项时，默认样式将不会被加载，转而使用位于`cssurl`的css文件。

   我们可以将仓库中的`main.css`拷贝出来，把指定的条目换成我们的自定义样式，并将修改后的css文件上传到某个网站，最后把上传后得到的直链地址填到`cssurl`项即可。

我个人使用的是第三种方法，将修改后的样式上传到自己的阿里云oss并引用：

```ejs
<script>
    if (window.AV != undefined) { delete window.AV; }
    var appID = "<%=  theme.plugins.Artitalk.appID  %>";
    var appKEY = "<%=  theme.plugins.Artitalk.appKEY  %>";
    （中间省略）
    var cssurl = "https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/artitalk.min.css"
</script>
```

最终效果可右键我的博客点击`我的小窝`查看。