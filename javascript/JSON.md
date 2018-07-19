### JSON简介

###### JSON的两种结构：
* “名称/值”对的集合（A collection of name/value pairs）。不同的语言中，它被理解为对
象（object），纪录（record），结构（struct），字典（dictionary），哈希表（hash table）
，有键列表（keyed list），或者关联数组 （associative array）。
* 值的有序列表（An ordered list of values）。在大部分语言中，它被理解为数组（array）。
>这些都是常见的数据结构。事实上大部分现代计算机语言都以某种形式支持它们。这使得一种数据
格式在同样基于这些结构的编程语言之间交换成为可能。

###### JSON的具体表现形式
* 对象是一个无序的“名称/值”对集合。一个对象以“{”（左括号）开始，“}”（右括号）结束
。每个“名称”后跟一个“:”（冒号）再跟上与其对应的值；“名称/值”对之间使用“,”（逗号）
分隔。
* 数组是值（value）的有序集合。一个数组以“[”（左中括号）开始，“]”（右中括号）结束。
值之间使用“,”（逗号）分隔。
>值（value）可以是双引号括起来的字符串（string）、数值(number)、true、false、 null、对
象（object）或者数组（array）。这些结构可以嵌套。

###### JavaScript中序列化和反序列化JSON
现在JSON格式在web开发中非常重要，特别是在使用ajax开发项目的过程中，经常需要将后端响应
的JSON格式的字符串返回到前端，前端解析成JS对象值（JSON 对象），再对页面进行渲染。在数
据传输过程中，JSON是以文本，即字符串的形式传递的，而JS操作的是JSON对象，所以，JSON对象
和JSON字符串之间的相互转换是关键。

一、JSON对象（Object）和JSON字符串（String）
JSON字符串（首尾字符串带引号）:
```
var str1 = '[{"name":"chunlynn","sex":"man" },{ "name":"linda","sex":"wowen"}]';
var jsonstr ='{"name":"chunlynn","sex":"man"}';
```
JSON对象（JS对象值）（首尾不带引号）:
```
var obj = [{"name":"chunlynn","sex":"man" },{"name":"linda","sex":"wowen"}];
```
二、解析JSON数据的四种方法
「解析」：将JSON格式的字符串转化成JSON对象（JS对象值）的过程。也称为「反序列化」。
「序列化」：就是说把原来是对象的类型转换成字符串类型（或者更确切的说是JSON字符串类型的）。

###### JSON.parse()和JSON.stringify()

| 方法名 | 描述 |
|:--------:|:---------|
| parse(s, reviver) | 将字符串解析为JSON，S:要解析的字符串；reviver(可选)：用于装换解析值的可选函数；|
| stringify(o, filter, intent) | 将指定的参数o转换为字符串，会调用o的toJSON方法，o:要转换为字符串的JSON对象，数组或原始值；filter：可选的函数在转换前做一些替换，或一个数组，包含要转换的属性名；intent：可选参数，指定参数，指定缩进及缩进的空格数，最大是10|


```
    var s = '{"id" : 1, "name" : "lwei"}'
    var r = JSON.parse(s);
    console.log(r);

    console.log(r.id + ", " + r.name);
    r = JSON.parse(s, function(k,v){
        console.log(k);
        if(k == "")
            return v;
        return v += "test";
    });
    console.log(r.id + ", " + r.name);
```

结果如图(图1-1)：

![图1-1][JSONParse]

```
var o = {id : 1, name : "lwei"};
        var s = JSON.stringify(o);
        console.log(s);
        s = JSON.stringify(o, ["id"]);
        console.log(s);
        s = JSON.stringify(o, function(k,v){
            if(k == "")
                return v;
            else
                return v + "test";
        })
        console.log(s);
```

结果如图(图1-2)：

![图1-2][JSONStringify]

[JSONParse]: ../image/JsonParse.png "图1-1"
[JSONStringify]: ../image/JsonStringify.png "图1-1"