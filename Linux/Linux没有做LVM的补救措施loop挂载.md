### Linux限制文件系统大小的补救办法loop挂载
说明：回环设备可以把文件虚拟成块设备，以便模拟整个文件系统，这样用户可以将其看作是硬盘驱动器或者光驱等设备，并挂载当作文件系统来使用。这样系统还
可以额外增加多个分区(默认只有loop0-loop7)


###### 挂载步骤
1. dd if=/dev/zero of=/opt/ITMsize bs=10M count=512 
         →创建一个5G的文件/opt/ITMsize，该文件为了给loop赋予空间
   du -sh /opt/ITMsize
         →查看是否创建成功创建5G大小的该文件
   如图：
   
   
![图1-1][loop_mount01]


【注】请勿在执行以上命令前自己创建该文件

2. losetup -a
		 →查看所有已使用的回环设备状态
   【无任务输出，则没有使用过任何回环设备】

3. losetup -f
        →查找第一个未使用的回环设备
   【若/dev/loop0已被使用，则/dev/loop1默认成为第一个未使用回环设备】
例如：图中所示/opt/test已使用了/dev/loop0,所以losetup -f 查看到的的第一个未使用的回环设备便是/dev/lopp1，依次类推...


![图1-2][loop_mount02]

4. losetup -f /opt/ITMsize
        →将/opt/ITMsize虚拟为第一个未使用的回环设备
    即为/dev/loop0赋予空间，在这里我默认系统中的回环设备都未被使用，具体生产中请大家看好回环设备号

  losetup -a
        →查看是否成功添加回环设备 
  如图：
  
  
![图1-3][loop_mount03]

5. mkfs -t ext3 /dev/loop0
        →将虚拟过的回环设备格式化，这里格式化为ext3文件系统（以实际情况为准）
   如图：
   
   
![图1-4][loop_mount04]

6. mount /dev/loop0 /opt/itm6
        →将格式化之后的回环设备挂载到将要使用的/opt/itm6目录下
   df -h 
        →查看挂载的系统空间信息
  如图：
  
  
![图1-5][loop_mount05]


![图1-6][loop_mount06]

至此利用losetup虚拟出块设备(文件系统）的设置已完成

###### 卸载步骤
【如何卸载回环设备步骤如下】
  
1、umount /opt/itm6/logs 
         →取消挂载目录
   df -h
         →查看挂载的系统空间信息（已无/opt/itm6/logs信息）
   如图：
   
   
![图1-7][loop_mount07]    

2、losetup -d /dev/loop0
         →取消回环设备
  losetup -a
         →查看所有已使用的回环设备状态
           （已无/dev/loop0信息）  
  如图：
  
  
![图1-8][loop_mount08] 

###### 如何设置开机挂载


[loop_mount01]: ../image/loop_mount01.png "图1-1"
[loop_mount02]: ../image/loop_mount02.png "图1-2"
[loop_mount03]: ../image/loop_mount03.png "图1-3"
[loop_mount04]: ../image/loop_mount04.png "图1-4"
[loop_mount05]: ../image/loop_mount05.png "图1-5"
[loop_mount06]: ../image/loop_mount06.png "图1-6"
[loop_mount07]: ../image/loop_mount07.png "图1-7"
[loop_mount08]: ../image/loop_mount08.png "图1-8"