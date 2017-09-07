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



