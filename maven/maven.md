## Maven简介

### Maven是什么
Maven主要服务于基于Java平台的项目构建、依赖管理和项目管理。其用途之一是服务于构建，它是一个非常强大的构建工具，能够帮我们自动化构建过程，从清理、编译、测试到生成报告，再到打包和部署。同时它还能抽象构建过程，提供构建任务实现；Maven是夸平台的，无论是在Windows上，还是Linux或者是Mac上，都可以使用同样的命令完成构建工作。而Maven不仅仅是自动化构建工具，还是一个依赖管理工具和项目管理工具。Maven可以通过一个坐标系统准确地定位每一个构建（artifact），也就是通过一组坐标Maven能够找到任何一个Java类库（如jar文件）。Maven还能帮助我们管理原本分散在项目中各个角落的项目信息，包括项目描述、开发者列表、版本控制系统地址、许可证、缺陷管理系统地址等。Maven还未全世界的Java开发者提供了一个免费的中央仓库，在其中几乎可以找到任何的流行开源类库。

### Maven项目核心 pom.xml(Project Object Model)
在pom.xml文件中代码的第一行指定了xml文档的版本和编码方式。紧接着就是project元素，project是所有pom.xml的根元素，它同时声明了一些POM相关的命名空间及xsd元素。根元素下的第一个子元素modelVersion指定了当前POM模型的版本，对于maven 2和maven 3来说，它只能是4.0.0。  
在pom.xml文件中最重要的就是项目的基本坐标，在Maven的世界里，任何的jar、pom或者war都是以基于这些基本坐标进行区分的，它们是groupId、artifactId和version。groupId定义了项目属于哪个组，这个组往往和项目所在的组织和公司存在联系。artifactId定义了当前Maven项目在组中唯一的ID。而version指定了项目当前的版本。

### Maven坐标与依赖
Maven的一大功能是管理项目依赖。为了能自动化地解析任何一个Java构件，Maven就必须将它们唯一标识，这就依赖管理的底层基础——坐标。Maven定义了这样一组坐标：世界上任何一个构件都可以使用Maven坐标唯一标识，Maven坐标的元素包括groupId、artifactId、version、packaging、classifier。只要我们提供正确的坐标元素，Maven就能找到对应的构件。下面详细解释一下各个坐标元素：
* groupId：定义当前Maven项目隶属的实际项目。首先，Maven项目和实际项目不一定是一对一的关系。如SpringFramework这个实际项目，其对应的Maven项目会有很多，如spring-core、spring-context等。这是由于Maven中的模块的概念，因此，一个实际项目往往会被划分成很多模块。其次，groupId不应该对应项目隶属的组织或公司。原因很简单，一个组织下会有很多实际项目，如果groupId只定义到组织级别，而后面我们会看到，artifactId只能定义项目（模块），那么实际项目这个层面将难以定义。最后，groupId的表示方式与Java包名的表示方式类似，通常与域名反向一一对应。
* artifactId：该元素定义实际项目中的一个Maven项目（模块），推荐的做法是使用实际项目名称作为artifactId的前缀。使用实际项目名称作为前缀之后，就能方便从一个lib文件夹中找到某个项目的一组构件。所以在Maven中groupId应该要到实际项目这个级别而artifactId则是要到模块这个级别。
* version：该元素定义Maven项目当前所处的版本。
* packaging：该元素定义Maven项目的打包方式。首先，打包方式通常与所生成构件的文件扩展名对应。其次，打包方式会影响到构建的生命周期，比如jar打包和war打包会使用不同的命令。最后，当不定义packaging的时候，Maven会使用默认值jar。
* classifier：该元素用来帮助定义构建输出的一些附属构件。附属构件与主构件对应，项目中可能会使用其他的插件生产Java文档和源代码等附属的构件，这时候，javadoc和sources就是这样两个附属构件的classifier。这样的附属构件也就拥有了自己唯一的坐标。注意，不能直接定义项目的classifier，因为附属构件不是项目直接默认生成的，而是有附加的插件帮助生成。  
上述5个元素中，groupId、artifactId、version是必须定义的，packaging是可选的（默认为jar），而classifier是不能直接定义的。
