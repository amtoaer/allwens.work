---
title: php表单提交并自动发送邮件
date: 2019-10-29 21:41:34
tags: [php,website]
categories: 网站建设
photos: /img/banner/images/6.jpg
description: 完成网站的表单提交
---

最近在[html5up](https://html5up.net/)上淘了个主页模板，模板底有一个表单，今天在修改模板的时候，朋友提起可以配置表单实现提交表单时自动发送邮件通知，于是就萌生了这个想法，结果没想到一搞就是三四个小时（主要是因为网上的某些“教程”太坑人了！），所以记录一下配置过程给后来人参考。

<!--more-->

# 给服务器安装php,php-fpm

作者使用的是ubuntu18.04，所以使用

```bash
sudo apt-get install php
sudo apt-get install php-fpm
```

# web服务器添加php支持



作者使用的是nginx，为支持php需要修改一下配置文件，网上不少教程说要改`nginx.conf`，但我发现我这里的配置文件和他们的有很大差异，后来实测修改`/etc/nginx/sites-available/default`有效。将文件与php有关部分修改为：

```bash
        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html index.php;

        server_name _;
        
		# nginx不允许静态文件响应post请求，会出现405 not allowed提示，所以需要添加以下内容
		# 需要开启8080端口，或者可以修改为目前已经开启的端口（或许）
        error_page  405 =200 @405;
        location @405 {
            proxy_method GET;
            proxy_pass http://你的地址:8080;
        }

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }

        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;

                # With php-fpm (or other unix sockets):
                # 这里需要把php7.2修改为安装php时显示的版本
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
                # With php-cgi (or other tcp sockets):
                # fastcgi_pass 127.0.0.1:9000;
        }

```

# 修改表单所在的html文件

接下来打开表单所在的html文件，修改form标签，例如我的：

```html
<!--其实粘贴这么多只是想说form标签需要加个action="mail.php"啦（滑稽）-->
<form method="post" action="mail.php">
    <div class="fields">
        <div class="field half">
            <label for="name">Name</label>
            <input type="text" name="name" id="name" />
        </div>
        <div class="field half">
            <label for="email">Email</label>
            <input type="text" name="email" id="email" />
        </div>
        <div class="field">
            <label for="message">Message</label>
            <textarea name="message" id="message" rows="6"></textarea>
        </div>
    </div>
    <ul class="actions">
        <li><input type="submit" value="Send Message" class="primary" /></li>
        <li><input type="reset" value="Clear" /></li>
    </ul>
</form>
```

# 配置mail.php文件

form提交将会调用mail.php文件，接下来就需要配置它了。我浏览了许多网站，发现网上大体只有两个模板，即[这个](https://jingyan.baidu.com/article/636f38bb482efcd6b8461019.html)和[这个](https://www.jb51.net/article/62543.htm)。但亲身体验后发现都！不！能！用！第一个是单纯的配置文件问题，我把各项修改好后还是不能用。（或许是因为我多删了点东西？）第二个则使用了php的mail()函数，不过很不幸的是，正如这篇[最后解决我问题的文章](https://www.jianshu.com/p/03e02c58200a)中写的一样：

> PHP环境下，是提供了发送邮件的函数`mail()`的，不过该函数要求服务器支持sendmail或者必须设置一台不需要中继的邮件发送服务器，但现在要找到一台不需要身份验证的邮件发送中继几乎不可能，所以使用mail函数往往无法成功发送电子邮件。

mail()函数确实无法成功发送邮件。这篇文章同样给出了一个解决办法，就是使用[PHPMailer](https://github.com/PHPMailer/PHPMailer)。

将其`git clone`到服务器并解压，mail.php只需按照README.md中所给的Example进行微量修改，我的大概为：

```php
<?php
// Import PHPMailer classes into the global namespace
// These must be at the top of your script, not inside a function
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

// 修改这三个文件的路径为服务器路径
require './PHPMailer/src/Exception.php';
require './PHPMailer/src/PHPMailer.php';
require './PHPMailer/src/SMTP.php';

// 这里将内容对应改成form标签中各项的名字
$email=$_POST['email'];
$name=$_POST['name'];
$message=$_POST['message'];

// Instantiation and passing `true` enables exceptions
$mail = new PHPMailer(true);

// 这里我使用的是qq邮箱，其它邮箱同理
try {
    //Server settings
    $mail->SMTPDebug = SMTP::DEBUG_SERVER;                      // Enable verbose debug output
    $mail->isSMTP();                                            // Send using SMTP
    $mail->Host       = 'smtp.qq.com';                    // Set the SMTP server to send through
    $mail->SMTPAuth   = true;                                   // Enable SMTP authentication
    $mail->Username   = '邮箱的用户名';                     // SMTP username
    $mail->Password   = '邮箱的密码';                               // SMTP password
//    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;         // Enable TLS encryption; `PHPMailer::ENCRYPTION_SMTPS` also accepted
    $mail->SMTPSecure = 'ssl';
    $mail->Port       = 465;                                    // TCP port to connect to

    //Recipients
    $mail->setFrom('邮箱的用户名', '随便填个昵称');
    $mail->addAddress('发送到的邮箱', '随便填个昵称');     // Add a recipient
    
//	后边的那些我不用，就注释掉了
//    $mail->addAddress('ellen@example.com');               // Name is optional
//    $mail->addReplyTo('info@example.com', 'Information');
//    $mail->addCC('cc@example.com');
//    $mail->addBCC('bcc@example.com');

    // Attachments
//    $mail->addAttachment('/var/tmp/file.tar.gz');         // Add attachments
//    $mail->addAttachment('/tmp/image.jpg', 'new.jpg');    // Optional name

    // Content
    $mail->isHTML(true);                                  // Set email format to HTML
    $mail->Subject = "An E-mail from $email";
    $mail->Body = "This e-mail is written by $name : $message";
    
    // 我在测试时，AltBody中的内容并不会在邮件中显示出来，目前暂时不清楚有什么用
    $mail->AltBody = "";

    $mail->send();
    echo 'Message has been sent';
} catch (Exception $e) {
    echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
}
```

# 提交不跳转方法

经过以上配置之后，你的表单应该可以正常发送邮件了，唯一的不足是在点击提交之后会跳转出现一堆提示信息，影响观感，[这篇文章](https://segmentfault.com/a/1190000000461339)中给出了一种可行方法，即为`form`标签加入target属性并添加`iframe`标签。以我的表单为例，需要将`form`标签修改为：

```html
<form method="post" action="mail.php" target="id_iframe">
```

并在其后添加：

```html
<iframe id="id_iframe" name="id_iframe" style=""></iframe>
```

这样修改虽然有效，但会在点击提交之后出现一个简陋的框体，其中显示的内容就是之前跳转后的提示信息。这没有达到我们的目的，于是想到将`iframe`标签隐藏，也就是将其的高度和宽度设置为0：

```html
<iframe id="id_iframe" name="id_iframe" style="" width="0" height="0"></iframe>
```

可这样又会出现一个问题，点击按钮之后邮件到底有没有发送成功是未知的，因为所有的提示信息都被隐藏掉了，那该怎么办呢？我想到的是，将原来php文件中的两个用于输出提示信息的`echo`修改成`echo "<script>alert('内容')</script>"`，也就是：

```php
echo 'Message has been sent';
// 替换为
echo "<script>alert('Message has been sent')</script>";

echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
// 替换为
echo "<script>alert('Message could not be sent.')</script>";
```

这样的话就可以实现网页弹窗提示邮件发送结果而不跳转了。

# 效果预览



![填写表单](https://img.vim-cn.com/46/d7b3a55d08f29baa98472640716e9a8ae06907.jpg "填写表单")

![点击提交](https://img.vim-cn.com/ea/1a881a1eb0565d390f224777de31823efaaeb4.jpg "点击提交")

![收到邮件](https://img.vim-cn.com/53/10173e2b8b20b797906fa6d25ef0aa769439a8.jpg "收到邮件")

# 结语

总体来说，以上实现方式虽然可以正常使用，但是还有很大改进空间，比如提交不跳转的实现方式。不过毕竟自己没有系统学习过web方面的知识，也只能得过且过了。等什么时候能闲下来再考虑改进吧（笑）。也欢迎大家在评论里给我提建议吖！（话说这篇文章真的有人看吗？！）