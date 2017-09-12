## Git远程版本库概念

### 1 裸版本库和开发版本库
Git版本库分为裸版本库和开发版本库：开发版本库常用于日常开发，它有工作目录，可以提供检出版本库中的分支副本，修改工作目录中的当前分支中的文件，提交修改到当前分支。相反，裸版本库没有工作目录，没有检出分支的概念。它的关键角色是作为协作开发的权威焦点。其他开发人员可以从裸版本库中克隆（clone）和抓取（fetch），并推送（push）更新。

### 2 版本库的克隆
git clone命令可以创建一个新的Git版本库，它是基于你通过文件系统或网络地址指定的原始版本库。Git不会复制版本库的所有信息，相反，Git会忽略只跟原始版本库相关的信息如钩子（hooks）、配置文件、引用日志（reflog）和储藏（stash）都不在克隆中重现。在正常使用git clone命令时，原始版本库中存储在refs/heads/下的本地开发分支，会成为新的克隆版本库中refs/remotes/下的远程追踪分支，而原始版本库中refs/remotes/下的远程分支不会被克隆。

默认情况下，每个新克隆的版本库都通过一个称为origin的远程版本库，建立一个链接指回它的父版本库。但是原始版本库并不知道任何克隆版本库，也不维护指向克隆版本库的链接。**这是一个单向关系！**

### 3 远程版本库和远程追踪分支
Git使用远程版本库和远程追踪分支来引用另一个版本库，远程版本库为版本库提供了更友好的名字，可以代替版本库实际的URL。一个远程版本库还形成了该版本库远程追踪分支名字的基本部分。远程追踪分支可以进一步分为不同的类型: 

* 远程追踪分支（remote-tracking branch）与远程版本库相关联，专门用来追踪远程版本库中每个分支的变化。
* 本地追踪分支（local-tracking branch）与远程追踪分支相配对。它是一种集成分支，用于收集本地开发和远程追踪分支中的变更。
* 任何本地的非追踪分支通常称为特性（topic）或开发（development）分支。
* 远程分支（remote branch）是一个远程版本库的分支，很可能是远程跟踪分支的上游源。

因为远程追踪分支专门用于追踪另一个版本库中的变化，所以你应该把它们当作是只读的。不应合并或提交到一个远程追踪分支。这样做会导致你的远程追踪分支变得和远程版本库不同步。更糟糕的是，将来每个从远程版本库的更新都可能需要进行合并，这会使你的克隆越来越难以管理。

### 4 Git支持的远程版本库的协议
在Git中常用的远程版本库的协议有四种：本地文件系统（包括网上文件系统NFS挂载到本地的虚拟文件系统）、git原生协议（这种协议主要是无法控制用户认证，所有的用户都可以使用这种协议来pull、push操作）、HTTP协议和SSH协议。后面两种是常用的Git远程通信协议，HTTP经过优化后现在和SSH的效率基本差不多了，而SSH协议是比较安全并且高效的协议推荐使用。以下是这几种协议的URL：
* 本地文件系统  /path/to/repo.git
* git原生协议   git://example.com/path/to/repo.git
* HTTP协议  http://example.com/path/to/repo.git
* SSH协议   ssh://[user@]example.com[:port]/pah/to/repo.git

### 5 refspec
如何在版本库历史中指定一个特定的提交。通常引用一个分支名。refspec把远程版本库中的分支名映射到本地版本库中的分支名。在refspec中，你通常会看到开发分支名有refs/heads/前缀,远程追踪分支名有refs/remotes/前缀。refspec语法：
```
[+]source:destination
```
前面可选的加号`+`，如果有加号则表示不会再传输中进行快进安全检查。此外，星号`*`允许用有限形式的通配符匹配分支名。一般git fetch默认的refspec如下：
```
+refs/heads/*:refs/remotes/remote/*
```
此处的refspec可以这样解释：
* 在命名空间refs/heads/中来自远程版本库的所有源分支映射到本地版本库。
* 使用远程版本库名来构建名字，并放在refs/remotes/remote命名空间中。
一般git push操作使用这样的一个refspec。
```
+refs/heads/*:refs/heads/*
```
此处的refspec可以这样解释：
* 从本地版本库中，将源命名空间refs/heads/下发现的所有分支名，放在远程版本库的目标命名空间refs/heads/下的匹配分支中，使用相似的名字来命名。

>可以使用`git show-ref`查看当前版本库中的引用。使用`git ls-remote`版本库列出远程版本库的引用。  

### 6 git pull 与 git push

完整的`git pull`命令允许指定版本库和多个refspec：`git pull 版本库 refspec`。如果不在命令行上指定版本库，无论是通过Git URL还是间接通过远程版本库名，则使用默认的origin远程版本库。如果你没有在命令行上指定refspec，则使用远程版本库的抓取（fetch）refspec。如果指定版本库（直接或使用远程版本库），但是没有指定refspec，git会抓取远程版本库的HEAD引用。`git pull`操作有两个根本步骤，每个步骤都由独立的git命令实现。也就是说，`git pull`意味着先执行`git fetch`，然后执行`git merge`或`git rebase`。默认情况下第二步是merge。  

抓取步骤：在最开始的抓取步骤中，Git先定位远程版本库。该远程版本库的信息在配置文件中：
```
[remote "origin"]
    url = /path/to/remote/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```
此外，由于没在命令行中指定refspec，Git会使用remote条目中的所有“fetch=”的行。也不必使用refs/heads/*的通配符来获取远程版本库的所有特性分支。可以明确地指出它们。

合并或变基步骤：Git使用一种特殊类型的合并操作快进（fast-forward），合并远程追踪分支origin/master的内容到你的本地追踪分支master分支。配置信息如下：
```
[branch "master"]
    remote = origin
    merge = refs/heads/master
```
以上配置信息解释如下:当master分支是当前检出分支时，使用origin作为fetch（或pull）操作过程中获取更新的默认远程版本库。此外，在`git pull`的merge步骤中，用远程版本库中的refs/heads/master作为默认分支合并到master分支。

`git push`操作是把当前master分支推送到origin远程版本库的简便方法。这个操作有两步，第一步：提取当前master分支的变更，将它们捆绑在一起，发送到名为origin的远程版本库中。同时将这些变更添加到当前版本库的远程追踪分支origin/master中。实际上就是Git使原本在当前master分支的变更发送到远程版本库，然后再请求把它们放回origin/master远程追踪分支。

### 7 追踪分支
克隆版本库的master分支可以被认为是origin/master分支引进的开发扩展，Git通过使用一致的引用名称来很容易地创建本地和远程追踪分支对。使用远程追踪分支名的一个简单的检出请求会导致创建一个新的本地追踪分支，并与该远程追踪分支相关联。
