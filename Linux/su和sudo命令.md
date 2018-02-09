### `su`和`sudo`命令

##### login与non-login shell
* login shell：取得bash时需要完整的登入流程，就称为login shell。举例来说，你要由tty1~tty6登入，需要输入用户的账户与密码，此时取得的bash就称为“login shell”。
* non-login shell：取得bash接口的方法不需要重复登入的动作，举例来说，你以X Window登入Linux后，再以X的图形界面启动终端机，此时那个终端接口并没有需要再次输入账户与密码，那个bash的环境就称为non-login shell了，你在原本的bash环境下再次执行bash这个命令，同样也没有输入账户密码，那第二个bash(子进程)也是non-login shell。
* 一般来说login shell其实只会读取连个配置文件：1./etc/profile：这是系统整体设置，最好不要修改； 2.~/.bash_profile或~/.bash_login或~/.profile:这些文件都属于用户个人配置，你要改自己的数据，就写入这里。
* /etc/profile：这个文件根据用户的id来决定很多重要的变量数据，每个用户登入时都会读取该配置文件。这个文件主要设置的环境变量有：
    1. PATH：主要应用程序的根路径；
    2. MAIL：登入用户的邮箱；
    3. USER：登入用户名字；
    4. HOSTNAME：登入的主机名；
    5. HISTSIZE：历史命令记录条数；  
在/etc/profile文件里还调用了其他的文件主要有: /etc/inputrc：用户自定义按键功能；/etc/profile/*.sh：只要登入用户对这些脚本有读的权限在登入时就会被读取，这些脚本主要定义了与登入bash相关的环境变量；
* \~/.bash_profile：当读取完了/etc/profile的系统登入环境变量后，就可以读取每个登入用户个人主目录下的bash环境变量，其实bash的login shell设置主要会按序读取三个文件~/.bash_profile、\~/.bash_login、\~/.profile中的一个。也就是说如果~/.bash_profile存在，其他的两个无论有没有都不会读取，如果~/.bash_profile不存在才会读取~/.bash_login，而前面两者都不存在才会读取~/.profile。同时在~/.bash_profile中还调用了~/.bashrc
* \~/.bashrc：当你取得non-login shell时，该bash配置文件仅会读取~/.bashrc配置文件。该文件主要的工作是根据登入用户的id指定umask值，指定bash提示符等。

##### `su`命令
1.`su`是最简单的身份切换命令，它可以进行任何身份的切换。要注意的是`su username`和`su - username`两种形式，这两种形式的主要区别在于login-shell配置文件读取方式,单纯的使用`su`切换成为root的身份，读取的变量设置方式为non-login shell的方式，这种方式下很多原本的环境变量不会改变，尤其是我们之前谈过很多次的PATH这个变量，由于没有改变成为root的环境(一堆/sbin、/usr/sbin等目录都没有被加进环境变量)，因此很多root惯用的命令就只能使用绝对路劲来执行了。

2.`su`命令的使用如下：
* 想要完全切换到新用户的环境，必须使用`su - username`或`su -l username`，这样才会连同环境变量一起切换；
* 如果仅想执行一次root的命令，可以利用`su - -c 命令串`的方式来处理；
* 使用root切换成为任何用户时，并不是需要输入普通用户的密码。

##### `sudo`命令
1.`sudo`可以让你以其他用户的身份执行命令(通常是使用root的身份来执行命令),仅有/etc/sudoers内的用户才能够执行sudo这个命令。`sudo`命令的使用形式：`sudo -u username 命令`，如果不加-u username就代表切换root身份。sudo的执行顺序如下：
* 当用户执行sudo时，系统于/etc/sudoers文件中查找用户是否有执行sudo的权限；
* 若用户具有可执行sudo权限后，便让用户输入自己的密码来确认；
* 若密码输入成功，便开始进行sudo后续的命令(但root不需要密码)；
* 若欲切换的身份与执行者身份相同，也不需要密码。
2
##### visudo与/etc/sudoers
除了root之外的其他账号，若想要使用sudo执行属于root的权限命令，则root需要先使用visudo去修改/etc/sudoers，让该账号能够使用全部部分root命令。
* 单一用户可进行root所有命令与sudoers文件的语法例如：`sysadmin    ALL=(ALL)    ALL`，上面这行的四个参数意义是1.用户账号，2.登入者的来源主机名，3.可切换的身份，4.可执行的命令。
* 利用用户组以及免密码例如：`%wheel    ALL=(ALL)    NOPASSWD:ALL`，用户组名前需要加%符区别，在可执行命令前加NOPASSWD可以实现免密码功能。
* 有限制的命令：对于像要让用户禁用默写命令，可以在全路劲命令前加!符来禁用这些命令例如：`myuser    ALL=(root)    !/usr/bin/passwd, /usr/bin/passwd [A-Z][a-z]*, !/usr/bin/passwd root`，上面这行的意思是可以使用passwd 任意字符但是`passwd`和`passwd root`除外。
* 通过别名设置visudo：可以这样定义别名例如：`User_Alias ADMPW = user1, user2, user3`,`Cmnd_Alias ADMPWCOM = !/usr/bin/passwd, /usr/bin/passwd [A-Z][a-z]*, !/usr/bin/passwd root`,上面两个例子一个是定义用户别名，一个是定义可执行命令别名。
* sudo搭配su的使用方式：想要不输密码su到某个用户上可以使用以下visudo语法：`user1    ALL=(ALL)    NOPASSWD:/bin/su - user2`，当user1在当前环境下使用sudo su - user2就可以直接切换到user2的环境中去，而不用输入密码。
