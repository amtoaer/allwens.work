#!/bin/bash

# 切换到番组目录
cd source/bangumi
# 下载番组生成工具
curl -L -O https://github.com/amtoaer/AnimePage-for-hexo-theme-sakura/releases/download/0.1.4/GenerateAnimePage
# 给予可执行权限
chmod +x ./GenerateAnimePage
# 生成文件内容并覆盖本地番组的index.md
./GenerateAnimePage amtoaer
# 删除番组生成工具
rm ./GenerateAnimePage 
# 返回原目录
cd ../../ 
# hexo生成静态网页
hexo generate
