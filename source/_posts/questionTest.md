---
title: 马原毛概刷题工具(WEB VERSION)
date: 2020-01-30 09:44:08
tags: [website,go,Vue.js]
categories: 开发记录
photos: /img/banner/images/12.jpg
description: 使用vue+go开发的刷题工具
---

考试之前临时赶工做了个马原刷题工具，考试后有了时间顺便把它拓展成了[马原毛概刷题工具](https://github.com/jeasonlau/Question-test)，添加了随机刷题，考试模拟，错题本等功能，但平心而论，`python`的命令行程序还是不太易于使用，于是考虑将其改为网页版本，目前[该项目](https://github.com/jeasonlau/Question-test-web)已经开源在了github（在此前并没有接触过前端，所以可能会有很多不足之处）。

<!--more-->

## 后端

后端使用`go`的轻量web框架`gin`，[代码在这儿](https://github.com/jeasonlau/Question-test-web/blob/master/back-end/main.go)！

其通过读取当前目录的`mayuan.json/maogai.json`，根据不同的路由返回不同的结果：

|         访问地址          |           返回结果            |
| :-----------------------: | :---------------------------: |
|  /:subject/position/:num  | 返回该subject位置为num的题目  |
|     /:subject/random/     |   返回该subject随机一道题目   |
|  /:subject/random/radio   | 返回该subject随机一道单选题目 |
| /:subject/random/checkbox | 返回该subject随机一道多选题目 |

## 前端

前端使用`vue.js`，准备学习的时候，在官方文档中发现了这句话：

> 官方指南假设你已了解关于 HTML、CSS 和 JavaScript 的中级知识。如果你刚开始学习前端开发，将框架作为你的第一步可能不是最好的主意——掌握好基础知识再来吧！之前有其它框架的使用经验会有帮助，但这不是必需的。

而我对前端知识一无所知，于是先去`freecodecamp`学习了`HTML`基础和前几节`CSS`（因为`CSS`内容实在是太多了！），然后去`廖雪峰教程`把`JavaScript`学到了函数部分，之后一边参考官方文档学习一边上手开发。

------

首先使用`webpack`脚手架创建`vue`项目，接着安装并引入`muse-ui`组件库。

1. 路由

   ```javascript
   import Vue from 'vue'
   import Router from 'vue-router'
   import index from '../components/index'
   import temp from '../components/temp'
   import exam from '../components/exam'
   import order from '../components/order'
   import about from '../components/about'
   
   Vue.use(Router)
   
   export default new Router({
     routes: [
       {
         path: '/',
         name: 'index',
         component: index
       },
       {
         path: '/马原',
         name: 'mayuan',
         component: temp
       },
       {
         path: '/毛概',
         name: 'maogai',
         component: temp
       },
       {
         path: '/马原/顺序刷题',
         name: 'mayuanorder',
         component: order
       },
       {
         path: '/毛概/顺序刷题',
         name: 'maogaiorder',
         component: order
       },
       {
         path: '/马原/考试模拟',
         name: 'mayuanexam',
         component: exam
       },
       {
         path: '/毛概/考试模拟',
         name: 'maogaiexam',
         component: exam
       },
       {
         path: '/关于',
         name: 'about',
         component: about
       }
     ]
   })
   ```

2. 组件

   + `App.vue`中写入通用的顶栏，侧边栏等内容，监听路由变化修改标题。

   + `index.vue`和`about.vue`使用纯`HTML/CSS`写成。

   + `temp.vue`用于选择刷题方式。

   + `order.vue`为顺序刷题界面，使用`mu-pagination`进行翻页，`exam.vue`为考试模拟界面，使用`mu-load-more`实现题目部分加载。

   + `question.vue`为单位题目，是`order.vue`和`exam.vue`的子组件，监听`props`中`num`的变化，调用`getQuestion()`加载相应题目并判断是单选还是多选。在选择选项时使用`ifRight()`判断答案是否正确。

     ```javascript
     // ifRight
     ifRight: function () {
             let answer
             if (this.isRadio === false) {// 多选将答案array排序并链接为字符串
               answer = this.yourAnswer.sort().join("")
             } else {// 单选直接获取
               answer = this.yourAnswer
             }
             if (answer === this.question["Answer"]) {
               this.isRight = true
               let that = this
               if (this.timer)
                 clearTimeout(this.timer)
               this.timer = setTimeout(function () {// 显示2s的通知
                 that.isRight = false
               }, 2000)
             } else {
               this.isRight = false
             }
           }
     // getQuestion
     getQuestion () {
         this.yourAnswer=[]
         //根据父组件的path和当前num获取要请求的地址
         if (this.type === "/马原/顺序刷题") {
             this.url = "https://.../api/mayuan/position/" + (this.num - 1)
         } else if (this.type === "/毛概/顺序刷题") {
             this.url = "https://.../api/maogai/position/" + (this.num - 1)
         } else if (this.type === "/马原/考试模拟") {
             if (this.num <= 40) {
                 this.url = "https://.../api/mayuan/random/radio"
             } else {
                 this.url= "https://.../api/mayuan/random/checkbox"
             }
         } else if (this.type === "/毛概/考试模拟") {
             if (this.num <= 40) {
                 this.url = "https://.../api/maogai/random/radio"
             } else {
                 this.url = "https://.../api/maogai/random/checkbox"
             }
         }
         axios// 使用axios请求api获取题目
             .get(this.url)
             .then(response => {
             this.question = response.data
             if (this.question['Answer'].length > 1) {// 判断是单选还是多选
                 this.isRadio = false
             } else {
                 this.isRadio = true
             }
         })
     }
     ```

## 部署

在部署的时候遇到了不少问题。

开始在本地调试时发现无法加载出题目。查看`chrome console`中的错误信息，查询后发现是因为后端没有配置跨域，于是在后端路由中加上了：

```go
c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
```

调试正常，但部署到`github pages`后发现仍然无法加载，查看错误信息，得知在`https`网页中不能加载`http`资源，于是任务变成了给`gin`加上`https`。

查阅发现一般方法是申请子域名和免费证书，但我懒得整那么多了，正好手头有个`https`域名，直接给`nginx`的当前`server`块配个反向代理：

```nginx
location /api{
        proxy_pass http://localhost:8080;
}
```

然后在`github pages`中请求这个地址，但是不知道是不是因为中间隔了个`nginx`，又出现了跨域问题，一时没有查到解决方法，所以不得已把前端也部署在了`nginx`上，问题解决（唯一问题是我的服务器没有备案，所以只能手动输入端口访问）。

## 参考

+ [Vue.js官方文档](https://cn.vuejs.org/v2/guide/)
+ [Muse-UI官方文档](https://muse-ui.org/#/zh-CN/installation)
+ [Gin.README.md](https://github.com/gin-gonic/gin/blob/master/README.md)
+ [扶朕起来朕还能学](https://neumathe.xyz/)

