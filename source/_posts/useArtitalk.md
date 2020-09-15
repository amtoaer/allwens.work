---
title: artitalk的使用及美化
date: 2020-08-26 21:22:06
tags: [artitalk,website]
categories: 网站建设
photo: /img/banner/images/1.jpg
description: artitalk 2.4.x 在pjax网站的使用方法及美化过程
---

 Artitalk是一款通过leancloud实现的可实时发布说说的js。点击我博客顶部的“说说”，看到的即为artitalk界面。

本文主要记录`artitalk 2.4.x`在pjax网站的使用方法及美化过程。

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

此处我们讨论的是第二种方法。参照[该pr](https://github.com/volantis-x/hexo-theme-volantis/pull/429/files)的思路，我们需要在页面重载的时候删除掉原本的`window.AV`对象，接着重新加载artitalk.js。

### 数据迁移

因为valine同样依赖`window.AV`提供服务。使用上述方法解决artitalk问题的代价是：**在加载artitalk界面过程中，artitalk将valine的`window.AV`替换成了自己的。**所以首先我们需要确保artitalk和valine使用的是相同的LeanCloud应用。

按照artitalk官方文档的说法：

> 因为 LeanCloud 功能的限制。若想同时使用 valine 和 artitalk，请在 `class` 中添加名为 `Comment` 的 class。不推荐在存储 valine 的应用中新建名为 `shuoshuo` 的 class，可能会出现神奇的 bug。

所以我们需要将valine的数据迁移到artitalk中（如果本来用的就是相同的应用可以跳过该步骤）：

1. 在artitalk使用的LeanCloud应用中新建`Comment` class，如果有使用访问量功能的话还需要新建`Counter `class

2. 将原来valine应用中的`Comment`和`Counter` class导出（*吐槽一句：为什么只能在中午十二点前导出啊！维护用得着整整半天吗？！*）

   ![image-20200827151353004](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200827151353004.png)

3. 将导出的`Comment`和`Counter ` class导入到artitalk使用的应用中

   ![image-20200827151808051](https://allwens-work.oss-cn-beijing.aliyuncs.com/bed/image-20200827151808051.png)

4. 将配置文件中valine使用的ID和Key改成和artitalk相同的。

### 具体的实现过程

这一步是我自己摸索出来的，可能有些繁琐。

参考[该文章](https://liuyib.github.io/2019/09/24/use-pjax-to-your-site/#%E9%87%8D%E8%BD%BD-js-%E8%84%9A%E6%9C%AC)里重载整个js文件的实现思路，我们可以将artitalk引入到网站并加上`data-pjax`属性，并在每次pjax切换页面时对带有`data-pjax`属性的js文件进行重载。

但问题是，我们并不应该让artitalk在每个页面都执行，只有位于artitalk页面时才有执行的必要，因此我们需要手动修改`artitalk`源码并重新构建，具体流程是：

#### 克隆Artitalk仓库并切换到指定commit

查看版本历史后发现`1df35c9`似乎是最后通过测试的commit，因此我们使用该次commit。

```bash
git clone https://github.com/ArtitalkJS/Artitalk
cd Artitalk
git checkout 1df35c9
```

~~有一说一，感觉这个项目有点乱。所有操作基本都在master分支，甚至使用github actions往master里push...~~

#### 加入对当前所处页面的判断

我们需要加入对当前页面的判断，只有当前页是artitalk页时才需要执行脚本。以我的博客为例，artitalk页面的`window.location.pathname`为`/personal-space/`，我做的操作是：

+ 为`src/main.js`套一个判断

  ```javascript
  if (window.location.pathname==='/personal-space/'){
      // 文件原本内容
  }
  ```

+ 为`av.min.js`套一个判断

  ```javascript
  if (window.location.pathname==='/personal-space/'){
      if (window.AV!==undefined){
          delete window.AV
      }
      // 文件原本内容
  }
  ```

#### 安装依赖并构建

```bash
# for yarn
yarn 
yarn gulp
# for npm
npm install
npm run gulp
```

#### 在网站中引入构建好的文件

把`dist/artitalk.min.js`放入博客的`source/js`目录。将这行加到footer里：

```html
<script data-pjax src='/js/artitalk.min.js'></script>
```

#### 修改`pjax:complete`函数

```javascript
// 这是Valine的重载函数
VA: function () {
    if (!valine) {
        var valine = new Valine()
        valine.init({
            el: '#vcomments',
            appId: mashiro_option.v_appId,
            appKey: mashiro_option.v_appKey,
            path: window.location.pathname,
            placeholder: '你是我一生只会遇见一次的惊喜 ...',
            visitor: true
        })
    }
}
// pjax:complete内
pjax(...,...,{...}).on('pjax:complete',function (){
    // 重载artitalk
    $("script[data-pjax], .pjax-reload script").each(function () {
        $(this).parent().append($(this).remove());
    });
    // 再重载valine
    VA()
})
```

**这一步要注意顺序，实测如果先重载valine再重载artitalk，会出现valine能正确显示评论条数却不能显示内容的bug。**

#### 加入artitalk页面

万事具备，最后只需要在artitalk对应的md文件内写入：

```html
---
title: 标题
comments: false
---
<div id="artitalk_main"></div>
<script>
    var appID="你的ID";
    var appKEY="你的Key";
    // 各种配置项请参考artitalk官方文档
</script>
```

## artitalk美化（自定义样式）

### 简单需求

如果只是想换个背景色，我们可以通过简单指定配置项的`color1`/`color2`/`color3`来生效。例如我的博客，使用的配置是：

```javascript
var color1='#d9d9f3';
var color2='#ceefe4';
var color3='black';
```

### 复杂需求

对于更复杂的美化需求，[这篇文章](https://blog.csdn.net/cungudafa/article/details/106224223)给出了多个自定义样式。然而，但实际使用中会发现文中的自定义方法不能生效。

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

   根据[artitalk配置项文档](https://artitalk.js.org/settings.html#📌cssurl)，当我们指定`cssurl`项时，默认样式将不会被加载，转而使用位于`cssurl`的css文件。

   我们可以将仓库中的`main.css`拷贝出来，把指定的条目换成我们的自定义样式，并将修改后的css文件上传到某个网站，最后把上传后得到的直链地址填到`cssurl`项即可。

