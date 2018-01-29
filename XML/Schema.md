### XML Schema
基本概念：XML Schema是基于XML的 DTD替代者。XML Schema主要用来描述 XML文档的结构。XML Schema语言也称作 XML Schema定义(XML Schema Definition，XSD)。XML Schema使用一套预先规定的XML元素和属性创建的，这些元素和属性定义了XML文档的结构和内容模式。XML Schema规定XML文档实例的结构和每个元素、属性的数据类型，为什么说XML Schema是DTD的继任者有以下几点理由：
* XML Schema 可针对未来的需求进行扩展
* XML Schema 更完善，功能更强大
* XML Schema 基于 XML 编写
* XML Schema 支持数据类型
* XML Schema 支持命名空间
 

##### 什么是XML Schema
* 定义可出现在文档中的元素
* 定义可出现在文档中的属性
* 定义哪个元素是子元素
* 定义子元素的次序
* 定义子元素的数目
* 定义元素是否为空，或者是否可包含文本
* 定义元素和属性的数据类型
* 定义元素和属性的默认值以及固定值

##### 定义XML Schema
在一个XML Schema定义文档中，<schema>元素是每个XML Schema的根元素，而且<schema>元素可包含属性，一个schema声明往往看上去如以下定义范例：
```
<?xml version="1.0"?>
 
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
targetNamespace="http://www.w3school.com.cn"
xmlns="http://www.w3school.com.cn"
elementFormDefault="qualified">
 
 ...
 ...
</xs:schema>
```
首先定义了一个名称空间“ http://www.w3.org/2001/XMLSchema ”，并且使用该名称空间的前缀xs:来限定schema本身，表示schema中用到的用于构造Schema的元素和数据类型来自名称空间“ http://www.w3.org/2001/XMLSchema ”。使用targetNamespace属性来表示当前schema定义的元素和数据类型来自名称空间“ http://www.w3school.com.cn ”。使用xmlns来定义默认的名称空间为“ http://www.w3school.com.cn ”。最后使用elementFormDefault表示在任何XML实例文档所使用的且在此schema中声明过的元素必须被名称空间限制。

##### 引用XML Schema
如下是一个XML文档引用XML Schema的例子：
```
<?xml version="1.0"?>

<note xmlns="http://www.w3school.com.cn"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.w3school.com.cn note.xsd">

    <to>George</to>
    <from>John</from>
    <heading>Reminder</heading>
    <body>Don't forget the meeting!</body>
</note>
```
xmlns定义了默认的名称空间为“ http://www.w3school.com.cn ”，并定义了一个前缀为xsi的名称空间“ http://www.w3.org/2001/XMLSchema-instance ”，使用xsi名称空间下的schemaLocation元素来指定使用xsd文件验证某个名称空间本例是使用相同路径下的note.xsd文件来验证“ http://www.w3school.com.cn ”名称空间。

##### Schema的数据类型
* 简单类型：内置的数据类型(built-in data types) 1.基本的数据类型，2.扩展的数据类型；用户自定义数据类型(通过simpleType定义)
* 复杂类型：(通过complexType定义)

Schema的数据类型——基本数据类型  

|数据类型|描述|
|:--------:|:----------------:|
|string|字符串类型|
|boolean|布尔类型|
|decimal|特定精度的数字|
|float|单精度32位浮点数|
|double|双精度64位浮点数|
|duration|持续时间类型|
|dateTime|特定时间数据类型|
|time|特定时间，但是每天重复的|
|date|日期类型|
|hexBinary|十六进制数据类型|
|anyURI|定位文件的URI类型|

Schema的数据类型——扩展的数据类型

|数据类型|描述|
|:--------:|:----------------:|  
|NOTATION|NOTATION类型|
|ID|用于唯一标识元素|
|IDREF|参考ID类型的元素或属性|
|ENTITY|实体类型|
|NMTOKEN|NMTOKEN类型|
|NMTOKENS|NMTOKENS类型|
|long|表示整型数，大小介于-9223372036854775808和9223372036854775807之间|
|int|表示整型数，大小介于-2147483648和2147483647之间|
|short|表示整型数，大小介于-32768和32767之间|
|byte|表示整型数，大小介于-128和127之间|

Schema的数据类型——数据类型的特征

|特征|描述|
|:--------:|:----------------:|    
|enumeration|在指定的数据集中选择，限定用户的选值|
|fractionDigits|限定最大的小数位，用于控制精度|
|length|指定数据的长度|
|maxExclusive|指定数据的最大值(小于)|
|maxInclusive|指定数据的最大值(小于等于)|
|maxLength|指定长度的最大值|
|minExclusive|指定最小值(大于)|
|minInclusive|指定最小值(大于等于)|
|minLength|指定最小长度|
|Pattern|指定数据的显示规范|

Schema的元素类型
* schema：schema文档的根元素，包含已经定义的所有schema元素，用法`<xs:schema>`,；
* 

