### swagger3学习手册

### 1. 前言
Swagger是一个简单但功能强大的API表达工具。它具有地球上最大的API工具生态系统，数以千计的开发人员，使用几乎所有的现代编程语言，都在支持和使用Swagger。使用Swagger生成API，我们可以得到交互式文档，自动生成代码的SDK以及API的发现特性等。前后端分离的项目，接口文档的存在十分重要。与手动编写接口文档不同，swagger是一个自动生成接口文档的工具，在需求不断变更的环境下，手动编写文档的效率实在太低。与swagger2相比新版的swagger3配置更少，使用更加方便。

### 2.Swagger作用
将项目中所有的接口展现在页面上，这样后端程序员就不需要专门为前端使用者编写专门的接口文档；当接口更新之后，只需要修改代码Swagger 描述就可以实时生成新的接口文档了，从而规避了接口文档老旧不能使用的问题；通过Swagger页面，我们可以直接进行接口调用，降低了项目开发阶段的调试成本。现在SWAGGER官网主要提供了几种开源工具，提供相应的功能。可以通过配置甚至是修改源码以达到你想要的效果
- Swagger Codegen: 通过Codegen可以将描述文件生成html格式和cwiki形式的接口文档，同时也能生成多钟语言的服务端和客户端的代码。支持通过jar包，docker，node等方式在本地化执行生成。也可以在后面的Swagger Editor中在线生成。
- Swagger UI:提供了一个可视化的UI页面展示描述文件。接口的调用方、测试、项目经理等都可以在该页面中对相关接口进行查阅和做一些简单的接口请求。该项目支持在线导入描述文件和本地部署UI项目。
- Swagger Editor: 类似于markendown编辑器的编辑Swagger描述文件的编辑器，该编辑支持实时预览描述文件的更新效果。也提供了在线编辑器和本地部署编辑器两种方式。
- Swagger Inspector: 感觉和postman差不多，是一个可以对接口进行测试的在线版的postman。比在Swagger UI里面做接口请求，会返回更多的信息，也会保存你请求的实际请求参数等数据。
- Swagger Hub：集成了上面所有项目的各个功能，你可以以项目和版本为单位，将你的描述文件上传到Swagger Hub中。在Swagger Hub中可以完成上面项目的所有工作，需要注册账号，分免费版和收费版。
使用Swagger，就是把相关的信息存储在它定义的描述文件里面（yml或json格式），再通过维护这个描述文件可以去更新接口文档，以及生成各端代码。

### 3.Open API
Open API规范(OpenAPI Specification)以前叫做Swagger规范，是REST API的API描述格式。
Open API文件允许描述整个API，包括：
* 每个访问地址的类型。POST或GET。
* 每个操作的参数。包括输入输出参数。
* 认证方法。
* 连接信息，声明，使用团队和其他信息。
Open API规范可以使用YAML或JSON格式进行编写。这样更利于我们和机器进行阅读。

OpenAPI规范（OAS）为REST API定义了一个与语言无关的标准接口，允许人和计算机发现和理解服务的功能，而无需访问源代码，文档或通过网络流量检查。正确定义后，消费者可以使用最少量的实现逻辑来理解远程服务并与之交互。
然后，文档生成工具可以使用OpenAPI定义来显示API，使用各种编程语言生成服务器和客户端的代码生成工具，测试工具以及许多其他用例。  


### 4.springfox
使用Swagger时如果碰见版本更新或迭代时，只需要更改Swagger的描述文件即可。但是在频繁的更新项目版本时很多开发人员认为即使修改描述文件（yml或json）也是一定的工作负担，久而久之就直接修改代码，而不去修改描述文件了，这样基于描述文件生成接口文档也失去了意义。Marty Pitt编写了一个基于Spring的组件swagger-springmvc。Spring-fox就是根据这个组件发展而来的全新项目。Spring-fox是根据代码生成接口文档，所以正常的进行更新项目版本，修改代码即可，而不需要跟随修改描述文件。Spring-fox利用自身AOP特性，把Swagger集成进来，底层还是Swagger。但是使用起来确方便很多。所以在实际开发中，都是直接使用spring-fox。

### 5.swagger配置
1. 基本配置信息

- Docket: 摘要对象，通过对象配置描述文件的信息。
- apiInfo: 设置描述文件中的info。参数类型ApiInfo。
- select(): 返回ApiSelectorBuilder对象，通过对象调用build()可以创建Docket对象。
- ApiInfoBuilder: ApiInfo构建器。

添加springboot依赖
```xml
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-boot-starter</artifactId>
    <version>3.0.0</version>
</dependency>
```


```java
@Configuration
public class SwaggerConfiguration {

    /**
     * 创建Docket类型对象。并使用spring容器管理。
     * Docket是Swagger中的全局配置对象
     */

    @Bean
    public Docket docket(){
        Docket docket = new Docket(DocumentationType.OAS_30);

        return docket.apiInfo(createApiInfo())
                .select()
                // 配置扫描路径下的API接口
                .apis(RequestHandlerSelectors.basePackage("com.vilin.demo.controller"))
                // 配置过滤API接口的资源路径
                .paths(PathSelectors.regex("/hello/.*"))
                .build();
    }

    // 配置API文档的基本信息
    private ApiInfo createApiInfo(){
        return new ApiInfoBuilder().title("Swagger Test")
                .description("api first configuration.")
                .contact(new Contact("Leo", "www.vilin.com", "guangyongluo@outlook.com"))
                .license("Apache 2.0")
                .licenseUrl("http://www.apache.org/licenses/LICENSE-2.0")
                .version("1.0")
                .build();
    }
}
```

### 6. 常用Swagger API注解
```less
@Api：用在请求的类上，表示对类的说明
    tags="说明该类的作用，可以在UI界面上看到的注解"
    value="该参数没什么意义，在UI界面上也看到，所以不需要配置"

@ApiOperation：用在请求的方法上，说明方法的用途、作用
    value="说明方法的用途、作用"
    notes="方法的备注说明"

@ApiImplicitParams：用在请求的方法上，表示一组参数说明
    @ApiImplicitParam：用在@ApiImplicitParams注解中，指定一个请求参数的各个方面
        name：参数名
        value：参数的汉字说明、解释
        required：参数是否必须传
        paramType：参数放在哪个地方
            · header --> 请求参数的获取：@RequestHeader
            · query --> 请求参数的获取：@RequestParam
            · path（用于restful接口）--> 请求参数的获取：@PathVariable
            · div（不常用）
            · form（不常用）    
        dataType：参数类型，默认String，其它值dataType="Integer"       
        defaultValue：参数的默认值

@ApiResponses：用在请求的方法上，表示一组响应
    @ApiResponse：用在@ApiResponses中，一般用于表达一个错误的响应信息
        code：数字，例如400
        message：信息，例如"请求参数没填好"
        response：抛出异常的类

@ApiModel：用于响应类上，表示一个返回响应数据的信息
            （这种一般用在post创建的时候，使用@RequestBody这样的场景，
            请求参数无法使用@ApiImplicitParam注解进行描述的时候）
    @ApiModelProperty：用在属性上，描述响应类的属性
```