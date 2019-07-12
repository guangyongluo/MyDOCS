### github上的提交没有在用户首页profile上显示

好久没有更新MyDOCS库了，最近有点点迷茫感觉自己年纪大了有很多局限。以前年轻时的梦想还能不能这么执着，
还能不能在有生之年实现，心中有很多不舍和不甘。作为一名在IT职场混迹多年的我一直都与自己的期望有很大落
差，一路走来读书时的抑郁在研究生期间达到了顶峰，所以一直徘徊不前。在30岁的时候才真正想清楚自己的职业
理想和抱负。在银行这小五年，自己从来不敢放松读书学习，当同事们都回家老婆孩子热炕头的时候我还在单位研
究时下最新最流行的技术。我也就偶尔在金鸡湖边走走也算难得的轻松惬意了，平时工作学习累了手机一拿起来就最少
半个小时，有时感觉自己在浪费时间，现代人太依赖手机了拿起了就放不下，给自己在下半年定个小目标，Forest
上周一到周五上班时间最少3个小时，不做到不下班。这小五年的时间是真正的技术积累时间，自学了很多应知应会
的技术，同时也感叹世界变化太快了，编程以后越来越傻瓜。在积累技术的同时我还要一个英语梦没有实现。往后
放放吧，毕竟人的精力太有限。这4年半我从Java的最底层开始一路Java web、多线程、git、maven、spring、hibernate
、springboot、JavaScript、bootrap。在系统管理上也有几年的经营对linux整体有了更全面的理解。接下来的几个月
必须完成的有spring加强、springboot\springcloud还有nosql数据库redis和MongoDB。最后就是中间件MQ(RabbitMQ\kafka)。

######生命不停，折腾不止 -- 罗葳

言归正传，从本次更新开始，我将争取把文章写得通俗易懂，向行业内那些码子大神致敬。本人能力有限，也请各位
同行批评指正。这篇软文针对更新了设备后提交到github上的变更在贡献墙上没有绿色显示的问题。github上计算
贡献是跟提交时的用户民和邮箱然后和github账户用户名和邮箱匹配，将提交计入对应的用户贡献墙。所以一般在更
换设备后亦或是修改用户名和邮箱后可能就会出现在用户贡献墙上没有绿点显示的问题。这时需要对比一下github里
提交的用户就会发现问题，提交的用户跟你查看用户的用户名不一致。查看本地设备git全局设置命令：
`git config --global --list`
修改本地设备git全局配置参数：
`git config --global user.name`
`git config --global user.email`
如果不想修改github版本库上的提交信息最简单的方式就是将本地git全局配置中的用户名和邮箱改成跟github一致。
如果已经将错误的用户信息提交到github上了，则需要按照下面的步骤来修改github版本库上的提交用户信息。

* 克隆版本库到本地
`git clone --bare ***.git`
* 转到版本库目录
`cd ***.git`
* 编写修改版本库提交信息的脚本
```
#!/bin/sh

git filter-branch -f --env-filter '

OLD_EMAIL="以前的用户名通过github上页面commit信息查看"
CORRECT_NAME="修改后本地全局配置的用户名"
CORRECT_EMAIL="修改后本地全局配置的邮箱"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```
* 保存脚本文件
* 赋予脚本执行权限(755尚可)
* 等待执行完成后将修改的信息推送到github上
`git push --force --tags origin 'refs/heads/*'`
* 最后删除临时库
`rm -rf ***.git/`