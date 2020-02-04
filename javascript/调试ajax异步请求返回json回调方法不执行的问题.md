### $.post() callback function不执行问题分析

这两天一直在研究spring security框架，测试from login认证，在spring security框架中支持两种认证方式：1.httpbasic；2.form login。form login方式比
较符合开发逻辑，在项目中也比较常用。同时form login也支持使用js ajax异步提交认证，所以功能非常强大。今天讨论的主要问题并不是spring security认证问题
而是前端有很多小的细节需要注意，废话不多说先看源码：
```
<form id="loginForm" action="${pageContext.request.contextPath}/securityLogin" method="post">
    用户名：<input type="text" name="username"/><br/>
    密码：<input type="password" name="password"/><br/>
    验证码:<input type="text" name="imageCode"/><img src="${pageContext.request.contextPath}/imageCode"/><br/>
    <input id="loginBtn" type="submit" value="登入"/>
</form>

<script type="text/javascript">
    $(function () {
        $("#loginBtn").click(function () {
            $.post("${pageContext.request.contextPath}/securityLogin", $("#loginForm").serialize(), function (data){
                if(data.userLogin){
                    window.location.href="${pageContext.request.contextPath}/product/index";
                }else{
                    alert("登入失败：" + data.errorMsg);
                    window.location.href="${pageContext.request.contextPath}/userLogin";
                }
                // alert(data);
            }, "json");
        });
    });
</script>
```
因为之前这段代码一直在验证spring security的同步认证方式，所有有个小细节没有注意导致调试了一整天就是想把问题找出，细心的同学应该可以发现这个小问题。
下面先说说问题，这段代码开启后台调试时一直无法debug到callback方法里面，报错不明显亦或是错误比较低级的原因，在网上找问题都是把错误指向了我后台返回的
json是否合法，我很纳闷的是因为我后台是用jackson类库来转换json应该不会出现json字符串不合法的情况。

debug的时候其实仔细点应该发现问题，但是真的运行下来没有报错，加之前端不是经常写的原因，花了很长的时间一直没有找到问题所在。其实我要是细心点应该发现
我没点击一次按钮触发两次请求，而且我用log4j打印日志时，每次都是两个进程查两次数据库(没有在意，其实对于所有异常的日志应该多问问自己为什么出现这种情况
)。而且chrome debug也是请求两次uri，每次都是正常返回200。后来我认真debug以下发现一次是http请求还有一次是jquery ajax请求。现在小伙伴应该已经知道问
题所在了，`<input type='submit'/>`这个type就是问题所在，但是由于我粗心大意直接在submit按钮上注册click事件导致debug过程极其不顺，没有任何错误的不
配合感觉非常迷茫的寻找问题出处，关键还不能debug到callback function里面。。。整个过程非常痛苦。

这样写下来的具体结果是，运行有时达到预期跳转到相应的页面，有时直接返回json字符串。。。真的懵逼。最后是运行过程中的警告给了一点灵感。警告信息如下：
`Resource interpreted as Document but transferred with MIME type text/json`，我明明指定了以json返回怎么又说格式不对。加之运行每次都是两次请求
而且结果时好时坏，其实就是一个是submit触发的请求，需要同步返回 document这里应该指的是text/html。而我又注册了一个click事件指定json返回，所有导致了
两个线程请求同时触发，且结果难测的局面。

结论是将input输入框的type改为button只使用jQuery异步提交就能解决。