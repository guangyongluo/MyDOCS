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

### Maven仓库
在Maven世界里，任何一个依赖、插件或者项目构建的输出，都可以称为构建。得益于坐标机制，任何Maven项目使用任何一个构件的方式都是完全相同的。在此基础上，Maven可以在某个位置统一储存所有Maven项目共享的构件，这个统一的位置就是仓库。其实Maven项目将不再各自存储依赖文件，它们只需要声明这些依赖的坐标，在需要的时候(例如，编译项目的时候需要将依赖加入到classpath中)，Maven会自动根据坐标找到仓库中的构件，并使用它们。  

对于Maven来说，仓库分为两类：本地仓库和远程仓库。当Maven根据坐标寻找到构建时，它首先会查看本地仓库，如果本地仓库存在此构建，则直接使用；如果本地仓库不存在此构件，或者需要查看是否有更新的构件版本，Maven就会去远程仓库查找，发现需要的构件之后，下载到本地仓库再使用。如果本地仓库和远程仓库都没有需要的构件，Maven就会报错。中央仓库是Maven自带的远程仓库，它包含了绝大部分开源的构件。在默认配置下，当本地仓库没有Maven需要的构件的时候，它就会尝试从中央仓库下载。私服是另一种特殊的远程仓库，为了节省宽带和时间，应该在局域网内架设一个私有的仓库服务器，用其代理所有外部的远程仓库。内部项目还能部署到私服上供其他项目使用。  

* 本地仓库：用户可以自定义本地仓库的目录地址。编辑~/.m2/setting.xml，设置localRepository元素的值为想要的仓库地址。setting.xml文件可以从Maven的安装目录复制$M2_HOME/conf/setting.xml文件再进行编辑。一个构件只有在本地仓库中才能让其他的Maven项目使用。有两种情况将Maven构件放到本地仓库：1.从远程仓库下载；2.将本地的项目构建安装到Maven仓库中。
* 远程仓库：安装好Maven后，如果不执行任何Maven命令，本地仓库目录是不存在的。当用户输入第一条Maven命令之后，Maven才会创建本地仓库，然后根据配置和需要，从远程仓库下载至本地仓库。
* 私服：私服是一种特殊的远程仓库，它是架设在局域网内的仓库服务，私服代理广域网上的远程仓库，供局域网内的Maven用户使用。当Maven需要下载构件的时候，它从私服请求，如果私服上不存在该构件，则从外部的远程仓库下载，缓存在私服上之后，再为Maven的下载请求提供服务。此外，一些无法从外部仓库下载到的构件也能从本地上传到私服上供大家使用。

配置远程仓库：
```
<project>
    ...
    <repositories>
        <id>jboss</id>
        <name>JBoss Repository</name>
        <url>http://repository.jboss.com/maven2/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
    </repositories>
</project>
```
对于以上远程仓库配置的解释：声明了一个id为jboss，名称为JBoss Repository的仓库。任何一个仓库声明的id必须是唯一的，尤其需要注意的是，Maven自带的中央仓库使用的id为central，如果其他的仓库声明也使用该id，就会覆盖中央仓库的配置。url值指向了仓库的地址，一般来说，该地址都基于http协议，Maven用户都可以在浏览器中打开仓库地址浏览构件。relases的enabled值为true，表示开启JBoss仓库的发布版本下载支持，而snapshots的enabled值为false，表示关闭JBoss仓库的快照版本的下载支持。因此，根据该配置，Maven只会从JBoss仓库下载发布版本的构件，而不会下载快照版的构件。  

对于releases和snapshots来说，除了enabled，它们还包含另外两个子元素updatePolicy和checksumPolicy:  
```
<snapshots>
    <enabled>true</enabled>
    <updatePolicy>daily</updatePolicy>
    <checksumPolicy>ignore</checksumPolicy>
</snapshots>
```
元素updatePolicy用来配置Maven从远程仓库检查更新的频率，默认的值是daily，表示Maven每天检查一次。其他可用的值包括：never-从不检查更新；always-每天构件都检查更新；interval：X-每隔X分钟检查一次更新(X为任意整数)。元素checksumPolicy用来配置Maven检查检验和文件的策略。当构件被部署到Maven仓库中时，会同时部署对应的校验和文件。在下载构件时，Maven会验证校验和文件，当checksumPolicy的值为默认的warn时，Maven会在执行构件校验和验证失败时输出警告信息，其他可用的值包括：fail-Maven遇到校验和错误就让构件失败；ignore-使Maven完全忽略校验和错误。

### 远程仓库的认证
配置认证信息和配置仓库信息不同，仓库信息可以直接配置在POM文件中，但是认证信息必须配置在settings.xml文件中。这是因为POM往往是被提交到代码仓库中供所有成员访问的，而settings.xml一般只放在本机。因此，在settings.xml中配置认证信息更为安全。例如：
```
<settings>
    <servers>
        <server>
            <id>my-proj</id>
            <username>reop-user</username>
            <password>repo-pwd</password>
        </server>
    </servers>
</settings>
```
这里关键是id元素，settings.xml中的server元素的id必须与POM中需要认证的repository元素的id完全一致。换句话说，正是这个id将认证信息与仓库配置联系在一起。

部署至远程仓库：Maven除了能对项目进行编译、测试、打包外，还能将项目生成的构件部署到仓库中。配置distributionManagement元素如下：
```
<project>
    <distributionManagement>
        <repository>
            <id>proj-releases</id>
            <name>Proj Release Repository</name>
            <url>http://192.168.1.100/content/repositories/proj-releases</url>
        </repository>
        <snapshotRepository>
            <id>proj-snapshots</id>
            <name>Proj Snapshot Repository</name>
            <url>http://192.168.1.100/content/repositories/proj-snapshots</url>
        </snapshotRepository>
    </distributionManagement>
</project>
```
distributionManagement包含repository和snapshotRepository子元素，前者表示发布版本构件的仓库，后者表示快照版本的仓库。这两个元素下都需要配置id、name和url，id为该远程仓库的唯一标识，name是为了方便人阅读，关键的url表示该仓库的地址。  

### 快照版本的实践
快照版本只应该在组织内部的项目或模块间依赖使用，因为这时，组织对于这些快照版本的依赖具有完全的理解及控制权。项目不应该依赖与任何组织外部的快照版本依赖，由于快照版本的不稳定性，这样的依赖会造成潜在的危险。在发布过程中，Maven会自动为构建打上时间戳。比如2.1-20171228-153833-13就表示2017年12月28日15时38分33秒的第13次快照。有了该时间戳，Maven就能随时找到仓库中该构件2.1-SNAPSHOT版本最新的文件。默认情况下，Maven每天检查一次更新(由仓库配置的updatePolicy控制)，用户也可以使用命令行-U参数强制让Maven检查更新，如mvn clean install -U。当依赖的版本设为快照版本的时候，Maven也需要检查更新，这时，Maven会检查仓库元数据groupId/artifactId/version/maven-metadata.xml，该XML文件的snapshot元素包含了timestamp和buildNumber两个子元素，分别代表了这一快照的时间戳和构件号，基于这两个元素可以得到该仓库中此快照的最新构件版本实际值。通过合并所有远程仓库和本地仓库的元数据，Maven就能知道所有仓库中该构件的最新快照。

### 镜像配置
如果仓库X可以提供仓库Y存储的所有内容，那么就可以认为X是Y的一个镜像。换句话说，任何一个可以从仓库Y获得的构件，都能够从它的镜像中获得。配置中央仓库的镜像，可以编辑settings.xml文件。
```
<settings>
    <mirrors>
        <mirror>
            <id>maven.net.cn</id>
            <name>one of the central mirrors in China</name>
            <url>http://maven.net.cn/content/groups/public/</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
</settings>
```
在这个例子中mirrorOf的值为central，表示给配置为中央仓库的镜像，任何对中央仓库的请求都会转至该镜像，用户也可以使用同样的方法配置其他仓库的镜像。需要注意的是，由于镜像仓库完全屏蔽了被镜像仓库，当镜像仓库不稳定时或者停止服务时候，Maven仍然无法请问被镜像仓库，因而将无法下载构件。

##### 几个重要的仓库搜索服务地址

[Sonatype Nexus](http://repository.sonatype.org/ "Sonatype Nexus")：Nexus是当前最流行的开源Maven仓库管理软件。     
[MVNbrowser](http://www.mvnbrowser.com "MVNbrowser")：只能提供关键字搜索功能。  
[MVNrepository](http://mvnrepository "MVNrepository"): 提供关键字的搜索、依赖声明代码片段、构建下载、依赖与被依赖关系信息、构件所包含信息等功能。

### 生命周期
Maven的生命周期就是为了对所有的构建过程进行抽象和统一。Maven从大量项目和构建工具中学习和反思，然后总结了一套高度完善的、易扩展的生命周期。这个生命周期包含了项目的清理、初始化、编译、测试、打包、集成测试、验证、部署和站点生成几乎所有构建步骤。Maven生命周期是抽象的，这意味着生命周期本身不做任何实际的工作，在Maven的设计中，实际的任务都交由插件来完成。Maven拥有三套相互独立的生命周期，它们分别是clean、default和site。clean生命周期的目的是清理项目，default生命周期的目的是构件项目，而site生命周期的目的是建立项目站点。每个生命周期包含一些阶段(phase)，这些阶段是有顺序的，并且后面的阶段依赖于前面的阶段，用户和Maven最直接的交互就是调用这些生命周期阶段。  较之与生命周期阶段的前后依赖关系，三套生命周期本身是相互独立的，用户可以仅仅调用clean生命周期的某个阶段，或者仅仅调用default生命周期的某个阶段，而不会对其他生命周期生产任何影响。以下列出三套独立生命周期的所有阶段：

##### clean生命周期
1. pre-clean 
2. clean 清理上一次构建生成的文件。
3. post-clean

##### default生命周期
1. vaidate
2. initialize
3. generate-sources
4. process-sources 处理项目主资源文件 /src/main/resources
5. generate-resources
6. process-resources 
7. compile 编译项目的主源码  /src/main/java
8. process-clasees
9. generate-test-sources
10. process-test-sources 处理项目测试资源文件 /src/test/resources
11. generate-test-resources
12. process-test-resources
13. test-compile 编译项目的测试代码 /src/test/java
14. process-test-classes
15. test 使用单元测试框架运行测试，测试代码不会打包和部署。
16. prepare-package
17. package接受编译好的代码，打包成可发布的格式。
18. pre-integration-test
19. integration-test
20. post-integration-test
21. verify
22. install 将包安装到Maven本地仓库，供本地其他Maven项目使用。
23. deploy 将最终的包复制到远程仓库，供其他开发人员和Maven项目使用。

##### site生命周期
1. pre-site
2. site 生成项目站点文档。
3. post-site
4. site-deploy 将生成的项目站点发布到服务器上。

### 插件目标与绑定
Maven的核心仅仅定义了抽象的生命周期，具体的任务是交由插件完成的，插件以独立的构件形式存在，因此，Maven核心的分发包只有不到3MB大小，Maven会在需要的时候下载并使用相关插件。对于插件本身，为了能够复用代码，它往往能够完成多个任务。一个插件完成相关的多个功能这样每个功能就是一个插件目标。Maven生命周期与插件相互绑定，用以完成实际的构建任务。具体而言，是生命周期的阶段与插件的目标相互绑定，以完成某个具体的构建任务。Maven在核心为一些主要的生命周期绑定了很多插件的目标，当用户通过命令调用生命周期的阶段的时候，对应的插件目标就会执行相应的任务。以下表格列出内置绑定：

表1 clean生命周期阶段与插件目标的绑定关系  

|生命周期阶段|插件目标|
|:---------:|:----------------:|
|pre-clean||
|clean|maven-clean-plugin:clean|
|post-clean||

表2 default生命周期的内置插件绑定关系及具体任务  


|生命周期阶段|差价目标|执行任务|
|:-----------------:|:-----------------:|:---------------------------------:|
|process-resources|maven-resources-plugin:resources|复制主资源文件至主输出目录|
|compile|maven-compiler-plugin:compile|编译主代码至主输出目录|
|process-test-resources|maven-resources-plugin:testResources|复制测试资源文件至测试输出目录|
|test-compile|maven-compiler-plugin:testCompile|编译测试代码至测试输出目录|
|test|maven-surefile-plugin:test|执行测试用例|
|package|maven-jar-plugin:jar|创建项目jar包|
|install|maven-install-plugin:install|将项目输出构件安装到本地仓库|
|deploy|maven-deploy-pluing:deploy|将项目输出构件部署到远程仓库|


表3 site生命周期阶段与插件目标绑定关系  

|生命周期阶段|插件目标|
|:--------:|:----------------:|
|pre-site||
|site|maven-site-plugin:site|
|post-site||
|site-deploy|maven-site-plugin:deploy|  

##### 自定义绑定
除了内置绑定外，用户还能自己选择将某个插件目标绑定到生命周期的某个阶段上，这种自定义绑定方式能让Maven项目在构件过程中执行更多更富特色的任务。具体配置如下：
```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-source-plugin</artifactId>
            <version>2.1.1</version>
            <executions>
                <execution>
                    <id>attach-sources</id>
                    <phase>verify</phase>
                    <goals>
                        <goal>jar-no-fork</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```
上述配置中，除了基本的坐标声明外，还有插件执行配置，executions下每个execution子元素可以用来配置执行一个任务。该例中配置了一个id为attah-sources的任务，通过phase配置，将其绑定到verify生命周期阶段上，再通过goals配置指定要执行的插件目标。有时候，即使不通过phase元素配置生命周期阶段，插件目标也能够绑定到生命周期中去。因为有很多插件的目标在编写时已经定义了默认绑定阶段。

##### 插件配置
1. 很多插件目标的参数都支持从命令行配置，用户可以在Maven命令中使用-D参数，帮伴随一个参数键=参数值的形式，来配置插件目标参数。
2. 有些参数的值从项目创建到项目发布都不会改变，或者说很少改变，对于这种情况，在POM文件中一次性配置就显然比重复再命令行输入要方便。这种在POM对插件参数进行全局配置如配置JDK编译1.8版本的源文件：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>2.1</version>
            <configuration>
                <source>1.8</source>
                <target>1.8</target>
            </configuration>
        </plugin>
    </plugins>
</build>
```

##### 获得插件信息的常用方式
1. 使用maven-help-plugin的describe目标：`mvn help:describe -Dplugin=org.apache.maven.plugins:maven-compiler-plugin:2.1`
2. Maven还支持直接从命令行调用插件目标，这种方式是因为有些任务不适合绑定在生命周期上。`mven dependency:tree`

### 聚合与继承
Maven聚合特性能够把项目的各个模块聚合在一起构建，而Maven的继承特性则能帮助抽取各个模块相同的依赖和插件等配置，在简化POM的同时，还能促进各个模块配置的一致性。一般来说，一个项目的子模块都应该使用同样的groupId，如果它们一起开发和发布，还应该使用同样的version，此外，它们的artifactId还应该使用一致的前缀，以方便同其他项目区分。  

聚合的实际例子：
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.juvenxu.mvnbook.account</groupId>
	<artifactId>account-aggregator</artifactId>
	<version>1.0.0-SNAPSHOT</version>
	<packaging>pom</packaging>
	<name>Account Aggregator</name>
	<modules>
		<module>account-email</module>
		<module>account-persist</module>
		<module>account-parent</module>
	</modules>
</project>
```
以上例子的解释：对于聚合模块来说，其打包方式packaging的值必须为pom，否则就无法构建。用户可以通过在一个打包方式为pom的Maven项目中声明任意数量的module元素来实现模块的聚合。这里每个module的值都是一个当前POM的相对目录。一般来说，为了方便快速定位内容，模块所处的目录名称应该与其artifactId一致，不过这不是Maven的要求，用户也可以将account-email项目放到email-account/目录下。这时，聚合的配置就需要相应地改为`<module>email-account</module>`。为了方便用户构件项目，通常将聚合模块放在项目目录的最顶层，其他模块则作为聚合块的子目录存在，这样当用户得到源码的时候，第一眼发现的就是聚合模块的POM，不用从多个模块中去寻找聚合模块来构建整个项目。account-aggregator的内容仅是一个pom.xml文件，他不像其他模块那样有src/main/java、src/test/java等目录。聚合模块仅仅是帮助聚合其他模块构建的工具，它本身并无实质内容。关于目录结构还需要注意的是，聚合模块的目录结构并非一定要是父子关系。如果使用平行目录结构，聚合模块的POM也需要做相应的修改，以指向正确的模块目录：
```
<modules>
    <module>../account-email</module>
    <module>../account-persist</module>
</modules>
```
最后通过`mvn clean install`命令构建聚合后的项目，Maven会首先解析聚合模块POM、分析要构建的模块、并计算出一个反应堆构建顺序(Reactor Build Order)，然后根据这个顺序依次构建各个模块。

面向对象设计中，程序员建立一种类的父子结构，然后在父类中声明一些字段和方法供子类继承，这样就可以做到“一处声明，多处使用”。类似地，我们需要创建POM的父子结构，然后再父POM中声明一些配置供子POM继承，以实现配置重用。由于父模块只是为了帮助消除配置的重复，因此它本身不包含除POM之外的项目文件，也就不需要src/main/java之类的文件夹了。以下是一个继承的例子：
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	
	<parent>
		<groupId>com.juvenxu.mvnbook.account</groupId>
		<artifactId>account-parent</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../account-parent/pom.xml</relativePath>
	</parent>
	
	<artifactId>account-email</artifactId>
	<name>Account Email</name>

    <dependencies>
    ...
    </dependencies>
    
    <build>
    ...
    </build>
    
</project>
```
该例中parent子元素groupId、artifactId和version指定了父模块的坐标，这三个元素是必须的。元素relativePath表示父模块POM的相对路劲。当项目构建时，Maven会首先根据relativePath检查父POM，如果找不到，再从本地仓库查找。relativePath的默认值是../pom.xml，也就是说，Maven默认父POM在上一层目录下。正确设置relativePath非常重要。当开发团队直接签出一个包含父子模块关系的Maven项目。由于只关心其中一个子模块，它就直接到该模块的目录下执行构件，这个时候，父模块还没有被安装到本地仓库，因此如果子模块没有设置正确的relativePath，Maven将无法找到父POM，直接导致构件失败。在上例中POM没有为account-email声明groupId和version，不过这并不代表account-email没有groupId和version。实际上，这个子模块隐式地从父模块继承了这两个元素，这也就消除了一些不必要的配置。

##### 可继承的POM元素
* groupId：项目组ID，项目坐标的核心元素。
* versioin：项目版本，项目坐标的核心元素。
* description：项目的描述信息。
* organization：项目的组织信息。
* inceptionYear：项目的创始年份。
* url：项目的URL地址。
* developers：项目的开发者信息。
* contributors：项目的贡献者信息。
* distributionManagement：项目的部署配置。
* issueManagement：项目的缺陷跟踪系统信息。
* ciManagement：项目的持续集成信息信息。
* scm：项目的版本控制系统信息。
* mailingLists：项目的邮件列表信息。
* properties：自定义的Maven属性。
* dependencies：项目的依赖配置。
* dependencyManagement：项目的依赖管理配置。
* repository：项目的仓库配置。
* build：包括项目的源码目录配置、输出目录配置、插件配置、插件管理配置等。
* reporting：包括项目的报告输出目录配置、报告插件配置等。

##### 依赖管理和插件管理
Maven提供的dependencyManagement元素既能让子元素继承到父模块的依赖配置，又能保证子模块依赖使用的灵活性。在dependencymanagement元素下的依赖声明不会引入实际的依赖，不过它能够约束dependencies下的依赖使用。Maven也提供了pluginManagement元素帮助管理插件。在该元素中配置的依赖不会造成实际的插件调用行为，当POM中配置了真正的plugin元素，并且其groupId和artifactId与pluginManagement中配置的插件匹配时，pluginManagement的配置才会影响实际的插件行为。以下列举一个父模块的POM文件让其他子模块来继承：
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.juvenxu.mvnbook.account</groupId>
	<artifactId>account-parent</artifactId>
	<version>1.0.0-SNAPSHOT</version>
	<packaging>pom</packaging>
	<name>Account Parent</name>
	<properties>
		<springframework.version>2.5.6</springframework.version>
		<junit.version>4.7</junit.version>
	</properties>
	<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>org.springframework</groupId>
				<artifactId>spring-core</artifactId>
				<version>${springframework.version}</version>
			</dependency>
			<dependency>
				<groupId>org.springframework</groupId>
				<artifactId>spring-beans</artifactId>
				<version>${springframework.version}</version>
			</dependency>
			<dependency>
				<groupId>org.springframework</groupId>
				<artifactId>spring-context</artifactId>
				<version>${springframework.version}</version>
			</dependency>
			<dependency>
				<groupId>org.springframework</groupId>
				<artifactId>spring-context-support</artifactId>
				<version>${springframework.version}</version>
			</dependency>
			<dependency>
				<groupId>junit</groupId>
				<artifactId>junit</artifactId>
				<version>${junit.version}</version>
				<scope>test</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
	<build>
		<pluginManagement>
			<plugins>
				<plugin>
					<groupId>org.apache.maven.plugins</groupId>
					<artifactId>maven-compiler-plugin</artifactId>
					<configuration>
						<source>1.5</source>
						<target>1.5</target>
					</configuration>
				</plugin>
				<plugin>
					<groupId>org.apache.maven.plugins</groupId>
					<artifactId>maven-resources-plugin</artifactId>
					<configuration>
						<encoding>UTF-8</encoding>
					</configuration>
				</plugin>
				<plugin>
				    <groupId>org.apache.maven.plugins</groupId>
				    <artifactId>maven-source-plugin</artifactId>
				    <version>2.1.1</version>
				    <executions>
				        <execution>
				            <id>attach-sources</id>
				            <phase>verify</phase>
				            <goals>
                                <goal>jar-no-fork</goal>
				            </goals>
				        </execution>
				    </executions>
				</plugin>
			</plugins>
		</pluginManagement>
	</build>
</project>
```
这里的dependencyManagement和pluginManagement声明的依赖既不会给account-parent引入依赖和插件配置，也不会给它的子模块引入这些声明，但是这段配置会被继承，当子模块声明了在父POM文件里声明的构件和插件，这时就可以避免一些重复的配置，这样可以在父POM中使用dependencyManagement和pluginManagement的配置可以统一继承项目的依赖版本和插件版本的参数。如果子模块不声明相关的配置那么也不会产生任何实际效果。同时，子模块还可以自定义一些在父POM中已经声明了的构件，可以覆盖在父POM中定义的配置。以下是一个子模块POM的例子：
```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
	<modelVersion>4.0.0</modelVersion>
	
	<parent>
		<groupId>com.juvenxu.mvnbook.account</groupId>
		<artifactId>account-parent</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../account-parent/pom.xml</relativePath>
	</parent>
	
	<artifactId>account-persist</artifactId>
	<name>Account Persist</name>

  <properties>
  	<dom4j.version>1.6.1</dom4j.version>
  </properties>

	<dependencies>
		<dependency>
			<groupId>dom4j</groupId>
			<artifactId>dom4j</artifactId>
			<version>${dom4j.version}</version>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-core</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-beans</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-context</artifactId>
		</dependency>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
		</dependency>
	</dependencies>

	<build>
	    <plugins>
	        <plugin>
	            <groupId>org.apache.maven.plugins</groupId>
	            <artifactId>maven-source-plugin</artifactId>
	        </plugin>
	    </plugins>
		<testResources>
			<testResource>
				<directory>src/test/resources</directory>
				<filtering>true</filtering>
			</testResource>
		</testResources>
	</build>
</project>
```
在上例子模块中不声明依赖的使用，即使该依赖已经在父POM的dependencyManagement中声明了，也不会产生任何实际的效果。从上例中看出这种管理机制不能减少太多的POM配置，但是还是推荐使用这种方法。其主要原因在于父POM中使用dependencyManagement声明依赖能够统一项目范围中依赖的版本，当依赖版本在父POM中声明之后，子模块在使用依赖的时候就无须声明版本，也就不会发生多个子模块使用依赖版本不一致的情况。对于插件的继承当子模块中声明插件的groupId和artifactId与pluginManagement中配置的插件匹配时，pluginManagement的配置才会影响实际的插件行为。如果子模块不需要使用父模块中pluginManagement配置的插件，可以尽管将其忽略。如果子模块需要不同的插件配置，则可以自行配置以覆盖父模块的pluginManagement配置。当项目中的多个模块有同样的插件配置时，应当将配置移到父POM的pluginManagement元素中。即使各个模块对于同一插件的具体配置不尽相同，也应该使用父POM的pluginManagement元素统一声明插件的版本。甚至可以要求将所有用到的插件的版本在父POM的pluginManagement元素中声明，子模块使用插件时不配置版本信息，这么做可以统一项目的插件版本，避免潜在的插件不一致或者不稳定问题，也更容易维护。

##### 聚合和继承的关系

1. 对于聚合模块来说，它知道有哪些被聚合的模块，但那些被聚合的模块不知道这个聚合模块的存在。
2. 对于继承关系的父POM来说，它不知道有哪些子模块继承于它，但那些子模块都必须知道自己的父POM是什么。
3. 如果非要说这两个特性的共同点，那么可以看到，聚合POM与继承关系中的父POM的packing都必须是pom，同时，聚合模块与继承关系中的父模块除了POM之外都没有实际的内容。

##### 反应堆
在一个多模块的Maven项目中，反应堆(Reactor)是指所有模块组成一个构建结构。对于单模块的项目，反应堆就是该模块，但对于多模块的项目来说，反应堆就包含了各模块之间继承与依赖的关系，从而能够自动计算出合理的模块构建顺序。实际的构建顺序是这样形成的：Maven按序读取POM，如果该POM没有依赖模块，那么就构建该模块，否则就先构建其依赖模块，如果该依赖还依赖与其他模块，则进一步先构建依赖的依赖。

### 使用Maven进行测试
Maven本身并不是一个单元测试框架，Java世界中主流的单元测试框架为JUnit(http://www.junit.org/)和TestNG(http://testng.org)。Maven所做的只是在构建执行到特定生命周期阶段的时候，通过插件来执行JUnit或者TestNG的测试用例。这一插件就是maven-surefire-plugin，可以称之为测试运行器(Test Runner)，它能很好地兼容JUnit3、JUnit4以及TestNG。  
我们知道，生命周期阶段需要绑定到某个插件的目标才能完成真正的工作，test阶段正是与maven-surefire-plugin的test目标相绑定了，这是一个内置的绑定。在默认情况下，maven-surefire-plugin的test目标会自动执行测试源码路径(默认为src/test/java/)下所有符合一组命名模式的测试类。这组模式为:
* \*\*/Test\*.java：任何子目录下所有命名以Test开头的Java类。
* \*\*/\*Test.java：任何子目录下所有命名以Test结尾的Java类。
* \*\*/\*TestCase.java：任何子目录下所有命名以TestCase结尾的Java类。
只要将测试类按上述模式命名，Maven就能自动运行它们，用户也就不再需要定义测试集合(TestSuite)来聚合测试用例(TestCase)。要注意的是以Tests结尾的测试类是不会自动执行的。  

##### 跳过测试
* Maven跳过测试运行：`mvn package -DskipTests`
* Maven跳过测试运行和测试代码的编译：`mvn package -Dmaven.test.skip=true`
* 指定执行要运行的测试用例：`mvn test -Dtes=RandomGeneratorTest` 这里test参数的值是测试用例的类名，这行命令的效果就是只有RandomGeneratorTest这一个测试类得到执行。
* 在指定测试用例的时候可以使用通配符`*`和`,`,星号可以匹配零个或多个字符，使用逗号指定多个测试用例。`mvn test -Dtest=Random*Test,AccountCaptchaServiceTest`,test参数的值必须匹配一个或者多个测试类，如果maven-surefire-plugin找不到任何匹配的测试类，就会报错并导致构件失败，可以加上-DfailNoIfTests=false，告诉maven-surefire-plugin即使没有任何测试也不要报错:`mvn test -Dtest -DfailIfNoTests=false`

