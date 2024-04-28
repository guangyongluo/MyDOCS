# PHP8快速入门

### 1、PHP是什么

> PHP(Hypertext Preprocessor 超文本预处理器) 的简称，是一种被广泛应用的开源通用的服务器端脚本语言，适用于 Web 开发并可嵌入 HTML 中。

- 通用：指跨平台，如：Windows、Linux、MacOS
- 开源：意味着你可以轻松获取全部源代码，并进行定制或扩展
- 免费：意味着你不必为PHP花一分钱，哪怕用在商业项目中
- 服务器端：意味着你必须将它安装在服务器环境下才可以使用
- 脚本语言：解释型语言，按编写顺序执行。是指不需要编译,直接由解释器/虚拟机执行的编程语言

### 2、PHP能做什么

- 可以快速动态的生成HTML页面
- 可以返回前端需要的各种类型的数据
- 可以高效安全的处理表单数据
- 可以安全的操作服务器上的文件
- 可以控制与客户端的会话( Cookie/Session )
- 可以对用户的行为进行授权控制
- 可以高效安全的操作各种类型的数据库
- 通过扩展，可以实现加密，压缩等其他功能
- 可以提供接口数据，包括：小程序、APP、等其他语言

### 3、php程序

- PHP 文件的默认扩展名是 ".php"
- PHP 文件中可以包含 `html`、`CSS`、`JavaScript` 代码

| 序号 | 组成           | 描述                              |
| ---- | -------------- | --------------------------------- |
| 1    | `<?php ... ?>` | PHP 标记                          |
| 2    | PHP代码        | 函数、数组、流程控制、类、方法... |
| 3    | `;`、`{}`      | 语句结束符                        |
| 4    | 空白符         | 合理使用空白符可增强代码可读性    |
| 5    | 注释           | `// 单行注释`, `/* 多行注释 */`   |

##### 1、PHP标记

- 开始标记 `<?php` 和 结束标记 `?>` 中间写 `PHP` 代码

当解析一个文件时，`PHP` 会寻找起始和结束标记，也就是告诉 `PHP` 开始和停止解析二者之间的代码。此种解析方式使得 `PHP` 可以被嵌入到各种不同的文档中去，而任何起始和结束标记之外的部分都会被 `PHP` 解析器忽略。

```php
<?php

?>
```

##### 2、PHP代码

| 序号 | 指令    | 描述                                    |
| ---- | ------- | --------------------------------------- |
| 1    | `echo`  | 可以输出一个或多个字符串，用逗号(,)隔开 |
| 2    | `print` | 只允许输出一个字符串                    |

```php
<?php
    echo 111,222
    print 111
?>
```

> 备：上面代码报错，因为没有结束符

##### 3、语句结束符 `;`

```php
<?php
    echo 111,222;
    print 111;
?>
```

##### 4、注释

```php
<?php
    // 这是单行注释
    /*
        这是多行注释
        注释后，在浏览器和网页源码中，是看不到的。
    */
?>
```

------

### 4、php 变量

##### 1、声明变量

```php
<?php
    $a = 'php中文网原创视频：《天龙八部》公益php培训系列课程汇总！';
    echo $a;
?>
```

##### 2、赋值运算符

| **运算符** | **描述**   |
| ---------- | ---------- |
| `=`        | 赋值运算符 |

##### 3、变量命名规则

- 声明变量开头需要使用$符

- 开头不能用数字
- 中间不能有空格

```php
<?php
    # 下划线命名法
    $new_title = 'php中文网原创视频：《天龙八部》公益php培训系列课程汇总！';
    echo $new_title;
    echo '<hr>';
    # 小驼峰命名法
    $newTitle  = 'php中文网《玉女心经》公益PHP WEB培训系列课程汇总';
    echo $newTitle;
    echo '<hr>';
    # 大驼峰命名法
    $NewTitle  = 'html5中submit是按钮么';
    echo $NewTitle;
?>
```

### 5、html和 php混编

- 需要把文件的后缀名，改为：`php`

- 相同的变量名，下面会把上面覆盖，也叫：重新赋值

### 6、php标量数据类型

| **类型**         | **描述**                       |
| ---------------- | ------------------------------ |
| 布尔型 `Boolean` | `true` 和 `false`              |
| 整型 `Integer`   | 0 - 无限大                     |
| 浮点型 `Float`   | 带小数的数字                   |
| 字符串 `String`  | 汉字、英文、符合、其它国家语言 |

> echo 输出数据值，开发时使用
> var_dump 可以打印数据类型和值，测试时使用

##### 1、布尔型

- 布尔型通常用于条件判断

```php
<?php
    $x = true;
    var_dump($x);
    echo '<hr>';
    $y = false;
    var_dump($y);
?>
```

##### 2、整型

- 整数不能包含逗号或空格
- 整数是没有小数点的
- 整数可以是正数或负数
- 整型可以用三种格式来指定：十进制、十六进制、八进制

```php
<?php
    $number = 0;
    var_dump($number);
    echo '<hr>';
    $number = 67;
    var_dump($number);
    echo '<hr>';
    $number = -322;
    var_dump($number);
?>
```

##### 3、浮点型

- 带小数部分的数字

```php
<?php
    $number = 10.03;
    var_dump($number);
    echo '<hr>';
    $number = -88.23;
    var_dump($number);
?>
```

##### 4、字符串

- 引号内的数据；
- 可以是单引号和双引号；
- 数字、浮点型、布尔型用引号也属于字符串类型

```php
<?php
    $str = '我是欧阳';
    var_dump($str);
    echo '<hr>';
    $str = 'My name is ou yang';
    var_dump($str);
?>
```

注意，字符串可以使用单引号和双引号来表示，但是单引号不会解析变量，而双引号则会解析变量。

### 7、php复合数据类型

| **类型** | **描述** |
| -------- | -------- |
| array    | 数组     |
| object   | 对象     |
| callable | 可调用   |
| iterable | 可迭代   |

------

## 8、php特殊数据类型

| **类型**    | **描述**       |
| ----------- | -------------- |
| 空值 `NULL` | 表示变量没有值 |
| resource    | 资源           |

##### 1、NULL

- NULL 值表示变量没有值

```php
<?php
    $null;
    var_dump($null);
    echo '<hr>';
    $null = '';
    var_dump($null);
    echo '<hr>';
    $null = null;
    var_dump($null);
?>
```

##### 2、资源指的是图片和视频

### 9、PHP的数组类型

| **类型**     | **描述**                       |
| ------------ | ------------------------------ |
| 数组 `Array` | 数组可以在一个变量中存储多个值 |

##### 1、创建空数组

```php
$arr = array();
var_dump( $arr );
$arrs = [];
var_dump( $arrs );
```

##### 2、创建索引数组

```php
$arr = array(
    '欧阳',
    '西门',
    '灭绝'
);
var_dump( $arr );
```

##### 3、创建关联数组

```php
$arr = [
    'ouyang' => '欧阳',
    'ximen' => '西门',
    'miejue' => '灭绝'
];
var_dump( $arr );
```

##### 4、输出数组值

```php
$arr = [
    '欧阳',
    '西门',
    '灭绝'
];
echo $arr[0];
echo '<hr>';
echo $arr[1];
echo '<hr>';
echo $arr[2];
echo '<hr>';


$arrs = [
    'ouyang' => '欧阳',
    'ximen' => '西门',
    'miejue' => '灭绝'
];
echo $arrs['ouyangke'];
echo '<hr>';
echo $arrs['huangrong'];
echo '<hr>';
echo $arrs['guojing'];
echo '<hr>';
```

##### 5、打印数组 `print_r`

```php
$arr = [
    '欧阳',
    '西门',
    '灭绝'
];
print_r($arr);
```

##### 6、`php` 连接符

```php
$var1 = 'PHP讲师';
$var2 = '欧阳';
var_dump( $var1 . $var2 );
var_dump( $var1 . '：' . $var2 );
```

### 10、php 多维数组

##### 1、二维数组

```php
$arr = array(
    array(
        'name' => '欧阳',
        'school'  => 'PHP中文网'
    ),
    array(
        'name' => '西门',
        'school'  => 'PHP中文网'
    ),
    array(
        'name' => '灭绝',
        'school'  => 'PHP中文网'
    )
)
var_dump($arr);
print_r($arr);
```

##### 2、三维数组

```php
$arr = [
    [
        'name' => '欧阳',
        'school'  => 'PHP中文网',
        'gongfu' => [
            'PHP',
            '小程序',
            'layui',
            'Thinkphp'
        ]
    ],
    [
        'name' => '西门',
        'school'  => 'PHP中文网',
        'gongfu' => [
            'PHP',
            'Thinkphp',
            'Laravel',
            '实战项目'
        ]
    ],
    [
        'name' => '灭绝',
        'school'  => 'PHP中文网',
        'gongfu' => [
            'HTML',
            'PHP',
            'layui',
            'Thinkphp'
        ]
    ]
];
var_dump($arr);
print_r($arr);
```

> 备：数组最好不要超过3层

##### 3、多维数组访问

```php
$arr = [
    [
        'name' => '欧阳',
        'school'  => 'PHP中文网',
        'gongfu' => [
            'PHP',
            '小程序',
            'layui',
            'Thinkphp'
        ]
    ],
    [
        'name' => '西门',
        'school'  => 'PHP中文网',
        'gongfu' => [
            'PHP',
            'Thinkphp',
            'Laravel',
            '实战项目'
        ]
    ],
    [
        'name' => '灭绝',
        'school'  => 'PHP中文网',
        'gongfu' => [
            'HTML',
            'PHP',
            'layui',
            'Thinkphp'
        ]
    ]
]
echo $arr[0]['name'].' --- ';
echo $arr[0]['gongfu'][0].' --- ';
echo $arr[0]['gongfu'][1];
```

> 备：数组访问时，层次不要弄错

### 11、`php` 数组循环

##### 1、`foreach`

```php
$arr = array(
    'ouyang' => '欧阳',
    'ximen' => '西门',
    'miejue' => '灭绝'
);
foreach( $arr as $v ){
    echo $v;
    echo '<hr>';
}
```

##### 2、key 和 value

> $k 和 $v，变量名，可以自定义

```php
示例1：
$arr = array[
    'ouyang' => '欧阳',
    'ximen' => '西门',
    'miejue' => '灭绝'
];
foreach( $arr as $k=>$v ){
    echo $k . ' --- ' . $v;
    echo '<hr>';
}
示例2：
$arr = [
    '欧阳',
    '西门',
    '灭绝'
];
foreach( $arr as $k=>$v ){
    echo $k . ' --- ' . $v;
    echo '<hr>';
}
```

##### 3、循环多维数组

```php
示例1：
$arr = [
    [
        'name' => '欧阳',
        'school'  => 'PHP中文网'
    ],
    [
        'name' => '西门',
        'school'  => 'PHP中文网'
    ],
    [
        'name' => '灭绝',
        'school'  => 'PHP中文网'
    ]
];
foreach( $arr as $k=>$v ){
    print_r($v);
    echo '<hr>';
}
示例2：
$arr = [
    [
        'name' => '欧阳',
        'school'  => 'PHP中文网'
    ],
    [
        'name' => '西门',
        'school'  => 'PHP中文网'
    ],
    [
        'name' => '灭绝',
        'school'  => 'PHP中文网'
    ]
];
foreach( $arr as $k=>$v ){
    foreach ($v as $key => $value) {
        echo $value;
        echo '<hr>';
    }
}
示例3：
$arr = [
    [
        'name' => '欧阳',
        'school'  => 'PHP中文网'
    ],
    [
        'name' => '西门',
        'school'  => 'PHP中文网'
    ],
    [
        'name' => '灭绝',
        'school'  => 'PHP中文网'
    ]
];
foreach( $arr as $k=>$v ){
    echo $v['name'].' --- '.$v['school'];
    echo '<hr>';
}
```

### 12、php 条件判断

##### 1、三元运算符 `? :`

```php
$ouyang = '欧阳';
var_dump( $ouyang ? '我是欧阳克' : '我也不知道我是谁' );
```

##### 2、`if`

```php
$ouyang = '欧阳';
if($ouyang){
    echo $ouyang;
}
```

##### 3、`if` `else`

```php
$ouyang = '欧阳';
if($ouyang){
    echo $ouyang;
}else{
    echo '灭绝师太';
}
```

##### 4、`if` `elseif` `else`

```php
$ouyang = '欧阳';
$miejue = '灭绝师太';

if($ouyang){
    echo $ouyang;
}else if($miejue){
    echo $miejue;
}else{
    echo '西门大官人';
}
```

##### 5、`switch` `case` `default`

```php
$str = 'ximen';
switch ($str) {
    case 'ouyang':
        echo '我是欧阳';
    case 'miejue':
        echo '我是灭绝师太';
    case 'ximen':
        echo '我是西门大官人';
    default:
        echo '我不知道我是谁';
}
```

##### 6、`break`

- 结束当前代码

```php
$str = 'ximen';
switch ($str) {
    case 'ouyang':
        echo '我是欧阳';
        break;
    case 'miejue':
        echo '我是灭绝师太';
        break;
    case 'ximen':
        echo '我是西门大官人';
        break;
    default:
        echo '我不知道我是谁';
        break;
}
```

##### 7、`PHP8` 新特性 `match`

```php
$str = 'ximen';
echo match ($str) {
    'ouyang' => '我是欧阳',
    'miejue' => '我是灭绝师太',
    'ximen' => '我是西门大官人'
};
```

> 匹配多条件、默认值

```php
$str = 'ouyang';
echo match ($str) {
    'miejue','miejueshitai' => "我是灭绝师太",
    'ximen','ximendaguanren' => "我是西门大官人",
    default => '我是欧阳',
};
```

> 备：没有默认值，会报错的

##### 8、`switch` 和 `match` 对比

- match是一个表达式，表示其结果可以存储在变量中或者返回；
- match分支仅支持单行表达式，不需要中断break;
- match匹配进行的是严格比较。

### 13、函数

##### 1、函数判断

```php
# 直接判断不存在的变量，会报错
if($miejue){
    echo '灭绝师太';
}

# 使用isset函数判断
if(isset($miejue)){
    echo '灭绝师太';
}

# 使用empty函数判断
if(empty($miejue)){
    echo '灭绝师太';
}
```

##### 2、什么是函数

- 函数是一段可以重复执行的代码片断
- 函数是实现代码复用的重要手段
- 函数是现代编程语言最重要的基本单元
- 函数永远是编程的核心工作

##### 3、函数的分类

- 根据函数的提供者(编写者),分为二类
  - 系统函数: 编程语言开发者事先写好提供给开发者直接使用的
  - 自定义函数: 用户根据自身需求，对系统功能进行扩展

##### 4、系统函数

- PHP 的真正力量来自它的函数：它拥有超过 1000 个内建的函数。

| **函数集合名** | **描述**                                                     |
| -------------- | ------------------------------------------------------------ |
| `String`       | 字符串处理函数                                               |
| `Array`        | 数组函数允许您访问和操作数组                                 |
| `MySQLi`       | 允许您访问 MySQL 数据库服务器                                |
| `Date`         | 服务器上获取日期和时间                                       |
| `Filesystem`   | 允许您访问和操作文件系统                                     |
| `Mail`         | 数学函数能处理 integer 和 float 范围内的值                   |
| `HTTP`         | 允许您在其他输出被发送之前，对由 Web 服务器发送到浏览器的信息进行操作 |
| `Calendar`     | 日历扩展包含了简化不同日历格式间转换的函数                   |
| `Directory`    | 允许您获得关于目录及其内容的信息                             |
| `Error`        | 允许您对错误进行处理和记录                                   |
| `Filter`       | 进行验证和过滤                                               |
| `FTP`          | 通过文件传输协议 (FTP) 提供对文件服务器的客户端访问          |
| `MySQL`        | 允许您访问 MySQL 数据库服务器                                |
| `SimpleXML`    | 允许您把 XML 转换为对象                                      |
| `XML`          | 允许我们解析 XML 文档，但无法对其进行验证                    |
| `Zip`          | 压缩文件函数允许我们读取压缩文件                             |

##### 5、`String` 字符串函数

| **函数**        | **描述**                                   |
| --------------- | ------------------------------------------ |
| `strtolower()`  | 将字符串转化为小写                         |
| `strtoupper()`  | 将字符串转化为大写                         |
| `strlen()`      | 获取字符串长度                             |
| `trim()`        | 去除字符串首尾处的空白字符（或者其他字符） |
| `ltrim()`       | 去除字符串开头的空白字符（或者其他字符）   |
| `rtrim()`       | 去除字符串结尾的空白字符（或者其他字符）   |
| `str_replace()` | 字符串替换                                 |
| `strpbrk()`     | 字符串中查找一组字符是否存在               |
| `explode()`     | 将字符串分割为数组                         |
| `md5()`         | 将字符串进行md5加密                        |

```php
// 将字符串转化为小写
$ouyang = 'OUYANGKE';
echo strtolower($ouyang);
echo '<hr>';

// 将字符串转化为大写
$miejue = 'miejueshitai';
echo strtoupper($miejue);
echo '<hr>';

// 将字符串分割为数组
$php = '欧阳克，灭绝师太，西门大官人，天蓬';
print_r ( explode('，',$php) );
echo '<hr>';

// 将字符串进行md5加密
$ximen = '西门大官人';
echo md5($ximen);
```

##### 6、`Array` 数组函数

| **函数**         | **描述**                       |
| ---------------- | ------------------------------ |
| `count()`        | 数组中元素的数量               |
| `implode()`      | 把数组元素组合为字符串         |
| `array_merge()`  | 两个数组合并为一个数组         |
| `in_array()`     | 数组中是否存在指定的值         |
| `sort()`         | 对数值数组进行升序排序         |
| `rsort()`        | 对数值数组进行降序排序         |
| `array_unique()` | 移除数组中的重复的值           |
| `array_push()`   | 将一个或多个元素插入数组的末尾 |
| `array_pop()`    | 删除数组中的最后一个元素       |

```php
$arr = [
	'欧阳克',
	'灭绝师太',
	'西门大官人',
	'天蓬'
];
// 数组中元素的数量
echo count($arr);
echo '<hr>';

// 把数组元素组合为字符串
echo implode('，',$arr);
echo '<hr>';

// 数组中是否存在指定的值
echo in_array('天蓬',$arr);
echo '<hr>';

// 删除数组中的最后一个元素
array_pop($arr);
print_r($arr);
```

> 官网手册：https://www.php.net/manual/zh/book.array.php

------

### 14、自定义函数

##### 1、函数的基本语法

```php
// 创建函数
function fun_name(参数列表)
{
    //函数体: 由一条或多条语句组成,可以为空
}
```

- 必须使用关键字:`function` 声明
- 函数名称**不区分大小写**,多个单词推荐使用下划线连接

##### 2、调用函数

```php
// 创建函数
function fun_name()
{
    return '我是：欧阳克';
}

// 调用函数
echo fun_name();
```

##### 3、函数参数

```php
// 创建函数
function fun_name($name)
{
    return '我是：' . $name;
}

// 调用函数
echo fun_name('欧阳克');
```

- 方法参数可以有默认值，有默认值可以不传值
- 方法必须以返回的方式，不要用 `echo` 输出的方式

```php
// 创建函数
function fun_name($name,$school='PHP中文网')
{
    return '我是：' . $name . '，我来至：' . $school;
}

// 调用函数
echo fun_name('欧阳克','过去的世界');
```

##### 4、作用域

- php中, 只有函数作用域和全局作用域
- 所有函数作用域中的变量，外部不可见
- 全局作用域声明变量，在函数中是可见的

```php
$name = '灭绝师太';
$school = 'PHP中文网';
// 创建函数
function fun_name()
{
    global $name;
    global $school;
    return '我是：' . $name . '，我来至：' . $school;
}

// 调用函数
echo fun_name();
```

##### 5、`PHP8` 新特性：命名参数

- 仅指定必须得参数，跳过可选的参数；
- 参数是与顺序无关的且具有自己录功能；

> PHP7

```php
function jisuan($a,$b=0,$c=0,$d=0){
	echo $a;
	echo '<hr/>';
	echo $b;
	echo '<hr/>';
	echo $c;
	echo '<hr/>';
	echo $d;
	echo '<hr/>';
}

jisuan(10,20,30,40);
```

> PHP8

```php
function jisuan($a,$b=0,$c=0,$d=0){
	echo $a;
	echo '<hr/>';
	echo $b;
	echo '<hr/>';
	echo $c;
	echo '<hr/>';
	echo $d;
	echo '<hr/>';
}

jisuan(10,20,d:30,c:40);
```

# 15、运算符

##### 1、php 运算符

| **运算符** | **描述**         |
| ---------- | ---------------- |
| `+`        | 相加             |
| `-`        | 相减             |
| `*`        | 相乘             |
| `/`        | 相除             |
| `%`        | 取余             |
| `++`       | 加加             |
| `--`       | 减减             |
| `.`        | 连接、用在字符串 |

> 示例：

```php
<?php
    var_dump( 120 + 80 );
    echo '<hr>';
    var_dump( 120 - 80 );
    echo '<hr>';
    var_dump( 120 * 80 );
    echo '<hr>';
    var_dump( 120 / 80 );
    echo '<hr>';
    var_dump( 120 % 80 );
    echo '<hr>';
    var_dump( 120++ );
    echo '<hr>';
    var_dump( 120-- );
    echo '<hr>';
    var_dump( ++120 );
    echo '<hr>';
    var_dump( --120 );
    echo '<hr>';
    var_dump( 120 . 80 );
    echo '<hr>';

    $var1 = 'PHP讲师：';
    $var2 = '欧阳';
    var_dump( $var1 . $var2 );
    //两个变量连接，没问题
    //一个变量和字符串，没问题
    //一个变量连接整型，必须在整型前面增加空格
?>
```

------

##### 2、php 赋值运算符

| **运算符** | **描述**       |
| ---------- | -------------- |
| `=`        | 赋值运算符     |
| `+=`       | 先加，后赋值   |
| `-=`       | 先减，后赋值   |
| `*=`       | 先乘，后赋值   |
| `/=`       | 先除，后赋值   |
| `%=`       | 先取余，后赋值 |
| `.=`       | 先连接，后赋值 |

> 示例：

```php
    $int = 120;
    var_dump($int);
    echo '<hr>';
    $int += 30;
    var_dump( $int );
    echo '<hr>';
    $int = $int + 30;
    var_dump( $int );
    echo '<hr>';
    $int -= 30;
    var_dump( $int );
    echo '<hr>';
    $int *= 30;
    var_dump( $int );
    echo '<hr>';
    $int /= 30;
    var_dump( $int );
    echo '<hr>';
    $int %= 30;
    var_dump( $int );
    echo '<hr>';
    $int .= 30;
    var_dump( $int );
```

------

##### 3、`php` 比较运算符

| **运算符** | **描述** |
| ---------- | -------- |
| `>`        | 大于     |
| `>=`       | 大于等于 |
| `<`        | 小于     |
| `<=`       | 小于等于 |
| `==`       | 等于     |
| `!=`       | 不等于   |
| `===`      | 恒等于   |
| `!==`      | 恒不等   |

- ##### `>` 大于

```php
    var_dump( 100 > 100 );
    echo '<hr>';
    var_dump( 100 > 90 );
    echo '<hr>';
    var_dump( 100 > 110 );
    echo '<hr>';
    var_dump( true > false );
    echo '<hr>';
    var_dump( 'php' > 'php' );
    echo '<hr>';
```

- ##### `>=` 大于等于

```php
    var_dump( 100 >= 100 );
    echo '<hr>';
    var_dump( 100 >= 90 );
    echo '<hr>';
    var_dump( 100 >= 110 );
    echo '<hr>';
    var_dump( true >= false );
    echo '<hr>';
    var_dump( 'php' >= 'php' );
    echo '<hr>';
```

- ##### `<` 小于

```php
    var_dump( 100 < 100 );
    echo '<hr>';
    var_dump( 100 < 90 );
    echo '<hr>';
    var_dump( 100 < 110 );
    echo '<hr>';
    var_dump( true < false );
    echo '<hr>';
    var_dump( 'php' < 'php' );
    echo '<hr>';
```

- ##### `<=` 小于等于

```php
    var_dump( 100 <= 100);
    echo '<hr>';
    var_dump( 100 <= 90);
    echo '<hr>';
    var_dump( 100 <= 110);
    echo '<hr>';
    var_dump( true <= false);
    echo '<hr>';
    var_dump( 'php' <= 'php' );
    echo '<hr>';
```

- ##### `==` 等于

```php
    var_dump( 100 == 100 );
    echo '<hr>';
    var_dump( true == 'true' );
    echo '<hr>';
```

- ##### `!=` 不等于

```php
    var_dump( 100 != 100 );
    echo '<hr>';
    var_dump( true != 'true' );
    echo '<hr>';
```

- ##### `===` 恒等于

```php
    var_dump( 100 === 100 );
    echo '<hr>';
    var_dump( true === 'true' );
    echo '<hr>';
```

- ##### `!==` 恒不等

```php
    var_dump( 100 !== 100 );
    echo '<hr>';
    var_dump( true !== 'true' );
    echo '<hr>';
```

- ##### `PHP8` 新特性：字符串与数字的比较

```php
var_dump( '欧阳' > 100 );
echo '<hr>';
var_dump( '欧阳' < 100 );
echo '<hr>';
var_dump('欧阳' == 0);
```

注意：在数字和字符串进行比较时，PHP8使用数字比较，否则将数字装换成字符串使用字符串比较

### 16、`php` 逻辑运算符

| **运算符**    | **描述** |
| ------------- | -------- |
| `and` 和 `&&` | 与       |
| `or` 和 `||`  | 或       |
| `xor`         | 异或     |
| `!`           | 非       |

##### 1、`and` 和 `&&`

```php
    //两个真，返回真。有一个是假，返回假。
    var_dump( 100 && 30 );
    echo '<hr/>';
    var_dump( true && true );
    echo '<hr/>';
    var_dump( true and false );
    echo '<hr/>';
    var_dump( false and false );
    echo '<hr/>';
```

##### 2、`or` 和 `||`

```php
    //一个真，返回真。两个真，返回真。两个假，返回假。
    var_dump( 120 || 80 );
    echo '<hr/>';
    var_dump( true || true );
    echo '<hr/>';
    var_dump( true or false );
    echo '<hr/>';
    var_dump( false or false );
    echo '<hr/>';
```

##### 3、`xor`

```php
    //一个真、返回真。两个真，返回假。两个假，也返回假。
    var_dump( 0 xor 1 );
    echo '<hr/>';
    var_dump( true xor true );
    echo '<hr/>';
    var_dump( true xor false );
    echo '<hr/>';
    var_dump( false xor false );
    echo '<hr/>';
```

##### 4、`!`

```php
    // 取反，如果是真，就是假。如果是假，就是真。
    var_dump( !0);
    echo '<hr/>';
    var_dump( !true );
    echo '<hr/>';
    var_dump( !false );
    echo '<hr/>';
    var_dump( !1 );
    echo '<hr/>';
```

### 17、循环

- ##### `while`

```php
$int = 1;
while ( $int < 10 ) {
    echo $int;
    echo '<hr/>';
    $int ++;
}
```

- ##### `do` `while`

```php
$int = 1;
do {
    echo $int;
    echo '<hr>';
    $int++;
}while ( $int < 1);
```

- ##### `for`

```php
示例1：
    for( $int=1; $int<10; $int++){
        echo $int;
        echo '<hr>';
    }
示例2：
    for( $int=1; $int<10; $int++){
        if($int == 5){
            echo '等于5，单独输出';
        }else{
            echo $int;
        }
        echo '<hr>';
    }
```

- ##### `continue`

  - 结束当前循环，进入下次循环

  - 在循环语句`while` `for`中使用 

```php
for( $int=1; $int<10; $int++){
    if($int == 5){
        //结束当前循环，进入下次循环
        continue;
    }
    var_dump($int);
    echo '<hr>';
}
```

- ##### `break`

  - 结束循环

  - 在循环语句 `while` `for` `switch`中使用

  - 可以跳出多层循环

```php
示例1：
for( $int=1; $int<10; $int++){
    if($int == 5){
        //结束当前循环，进入下次循环
        break;
    }
    var_dump($int);
    echo '<hr>';
}
示例2：
$money = 50000;
switch ($money) {
    case $money >= 50000:
        echo '我要买个华为Mate X2 手机';
        break;
    case $money >= 20000:
        echo '我要买个iphone手机';
        break;
    case $money >= 10000:
        echo '我要买个小米手机';
        break;
    case $money >= 5000:
        echo '我只能买个二手手机';
        break;
    default:
        echo '我啥也买不起，洗洗睡吧';
        break;
}
```

### 18、PHP8新特性：`JIT`

##### 1、`PHP` 运行速度测试

```php
<?php
	// 返回当前时间戳的微秒数
	$start = microtime(true) ;

	$total = 0;
	for ($i=0; $i < 1000000; $i++) { 
		$total += $i;
	}

	echo "Count: ".$i.",Total: " . $total . "\n";

	// 返回当前时间戳的微秒数
	$end = microtime(true);

	// 计算开始到结束，所用时间
	$spend = floor(($end - $start) * 1000);

	echo "Time use: " . $spend . " ms\n";
?>
```

------

##### 2、`JIT` （即时编译）编译器

- `JIT` (Just-In-Time)即时编译器是 `PHP 8.0` 中最重要的新功能之一，可以极大地提高性能。
- `JIT` 编译器将作为扩展集成到 `php` 中 `Opcache` 扩展 用于运行时将某些操作码直接转换为从 `cpu` 指令。 仅在启用 `opcache` 的情况下，`JIT` 才有效

##### 3、`Opcache` 扩展

- `OPcache` 通过将 `PHP` 脚本预编译的字节码存储到共享内存中来提升 `PHP` 的性能， 存储预编译字节码的好处就是：省去了每次加载和解析 `PHP` 脚本的开销。

##### 4、`Opcache` 开启

- 文件位置：softs\php\php-8.0.2-nts\php.ini

```php
zend_extension=opcache
```

##### 5、`Opcache` 配置

```php
; Determines if Zend OPCache is enabled
opcache.enable=1

; Determines if Zend OPCache is enabled for the CLI version of PHP
opcache.enable_cli=0

; The OPcache shared memory storage size.
opcache.memory_consumption=128

; The amount of memory for interned strings in Mbytes.
opcache.interned_strings_buffer=8

; The maximum number of keys (scripts) in the OPcache hash table.
; Only numbers between 200 and 1000000 are allowed.
opcache.max_accelerated_files=10000
```

##### 6、`JIT` 配置（新增）

```php
opcache.jit=tracing
opcache.jit_buffer_size=100M
```

##### 7、php 扩展目录

```php
extension_dir = "ext"
```