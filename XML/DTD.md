### DTD(Document Type Definition)
DTD的中文翻译是文档类型定义--(Document Type Definition),DTD用来描述XML文档的结构，一个DTD文档包含：
* 元素(ELEMENT)的定义规则；
* 元素之间的关系规则；
* 属性(ATTLIST)的定义规则；
* 可使用的实体(ENTITY)或符号(NOTATION)规则。
DTD文档与XML文档的关系好像类和对象、数据库表结构和数据记录之间的关系。有了DTD，每个XML文件可以携带一个自身格式的描述。不同组织的人可以使用一个通用DTD来描述交换信息载体XML文档的结构。应用程序可以使用一个标准DTD校验从外部世界接受来的XML数据是否有效，DTD已经成为了检验XML结构是否有效的常用方式。

##### DTD的声明和引用方式
DTD的声明的形式：\<!DOCTYPE 根元素 \[内容定义]>    

XML文档通过使用DOCTYPE声明语句(文档类型定义语句)来指明它所遵循的DTD文件，DOCTYPE声明语句紧跟在XML文档声明语句后面，有两种格式：
1. \<!DOCTYPE 文档类型名称 SYSTEM “DTD文件的URL”>
2. \<!DOCTYPE 文档类型名称 PUBLIC “DTD名称” “DTD文件的URL”>  
对于DTD名称应符合一些标准的规定，对于ISO标准的DTD以ISO三个字母开头：被改进的非ISO标准的DTD以加号“+”开头；未被改进的非ISO标准的DTD以减号“-”开头。  

##### DTD的定义
**元素定义**：
\<!ElEMENT 元素名称 元素类型>  
举例：  
\<!ELEMENT 书架 (书名，作者，售价)  
\<!ELEMENT 书名 (#PCDATA)>   
元素类型：  
* (#PCDATA) : parsed character data，可以包含任何字符数据和属性，但是不能包含任何子元素。    
* (子元素1，子元素2，子元素3) ：纯元素类型，只包含子元素，并且这些子元素外没有文本。 
* (子元素，#PCDATA)  ：混合元素类型，包含子元素和文本数据的混合体。
* EMPTY，该元素不能包含子元素和文本，但可以有属性(空元素)：如<!ELEMENT HR EMPTY>定义的元素形式为\<HR />
* ANY：表示以上任何一种形式。
 
**元素定义细节**：
* DTD使用与XML文档同样的注释方式：<!-- 注释内容 -->
* 每条元素定义语句的顺序是无关紧要的
* 具有不同用途的元素不能使用相同的元素名
* 一个元素的各个组成成分之间可以有各种关系：
    \<!ELEMENT MYFILE (TITLE AUTHOR EMAIL)>
    \<!ELEMENT MYFILE (TITLE,AUTHOR,EMAIL)>
    \<!ELEMENT MYFILE (TITLE|AUTHOR|EMAIL)>
* 在元素的使用规则中可以定义子元素出现的次数：
>   (book+)：一个或者多个  
>   (book?)：一个或者零个  
>   (book\*)：零个、一个或者多个  
* 一对圆括号()可用于将括在其中的内容组合成一个可统一操作的分组，分组中可以嵌套更小的分组。

**属性定义**：
```
<!ATTLIST 元素名
    属性名1 属性类型 属性特点
    属性名2 属性类型 属性特点 
    ......
>
```
**属性类型**：
* CDATA：普通文本字符串，特殊字符需要使用转义字符；
* NMTOKEN：是CDATA的一个子集，表示属性值必须是英文字母、数字、句号、破折号、下划线或冒号，属性值不能含有空格；
* NMTOKENS：与NMTOKEN类似，可以包含空格；
* ID：表明该属性的取值必须是唯一的；
* IDREF：属性的值指向文档其他地方声明的ID类型的值；
* IDREFS：与IDERF类似，属性值参照文档其他地方已经声明的多个ID类型的值，ID属性值之间用空格隔开；
* ENUMERATED：枚举类型，预先定义属性可选的多个值包括在括号中“()”,每个值之间用“|”来分隔；
* REQUIRED：元素的所有实例必须有该属性；
* IMPLIED：元素的实例中可以忽略该属性；  
**属性特点**：
* #REQUIRED：必须要设置的属性；
* #IMPLIED：可有可无的设置属性；
* #FIXED *value*：固定值得属性；
* 直接使用属性值为该属性的默认值；  
**实体定义**  
* 内部实体的定义：`<!ENTITY 实体名 "实体值">`，引用实体的形式：“&实体名；”
* 外部实体的定义：`<!ENTITY 实体名 SYSTEM "URI/URL">`,使用外部文档内容替换实体的引用；
* 内部参数实体的定义：`<!ENTITY % 实体名 "实体值">`，引用实体的形式：“%实体名；”
* 外部参数实体的定义：`<!ENTITY % 实体名 SYSTEM "URI/URL">`,使用外部文档内容替换实体的引用；  
**实体类型**
<table  border="3" bordercolor="#a0c6e5" style="border-collapse:collapse;">
    <tr>
        <th colspan="2">类型</th>
        <th>普通实体</th>
        <th>参数实体</th>
    </tr>
    <tr>
        <td colspan="2">使用场合</td>
        <td>用在XML文档中</td>
        <td>只用在DTD中元素和属性的声明中</td>
    </tr>
    <tr>
        <td rowspan="2">声明方式</td>
        <td>内部</td>
        <td>&lt;!ELEMENT 实体名 &quot;文本内容&quot;&gt;</td>
        <td>&lt;!ELEMENT % 实体名 &quot;文本内容&quot;&gt;</td>
    </tr>
    <tr>
        <td>外部</td>
        <td>&lt;!ELEMENT 实体名 SYSTEM &quot;外部文件URL地址&quot;&gt;</td>
        <td>&lt;!ELEMENT % 实体名 SYSTEM &quot;外部文件URL地址&quot;&gt;</td>
    </tr>
    <tr>
        <td colspan="2">引用方式</td>
        <td>&实体名;</td>
        <td>%实体名;</td>
    </tr>
</table>

##### 总结
一个有效的XML文档必然是结构正确的，结构正确的XML文档不一定是有效的。DTD包含一套用来描述并限制XML文档结构的语法规则。
* 元素的定义规则；
* 元素之间的关系规则；
* 属性定义规则；
* 可以使用的实体或符号规则；
一个使用DTD验证了的XML必定是一个结构正确的XML文档，同时也是一个有效的XML文档。
