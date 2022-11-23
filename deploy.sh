# 发生错误时终止
set -e

git add .
git commit -m "site update"
git push origin master

# 构建
sudo hexo g -d
