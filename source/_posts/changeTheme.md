---
title: 本站更换主题啦！
date: 2020-01-29 22:29:44
tags: website
categories: 网站建设
photos: /img/banner/images/2.png
description: 网站更换为sagiri主题
---

故事要从四天前说起...

那天，我像往常一样刷着网站，偶然发现了[DIYgod](https://diygod.me/)大佬的博客，看着这精美的主题，再回头审视一下自己使用的简陋到爆的`next`，不禁萌生了更换主题的想法。

<!--more-->

根据`footer`里的信息，我找到了这个主题`Sagiri`的托管地址，将其下载了下来，配置好`_config.yml`文件并`hexo s`，本以为事情就这样结束了。然并卵，我发现有很多功能都无法正常使用，正如他本人在[这篇文章](https://diygod.me/new-blog/)中写的一样：

> 主题虽然开源了，但是属于自用性质的项目，很多应该做成可定制化的地方都没有做，从开源项目的视角来看做得并不好，而我目前又对制作主题并没有太高的兴致，所以使用之前还请慎重考虑

然而这是后话了，当时的我并没有看到这些，于是头铁地开始了主题文件的增删改查之路（此处省略一万字）。

----

四天过去了，通过对文件的深度剖析（指删除很多本来就有的模块然后重新添加），我深刻地了解了`css`、`html`和`javascript`，明白了`hexo`主题的组织形式（并没有），于是准备记录一下这个主题部分特性的实现方式：

1. 网页无刷新跳转/自动滚动到正文

   使用`pjax`实现，主要参考[这篇文章](https://liuyib.github.io/2019/09/24/use-pjax-to-your-site/)。

2. 根据网页状态动态修改标题

   ```javascript
   // cheat.js
   var OriginTitle = document.title;
   var titleTime;
   document.addEventListener('visibilitychange', function () {
       if (document.hidden) {
           $('[rel="icon"]').attr('href', "/images/failure.ico");
           document.title = '╭(°A°`)╮ 页面崩溃啦 ~';
           clearTimeout(titleTime);
       }
       else {
           $('[rel="icon"]').attr('href', "/images/favicon.ico");
           document.title = '(ฅ>ω<*ฅ) 噫又好了~' + OriginTitle;
           titleTime = setTimeout(function () {
               document.title = OriginTitle;
           }, 2000);
       }
   });
   ```

3. 随机的丝带背景

   ```javascript
   // evan-you.js
   /*<canvas id="evanyou"></canvas>*/
   if (document.getElementById('evanyou')) {
     var c = document.getElementById('evanyou'),
       x = c.getContext('2d'),
       pr = window.devicePixelRatio || 1,
       w = window.innerWidth,
       h = window.innerHeight,
       f = 90,
       q,
       m = Math,
       r = 0,
       u = m.PI * 2,
       v = m.cos,
       z = m.random
     c.width = w * pr
     c.height = h * pr
     x.scale(pr, pr)
     x.globalAlpha = 0.6
     function evanyou () {
       x.clearRect(0, 0, w, h)
       q = [{ x: 0, y: h * .7 + f }, { x: 0, y: h * .7 - f }]
       while (q[1].x < w + f) d(q[0], q[1])
     }
     function d (i, j) {
       x.beginPath()
       x.moveTo(i.x, i.y)
       x.lineTo(j.x, j.y)
       var k = j.x + (z() * 2 - 0.25) * f,
         n = y(j.y)
       x.lineTo(k, n)
       x.closePath()
       r -= u / -50
       x.fillStyle = '#' + (v(r) * 127 + 128 << 16 | v(r + u / 3) * 127 + 128 << 8 | v(r + u / 3 * 2) * 127 + 128).toString(16)
       x.fill()
       q[0] = q[1]
       q[1] = { x: k, y: n }
     }
     function y (p) {
       var t = p + (z() * 2 - 1.1) * f
       return (t > h || t < 0) ? y(p) : t
     }
     document.onclick = evanyou
     document.ontouchstart = evanyou
     evanyou()
   }
   ```

4. 点击的烟花效果

   ```javascript
   // fireworks.js
   class Circle {
     constructor({ origin, speed, color, angle, context }) {
       this.origin = origin
       this.position = { ...this.origin }
       this.color = color
       this.speed = speed
       this.angle = angle
       this.context = context
       this.renderCount = 0
     }
   
     draw() {
       this.context.fillStyle = this.color
       this.context.beginPath()
       this.context.arc(this.position.x, this.position.y, 2, 0, Math.PI * 2)
       this.context.fill()
     }
   
     move() {
       this.position.x = (Math.sin(this.angle) * this.speed) + this.position.x
       this.position.y = (Math.cos(this.angle) * this.speed) + this.position.y + (this.renderCount * 0.3)
       this.renderCount++
     }
   }
   
   class Boom {
     constructor ({ origin, context, circleCount = 16, area }) {
       this.origin = origin
       this.context = context
       this.circleCount = circleCount
       this.area = area
       this.stop = false
       this.circles = []
     }
   
     randomArray(range) {
       const length = range.length
       const randomIndex = Math.floor(length * Math.random())
       return range[randomIndex]
     }
   
     randomColor() {
       const range = ['8', '9', 'A', 'B', 'C', 'D', 'E', 'F']
       return '#' + this.randomArray(range) + this.randomArray(range) + this.randomArray(range) + this.randomArray(range) + this.randomArray(range) + this.randomArray(range)
     }
   
     randomRange(start, end) {
       return (end - start) * Math.random() + start
     }
   
     init() {
       for(let i = 0; i < this.circleCount; i++) {
         const circle = new Circle({
           context: this.context,
           origin: this.origin,
           color: this.randomColor(),
           angle: this.randomRange(Math.PI - 1, Math.PI + 1),
           speed: this.randomRange(1, 6)
         })
         this.circles.push(circle)
       }
     }
   
     move() {
       this.circles.forEach((circle, index) => {
         if (circle.position.x > this.area.width || circle.position.y > this.area.height) {
           return this.circles.splice(index, 1)
         }
         circle.move()
       })
       if (this.circles.length == 0) {
         this.stop = true
       }
     }
   
     draw() {
       this.circles.forEach(circle => circle.draw())
     }
   }
   
   class CursorSpecialEffects {
     constructor() {
       this.computerCanvas = document.createElement('canvas')
       this.renderCanvas = document.createElement('canvas')
   
       this.computerContext = this.computerCanvas.getContext('2d')
       this.renderContext = this.renderCanvas.getContext('2d')
   
       this.globalWidth = window.innerWidth
       this.globalHeight = window.innerHeight
   
       this.booms = []
       this.running = false
     }
   
     handleMouseDown(e) {
       const boom = new Boom({
         origin: { x: e.clientX, y: e.clientY },
         context: this.computerContext,
         area: {
           width: this.globalWidth,
           height: this.globalHeight
         }
       })
       boom.init()
       this.booms.push(boom)
       this.running || this.run()
     }
   
     handlePageHide() {
       this.booms = []
       this.running = false
     }
   
     init() {
       const style = this.renderCanvas.style
       style.position = 'fixed'
       style.top = style.left = 0
       style.zIndex = '999999999999999999999999999999999999999999'
       style.pointerEvents = 'none'
   
       style.width = this.renderCanvas.width = this.computerCanvas.width = this.globalWidth
       style.height = this.renderCanvas.height = this.computerCanvas.height = this.globalHeight
   
       document.body.append(this.renderCanvas)
   
       window.addEventListener('mousedown', this.handleMouseDown.bind(this))
       window.addEventListener('pagehide', this.handlePageHide.bind(this))
     }
   
     run() {
       this.running = true
       if (this.booms.length == 0) {
         return this.running = false
       }
   
       requestAnimationFrame(this.run.bind(this))
   
       this.computerContext.clearRect(0, 0, this.globalWidth, this.globalHeight)
       this.renderContext.clearRect(0, 0, this.globalWidth, this.globalHeight)
   
       this.booms.forEach((boom, index) => {
         if (boom.stop) {
           return this.booms.splice(index, 1)
         }
         boom.move()
         boom.draw()
       })
       this.renderContext.drawImage(this.computerCanvas, 0, 0, this.globalWidth, this.globalHeight)
     }
   }
   
   const cursorSpecialEffects = new CursorSpecialEffects()
   cursorSpecialEffects.init()
   ```

5. 侧栏的固定

   使用`affix`实现，主要参考[这篇文章](https://www.runoob.com/bootstrap/bootstrap-affix-plugin.html)。
   
6. `valine`评论系统支持`pjax`

   参考[这个issue](https://github.com/xCss/Valine/issues/138)。

----

害，换个主题真的太难了，**一年之内不打算再换了！**

好了，写完去睡觉啦 XD！

----

***2020.1.30	23:12:33***

全站由`github`迁移到`coding`，国内浏览速度得到大幅提升。（香港服务器就是香啊！）