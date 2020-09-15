---
title: 一个简单的命令行图床上传工具
date: 2020-02-29 13:37:06
tags: [python,image]
categories: 开发记录
photos: /img/banner/images/15.png
description: 使用缩狗图床api写成的命令行图床上传工具
---

昨天使用[缩狗图床](https://pic.suo.dog)`api`写了个[命令行图床上传工具](https://github.com/jeasonlau/python-scripts/blob/master/imagehost.py)，支持指定使用的图床，支持单文件/多文件/多目录（非递归）上传。虽然代码很简单，但还是准备记录一下（因为想水篇文章XD

<!--more-->

## 获取api

既然要使用`api`，当然要获取`api`啦，首先看一下网站源码（此处只摘录了有用部分）：

```html
<!--图床的选择-->
<div class="bodyer">
    <label><input name="keke" checked="checked" type="radio" value="1688">阿里图床</label>
    <label><input name="keke" type="radio" value="tieba">百度图床</label>
    <label><input name="keke" type="radio" value="360">360图床</label>
    <label><input name="keke" type="radio" value="taobao">淘宝图床</label>
    <label><input name="keke" type="radio" value="smms">SM.MS图床</label>
    <label><input name="keke" type="radio" value="sohu">搜狐图床</label>
    <label><input name="keke" type="radio" value="jd">京东图床</label>
</div>
<!--图片的上传-->
<script>
    var imagesUpload = function (files) {
        a = $('input:radio:checked').val();
        $(files).each(function (key, value) {
            setTimeout(function () {
                uurrll = 'https://pic.suo.dog/api/tc.php?type=' + a + '&echo=imgurl'
                image_form = new FormData();
                image_form.append("file", value);
                $.ajax({
                    url: uurrll,
                    type: 'POST',
                    data: image_form,
                    contentType: false,
                    cache: false,
                    processData: false,
                    async: false,
                    success: function (data) {
                        if (typeof (data) == 'string') {
                            imgurl = data
                        } else {
                            imgurl = data.imgurl
                        }
                    },
                    error: function (XMLResponse) {
                        alert("error:" + XMLResponse.responseText);
                    }
                });
            }, 100);
        })
    };
</script>
```

上面的代码还是很清楚的，用选择器获取当前选中`radio`的`value`，使用其拼接需要请求的`api`，接着用`ajax`将文件数据`post`到`api`，成功后返回图片的地址。

## 开始编写

有了`api`，接下来就很简单了，基本思路就是：

1. 打开文件
2. 使用`requests`进行`post`
3. 输出返回的图片`url`

----

使用了`requests`/`click`/`os`三个包。缺少的包可以使用`sudo pip install 包名`安装。

首先将允许的图片文件拓展名和`api`地址设置为全局变量：

```python
# 这里列举了几种常见的图片格式，其它格式可以修改后自行测试
allowedExtension = ['.jpeg', '.bmp', '.jpg', '.png', '.webp']
url = ''
```

接着使用`click`为`main`函数增加命令行参数：

```python
@click.command()
@click.option('--type', '-t', default='1688', type=click.Choice(['1688', 'tieba', '360', 'taobao', 'smms', 'sohu', 'jd']), help='image hosting service.')
@click.argument('paths', nargs=-1, type=click.Path(exists=True, readable=True))
```

`--type/-t option`用于指定使用的图床，限制了图床的选择范围，默认使用阿里图床，`paths argument`接受多个路径参数，在此处保证了目录存在并可读。

然后是`main`函数：

```python
def main(type, paths):
    global url
    url = 'https://pic.suo.dog/api/tc.php?type={}&echo=imgurl'.format(type)
    count = 0
    print('\033[33m开始上传...\033[0m')
    for path in paths:
        if os.path.isdir(path):
            if not path.endswith('/'):
                path += '/'
            items = os.listdir(path)
            for item in items:
                if os.path.isfile(path + item):
                    count += uploadFile(path + item)
        else:
            count += uploadFile(path)
    print('\033[33m上传完成，共上传{}张图片!\033[0m'.format(count))
```

> 类似于`\033[33m开始上传...\033[0m`的格式是为了实现彩色输出，详情见[该文章](https://www.liuhaolin.com/linux/318.html)。

使用获取到的`type`组成`url`，使用`count`标记上传图片的张数，遍历所有的路径参数，如果该路径参数为目录，则尝试上传该目录的所有文件，如果该路径参数为文件，则直接尝试上传该文件。最后输出上传的图片张数。

之后是核心的上传函数：

```python
def uploadFile(file):
    if os.path.splitext(file)[-1] in allowedExtension:
        postContent = {'file': open(file, 'rb')}
        with requests.post(url, files=postContent) as response:
            print('\033[31m{}\033[0m : \033[4;32m{}\033[0m'.format(
                os.path.basename(file), response.text))
        return 1
    else:
        return 0
```

判断拓展名是否允许，如果允许则将该文件用二进制打开，`post`给`api`，输出文件名和上传的地址，返回`1`，否则返回`0`。

最后的内容就不用说了：

```python
if __name__ == '__main__':
    main()
```

## 使用截图

> 该截图同样使用该工具上传（使用`阿里图床/--type 1688`）

![](https://ae01.alicdn.com/kf/U7999450fd3164007a8ced5305332715ep.png)

## 结语

啊，没想到这么几行代码居然能水这么长一篇文章！（滑稽

目前`1688`图床可以正常使用，其它图床没有测试，如果有什么问题的话可以反馈给我。