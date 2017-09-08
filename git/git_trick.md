# Git 使用小技巧

#### 去掉Windows Git Bash中的回车换行警告
Windows默认设置，提交时转换为LF，检出时转换为CRLF
```
git config --global core.autocrlf true
```

允许提交包含混合换行符的文件
```
git config --global core.safe false
```


#### 查看git log的历史
``` 
git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short  
```

#### 设置git别名
```
git config –-global alias.ci commit
```

#### 设置Windows Git Bash的HTTP协议凭证托管
```
git config –-global credential.helper wincred
```

#### 生成SSH协议的公私密钥对
```
ssh-Keygen -t rsa -C "your email"
```

#### 更改远程仓库协议
```
git remote set-url origin "your git repository url"
```
