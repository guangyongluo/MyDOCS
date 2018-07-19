### innerHTML、innerText、outerHTML、outerText的区别
很有必要总结一下这几个属性的具体含义，网上有很多文章讲这几个属性的区别，
但是都不全面，本文将用实例讲解这几个属性的区别之处。

###### 概念
1. innerHTML：读取或写入位于Element标签内的HTML文档；
2. outerHTML：读取或写入Element的标签及标签内所有的HTML文档；
3. innerText：读取或写入位于Element标签内的文本；
4. outerText：读取Element标签内的文本，写入包含标签的所有文本；
5. textContent：将指定Element元素的所有后代Text节点简单地串联在一起。
innerText没有一个明确指定的行为，但是和textContent有一些不同。innerText
不返回<script>元素的内容。它忽略多余的空白，并试图保留表格格式。

>这几个概念要从读写的角度来区别理解，读取属性值时,innerHTML和outerHTML的
区别就是是否包含Element本省的标签；

###### 取值实例：
```
<!DOCTYPE html>
<html>
<head>
    <meta charset= 'utf-8'>
    <title>HTML5自由者</title>
</head>
<body>
<div id="test1">这是div中的文字<span>这是span中的文字</span></div>

<script type="text/javascript">
    console.log('innerHTML:'+test1.innerHTML);
    console.log('outerHTML:'+test1.outerHTML);
    console.log('innerText:'+test1.innerText);
    console.log('outerText:'+test1.outerText);
</script>
</body>
</html>

```

结果如图1-1所示：

![图1-1][readInnerOuterAttribute]

可以得出的结论：
1. innerHTML 获取对象起始和结束标签内的 HTML，即这里的对象是div标签，
亦即这个标签里面所有的内容包含span标签也获取出来，正如同这个属性的名字
一样输出的是HTML。
2. outerHTML 是在innerHTML基础上获取它的outer对象标签内容，也就是“
`<div id="test1">`这是div中的文字`<span>`这是span中的文字`</span>/div>`”
这些里面有什么内容及标签结构都获取出来。与innerHTML属性的主要区别就是
输出了Element元素本身的标签。
3. innerText和outerText在获取时是相同效果 都是获取`<div> </div>`标签里的
文本内容，去除掉了`<div> ,<span>`标签，只显示div,span标签里的文本内容，如
同这两个属性的名字一样输出的文本内容而不是HTML文档。

我先来看一张结构图，方便记忆下：

![图1-2][readInnerOuter]

###### 写入实例：
```
<!DOCTYPE html>
<html>
<head>
    <meta charset= 'utf-8'>
    <title>HTML5自由者——innerHTML、outerHTML和innerText、outerHTML的区别</title>
    <script language="JavaScript" type="text/javascript">
        //.innerHTML
        function innerHTMLDemo()
        {
            test_id1.innerHTML="<font size=9pt color=red><i><u>设置或获取对象及其内容的 HTML 形式.</u></i></font>";
        }
        //.innerText
        function innerTextDemo()
        {
            test_id2.innerText="<font size=9pt color=red><i><u>设置或获取对象及其内容的 HTML 形式.</u></i></font>";
        }
        //.outerHTML
        function outerHTMLDemo()
        {
            test_id3.outerHTML="<font size=9pt color=red><i><u>设置或获取对象及其内容的 HTML 形式.</u></i></font>";
        }
        //.outerText
        function outerTextDemo()
        {
            test_id4.outerText="<font size=9pt color=red><i><u>设置或获取对象及其内容的 HTML 形式.</u></i></font>";
        }
    </script>
</head>
<body>
　<ul>
    　  <li id="test_id1" onclick="innerHTMLDemo()">innerHTML效果.</li>
    　  <li id="test_id2" onclick="innerTextDemo()">innerText效果.</li>
    　　<li id="test_id3" onclick="outerHTMLDemo()">outerHTML效果.</li>
    　　<li id="test_id4" onclick="outerTextDemo()">outerText效果.</li>
    　</ul>
</body>
</html>

```

结果如图1-3所示：

![图1-3][innerOuterResult]

可以得出结论：
1. 可以看出，在设置标签的时候，innerHTML直接把标签结构设置到HTML文档中，
显示出样式出来。
2. outerHTML点击后显示结果：（跟innerHTMl效果一样。）是直接把字体大小、
颜色、斜体、下划线这些样式显现出来。与innerHTML最大的区别是把Element本身
的标签也替换了。
3. innerText 跟outerText 显示结果是直接把属性里的内容包括标签原封不动的设
置显示出来


[readInnerOuterAttribute]: ../image/readInnerOuterAttribute.png "图1-1"
[readInnerOuter]: ../image/readInnerOuter.png "图1-2"
[innerOuterResult]: ../image/innerOuterResult.png "图1-3"
