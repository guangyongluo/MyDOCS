## Maven简介

### Maven是什么
Maven主要服务于基于Java平台的项目构建、依赖管理和项目管理。其用途之一是服务于构建，它是一个非常强大的构建工具，能够帮我们自动化构建过程，从清理、编译、测试到生成报告，再到打包和部署。同时它还能抽象构建过程，提供构建任务实现；Maven是夸平台的，无论是在Windows上，还是Linux或者是Mac上，都可以使用同样的命令完成构建工作。而Maven不仅仅是自动化构建工具，还是一个依赖管理工具和项目管理工具。Maven可以通过一个坐标系统准确地定位每一个构建（artifact），也就是通过一组坐标Maven能够找到任何一个Java类库（如jar文件）。Maven还能帮助我们管理原本分散在项目中各个角落的项目信息，包括项目描述、开发者列表、版本控制系统地址、许可证、缺陷管理系统地址等。Maven还未全世界的Java开发者提供了一个免费的中央仓库，在其中几乎可以找到任何的流行开源类库。

### Maven项目核心 pom.xml(Project Object Model)
在pom.xml文件中代码的第一行指定了xml文档的版本和编码方式。紧接着就是project元素，project是所有pom.xml的根元素，它同时声明了一些POM相关的命名空间及xsd元素。根元素下的第一个子元素modelVersion指定了当前POM模型的版本，对于maven 2和maven 3来说，它只能是4.0.0。  
在pom.xml文件中最重要的就是项目的基本坐标，在Maven的世界里，任何的jar、pom或者war都是以基于这些基本坐标进行区分的，它们是groupId、artifactId和version。groupId定义了项目属于哪个组，这个组往往和项目所在的组织和公司存在联系。artifactId定义了当前Maven项目在组中唯一的ID。而version指定了项目当前的版本。

### Maven坐标与依赖
Maven的一大功能是管理项目依赖。为了能自动化地解析任何一个Java构件，Maven就必须将它们唯一标识，这就依赖管理的底层基础——坐标。Maven定义了这样一组规则：世界上任何一个构件都可以使用Maven坐标唯一标识，Maven坐标的元素包括groupId、artifactId、version、packaging、classifier。只要我们提供正确的坐标元素，Maven就能找到对应的构件。下面详细解释一下各个坐标元素：
* groupId：定义当前Maven项目隶属的实际项目。首先，Maven项目和实际项目不一定是一对一的关系。如SpringFramework这个实际项目，其对应的Maven项目会有很多，如spring-core、spring-context等。这是由于Maven中的模块的概念，因此，一个实际项目往往会被划分成很多模块。其次，groupId不应该对应项目隶属的组织或公司。原因很简单，一个组织下会有很多实际项目，如果groupId只定义到组织级别，而后面我们会看到，artifactId只能定义项目（模块），那么实际项目这个层面将难以定义。最后，groupId的表示方式与Java包名的表示方式类似，通常与域名反向一一对应。
* artifactId：该元素定义实际项目中的一个Maven项目（模块），推荐的做法是使用实际项目名称作为artifactId的前缀。使用实际项目名称作为前缀之后，就能方便从一个lib文件夹中找到某个项目的一组构件。所以在Maven中groupId应该要到实际项目这个级别而artifactId则是要到模块这个级别。
* version：该元素定义Maven项目当前所处的版本。
* packaging：该元素定义Maven项目的打包方式。首先，打包方式通常与所生成构件的文件扩展名对应。其次，打包方式会影响到构建的生命周期，比如jar打包和war打包会使用不同的命令。最后，当不定义packaging的时候，Maven会使用默认值jar。
* classifier：该元素用来帮助定义构建输出的一些附属构件。附属构件与主构件对应，项目中可能会使用其他的插件生产Java文档和源代码等附属的构件，这时候，javadoc和sources就是这样两个附属构件的classifier。这样的附属构件也就拥有了自己唯一的坐标。注意，不能直接定义项目的classifier，因为附属构件不是项目直接默认生成的，而是有附加的插件帮助生成。  
上述5个元素中，groupId、artifactId、version是必须定义的，packaging是可选的（默认为jar），而classifier是不能直接定义的。

### Maven依赖范围
依赖范围就是用来控制依赖与这三种classpath(编译classpath、测试classpath、运行classpath)的关系，Maven有以下几种依赖范围：
* compile：编译依赖范围。如果没有指定，就会默认使用该依赖范围。对于编译、测试、运行三种classpath都有效。
* test：测试依赖范围。只对于测试classpath有效，在编译主代码或者运行项目时将无法使用此依赖。
* provided：已经提供依赖范围。对于编译和测试classpath有效，但在运行时无效。
* runtime：运行时依赖范围。对于测试和运行classpath有效，但在编译主代码时无效。
* system：系统依赖范围，该依赖与三种classpath的关系，和provided依赖范围完全一致。但是，使用system范围的依赖时必须通过systemPath元素显式地指定依赖文件的路径。由于此类依赖不是通过Maven仓库解析的，而且往往与本机系统绑定，可能造成构建的不可移植，因此应该谨慎使用。systemPath元素可以引用环境变量。
* import：导入依赖范围。该依赖范围不会对三种classpath产生实际的影响。

### 传递依赖和依赖范围
传递依赖的概念：Maven会解析各个直接依赖的POM，将那些必要的间接依赖，以传递依赖的形式引入到当前的项目中。假设A依赖于B，B依赖于C，我们就说A对于B是第一直接依赖，B对于C是第二直接依赖，A对于C是传递依赖。第一直接依赖的范围和第二直接依赖的范围决定了传递性依赖的范围。对于传递依赖的范围如下表所示：  

|  |compile|test|provided|runtime|
|:--------:|:--------:|:--------:|:--------:|:--------:|
|compile|compile|-|-|runtime|
|test|test|-|-|test|
|provided|provided|-|provided|provided|
|runtime|runtime|-|-|runtime|

### 依赖调解
依赖调解的两大原则：  
1. 路劲近者优先原则，例如：A->B->C->X(1.0)、A->D->X(2.0),根据路径近者优先，第一条依赖路径的长度为3，第二条路径的长度为2,因此X(2.0)会被解析使用。
2. 声明顺序优先原则，当两个传递依赖路径长度相同时，在POM中依赖声明的顺序决定了到底解析哪个依赖，顺序靠前的依赖优先。

### 解决依赖问题的最佳实践
1. 排除依赖：传递性依赖会给项目隐式地引入很多依赖，这是极大地简化了项目依赖的管理，但是有些时候这种依赖也会带来问题。当我们不希望传递的依赖被解析而想替换某个传递性依赖，可以使用exclusions元素声明排除依赖，exclusions可以包含一个或多个exclusion子元素，因此可以排除一个或者多个传递性依赖。需要注意的是，声明exclusion的时候只需要groupId和artifactId，而不需要version元素，这是因为只需要groupId和artifactId就能唯一定位依赖图中的某个依赖。换句话说，Maven解析后的依赖中，不可能出现groupId和artifactId相同，但是version不同的两个依赖。(依赖调解)
2. 归类依赖：使用Maven属性，首先使用properties元素定义Maven属性，在定义了属性之后可以使用美元符合大括弧的方式来引用Maven属性。
3. 优化依赖：Maven会自动解析所有项目的直接依赖和传递依赖，并且根据规则正确判断每个依赖的范围，对于一些依赖冲突，也能进行调节，以确保任何一个构件只有唯一的版本在依赖中存在。在这些工作之后，最后得到的那些依赖被称为已解析依赖(Resolved Dependency)。使用dependency:list和dependency:tree可以帮助我们详细了解项目中所有依赖的具体信息，在此基础上，还有dependency:analyze工具可以帮助分析当前项目的依赖。尤其是使用`mvn dependency:analyze`该结果中重要的是两个部分。首先是Used undeclared dependencies，意味项目中使用到的，但是没有显示声明的依赖，这种依赖意味着潜在的风险，当前项目直接在使用它们，例如有很多相关的Java import声明，而这种依赖是通过直接依赖传递进来的，当升级直接依赖的时候，相关传递性依赖的版本也可能发生变化，这种变化不易察觉，但是有可能导致当前项目出错。例如由于接口的改变，当前项目中的相关代码无法编译。这种隐藏的、潜在的威胁一旦出现，就往往需要耗费大量的时间来查明真相。因此，显示声明任何项目中直接用到的依赖。结果中还有一个重要的部分是Unused declared dependencies，意指项目中未使用的，但是显示声明的依赖。需要注意的是，对于这样一类依赖，我们不应该简单地直接删除其声明，而是应该仔细分析。由于dependency:analyze只会分析编译主代码和测试代码需要用到的依赖，一些执行测试和运行时需要的依赖就发现不了。因此一定要小心测试找到没用的依赖再删除。
