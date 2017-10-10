## Maven简介

### Maven是什么
Maven主要服务于基于Java平台的项目构建、依赖管理和项目管理。其用途之一是服务于构建，它是一个非常强大的构建工具，能够帮我们自动化构建过程，从清理、编译、测试到生成报告，再到打包和部署。同时它还能抽象构建过程，提供构建任务实现；Maven是夸平台的，无论是在Windows上，还是Linux或者是Mac上，都可以使用同样的命令完成构建工作。而Maven不仅仅是自动化构建工具，还是一个依赖管理工具和项目管理工具。Maven可以通过一个坐标系统准确地定位每一个构建（artifact），也就是通过一组坐标Maven能够找到任何一个Java类库（如jar文件）。Maven还能帮助我们管理原本分散在项目中各个角落的项目信息，包括项目描述、开发者列表、版本控制系统地址、许可证、缺陷管理系统地址等。Maven还未全世界的Java开发者提供了一个免费的中央仓库，在其中几乎可以找到任何的流行开源类库。

### Maven项目核心 pom.xml(Project Object Model)
在pom.xml文件中代码的第一行指定了xml文档的版本和编码方式。紧接着就是project元素，project是所有pom.xml的根元素，它同时声明了一些POM相关的命名空间及xsd元素。根元素下的第一个子元素modelVersion指定了当前POM模型的版本，对于maven 2和maven 3来说，它只能是4.0.0。  
在pom.xml文件中最重要的就是项目的基本坐标，在Maven的世界里，任何的jar、pom或者war都是以基于这些基本坐标进行区分的，它们是groupId、artifactId和version。groupId定义了项目属于哪个组，这个组往往和项目所在的组织和公司存在联系。artifactId定义了当前Maven项目在组中唯一的ID。而version指定了项目当前的版本。