---
title: 免费获取Let's Encrypt泛域名证书
date: 2020-07-30 19:10:21
tags: website
categories: 网站建设
---

去年在`GoDaddy`买的`jeasonlau.xyz`域名即将到期，然而最近囊中羞涩续费不起了，于是考虑将网站业务迁移到`allwens.work`域名下。

目前在`jeasonlau.xyz`域名下的服务主要有我的马原毛概刷题工具、用于订阅`RSS`的`RSSHub`和个人使用的`Cloudreve`网盘，迁移的话我打算将其挂在不同的子域名下，所以打算看看能不能免费申请一张泛域名证书，结果还真找到了教程。

按着教程走了一遍，整个流程不过十分钟，非常方便，本文主要记录一下申请过程。😆

<!-- more -->

## 安装`acme.sh`

`Let's Encrypt`官方提供了一系列的申请方法文档，但流程比较复杂。我们使用第三方工具`acme.sh`来简化申请流程。

首先安装`acme.sh`：

```bash
curl  https://get.acme.sh | sh
```

该脚本进行的操作有：

+ 将`acme.sh`安装到`~/.acme.sh/`；
+ `alias acme.sh = ~/.acme.sh/acme.sh`，达到类似安装到环境变量中的效果；
+ 自动创建`cronjob`脚本，每天自动检测证书，如果快过期则自动更新。

## 使用`DNS-API`验证获取证书

参考[acme.sh文档](https://github.com/acmesh-official/acme.sh/wiki/How-to-issue-a-cert)可以发现，我们可以用很多种方式进行域名验证来得到证书。因为我的服务器未备案，所以`web`的那几种方式用起来都不是很方便，最终我选用了`DNS-API`来进行验证。

`DNS`验证指的是通过在你域名的DNS解析中加入指定的`txt`记录来验证你对域名的所有权，而`DNS-API`则是通过使用DNS提供商的API自动进行`txt`记录的增加和删除，达到自动验证的效果。

对于不同的提供商，需要不同的`API key`，可以[点击此处](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)查看详细教程，此处以阿里云为例。

1. 首先在[阿里云账号的API管理](https://ak-console.aliyun.com/#/accesskey)中获取到`AccessKey ID`和`AccessKey Secret`

2. 在服务器中执行

   ```bash
   export Ali_Key = AccessKey ID
   export Ali_Secret = AccessKey Secret
   ```

3. 运行以下命令获取证书（以`allwens.work`为例）

   ```bash
   acme.sh --issue --dns dns_ali -d allwens.work -d *.allwens.work
   ```

   完成后，证书文件将会存放在`～/.acme.sh/allwens.work`中，后续`acme.sh`将会自动更新该文件夹内的证书。

   我目前尚不清楚更新时是否需要API，因此为了保险又将第二步创建环境变量的语句写到了`~/.zshrc`中。

## 在web服务器中使用证书

因为嫌原有的路径名过长，所以我首先在`/etc`下新建了`cert`文件夹，做了一个软链接：

```bash
sudo mkdir /etc/cert
cd /etc/cert
ln -s ~/.acme.sh/allwens.work/allwens.work.cer ./
ln -s ~/.acme.sh/allwens.work/allwens.work.key ./
```

接着打开web服务器的配置文件（以`nginx`为例），找到需要使用证书的`Server`块：

```nginx
# Cloudreve
server {
        server_name drive.allwens.work;
        location / {
                proxy_pass http://localhost:5212;
        }
        client_max_body_size 30g;
        error_page 497 =301 https://$http_host$request_uri;
        listen 10000;
        # 加入如下三行
        ssl on;
        ssl_certificate /etc/cert/allwens.work.cer;
        ssl_certificate_key /etc/cert/allwens.work.key;
```

接着让`nginx`重新加载配置文件即可：

```bash
nginx -s reload
```



