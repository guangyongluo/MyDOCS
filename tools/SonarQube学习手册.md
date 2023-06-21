# SonarQube与Maven和Jenkins集成

------

### Analyzing source code

SonarQube支持29种不同的语言分析，SonarScanner的输出是代码质量分析数据，具体分析需要根据特定的语言来判断：

- 所有语言都会添加SCM的支持，默认支持Git和SVN，如果需要对其他的SCM支持需要提那家额外的插件；
- 所有语言都会执行静态代码分析(Java files, COBOL programs, etc)
- 对于特定语言，静态分析根据编译后的代码(.class files in Java, .dll files in C#, etc)

一般情况下根据你的SonarQube的版本来支持哪些文件被分析，比如你是社区版那所有的.java和.js会被分析，但是.opp将会被忽略。开发者版将会自动的分析你的项目的所有brancher和pull requests。



### SonarScanner For Maven

SonarScanner被指定为Maven项目的默认扫描器，无需手动地下载和安装可以通过Maven goal指令来执行SonarQube的扫描分析，在Maven的构建中已经包含了很多可用于SonarQube分析代码的信息，这样通过少量的人工配置就可以使用SonarQube来扫描分析代码。

可以为SonarQube设置全局环境变量，编辑在Maven根目录下的conf/setting.xml文件

```xml
<settings>
    <pluginGroups>
        <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
    </pluginGroups>
    <profiles>
        <profile>
            <id>sonar</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <properties>
                <!-- Optional URL to server. Default value is http://localhost:9000 -->
                <sonar.host.url>
                  http://myserver:9000
                </sonar.host.url>
            </properties>
        </profile>
     </profiles>
</settings>
```

分析Maven项目中的源代码在项目根目录下执行Maven goal:sonar:sonar，同时需要传递一个证书令牌：

```sh
mvn clean verify sonar:sonar -Dsonar.login=myAuthenticationToken
```

如果需要替换SonarScanner的分析参数，可以在pom.xml的properties部分指定

```xml
<properties>
  <sonar.buildString> [...] </sonar.buildString>
</properties>
```

排除项目中的module不让SnonarQube分析

- 在pom.xml文件中指定property`<sonar.skip>true<sonar.skip>`可以使当前模块不被SonarScanner扫描；
- 使用build profiles排除一些模块（类似于集成测试）；
- 使用高级反映器选项（例如：`-pl`）. 参考一个例子`mvn sonar:sonar -pl !module2`

怎样保持整个项目Sonar插件的版本一致，这样在parent pom.xml中定义的Sonar版本可以在子pom.xml被继承：

```xml
<build>
  <pluginManagement>
    <plugins>
      <plugin>
        <groupId>org.sonarsource.scanner.maven</groupId>
        <artifactId>sonar-maven-plugin</artifactId>
        <version>3.7.0.1746</version>
      </plugin>
    </plugins>
  </pluginManagement>
</build>
```



### Jenkins extension for SonarQube

这个Jenkins插件可以配置SonarQube server链接的全局变量，使用Jenkins的pipeline触发SonarQube的代码扫描，一旦Jenkins job运行完成，插件将发现SonarQube分析结束，会在job运行结果列表右上角会出现sonarqube的小图标，可以链接到SonarQube仪表盘和quality gate status。在Jenkins Update Center中可以安装Jenkins SonarQube Extension。



##### 使用Maven分析Java项目

- 全局配置：
  1. 使用admiinistrator登入Jenkins，去到Jenkins > Configure System;
  2. 下拉到SonnarQube servers部分，开启把SonarQube server配置注入到build环境变量。
- Job配置：
  1. 到Build Environment部分配置环境变量；
  2. 开启Prepare SonarScanner environment使SonarQube servers可以注入值到这个特定的Job，如果Jenkins中有多个SonatQube实例，需要选择一个实例。一旦环境变量被设置，将Goals绑定到标准Maven构建步骤上就可以使用他们。



##### 使用Jenkins pipeline

Jenkins插件提供了一个withSonarQubeEnv块允许你选择一个SonarQube server连接，这个连接细节配置在Jenkins global configuration中，将会自动的传递给scanner。你需要传一个credentialsId和一个SonarQube的server name。



### Test coverage

测试覆盖率报告和测试执行报告是一个重要的衡量你的代码质量的指标，测试覆盖率指的是有多少代码被测试用例覆盖，测试执行指的是测试用例运行的情况和结果，SonarQube本身不计算覆盖率，需要第三方覆盖率的工具生成报告，导入SonarQube来分析你的代码。



##### 一般指导原则

为了加入覆盖率分析，你需要做下面的这些准备：

1. 配置代码测试覆盖率工具作为你popeline的一部分，而且生成结果的报告需要在SonarScanner之前；
2. 配置代码测试覆盖率工具生成的报告的位置和格式必须符合SonarScanner要求；
3. 配置SonarScanner分析参数使其能导入测试报告；

### Java test coverage

SonarQube支持Java测试用例的分析，然而SonarQube不生产覆盖率报告，需要配置一个第三方工具去生成报告，接下来需要配置SonarQube测试用例报告生成的位置，发送测试报告到SonarQube，这些测试报告中的结果将和其他的指标一起展示在仪表盘中。SonarQube直接支持JaCoCo覆盖率工具。

##### 调整你的构建

- 调整你的构建流程确保JaCoCo的报告生成在SonarScanner扫描之前；
- 确保JaCoCo写入指定的构建环境的路径；
- 配置扫描阶段使SonarScanner可以提取到测试报告文件。

##### 在单独Maven项目中添加覆盖率

去添加覆盖率你需要使用jacoco-maven-plugin它的report goal生成一个覆盖率报告，通常，你可能需要创建一个指定Maven profile和指定说明来生成覆盖率报告，在很多例子中，我们需要执行两个goal：jacoco:prepare-agent它允许收集单元测试执行的覆盖率结果，jacoco:report它使用收集的数据结果生成测试覆盖率报告。默认情况下，这个工具生成XML，HTML和CSV的报告，SonarQube只分析XML的报告。这个profile部分看起来像这样：

```xml
<profile>
  <id>coverage</id>
  <build>
   <plugins>
    <plugin>
      <groupId>org.jacoco</groupId>
     <artifactId>jacoco-maven-plugin</artifactId>
      <version>0.8.7</version>
      <executions>
        <execution>
          <id>prepare-agent</id>
          <goals>
            <goal>prepare-agent</goal>
          </goals>
        </execution>
        <execution>
          <id>report</id>
          <goals>
            <goal>report</goal>
          </goals>
          <configuration>
            <formats>
              <format>XML</format>
            </formats>
          </configuration>
        </execution>
      </executions>
    </plugin>
    ...
   </plugins>
  </build>
</profile>
```

默认情况下，生成的报告放在target/site/jacoco/jacoco.xml。这个位子上的覆盖率报告会自动被scanner扫描。

##### 在一个多个模块的Maven项目中添加覆盖率

对于一个包含多个模块的Maven项目，你配置jacoco-maven-plugin在父pom中就像在上面单个的模块中那样，默认情况下，每个模块生成单个的覆盖率报告，如果你想生成所有的模块覆盖率报告到一个项目级别报告里面，一个最简单方式就是创建一个指定的Maven module，这个module中只包含一个pom.xml使用report-aggregate goal，以下是可以参考的例子：

```xml
<project>
  <artifactId>my-project-report-aggregate</artifactId>
  <name>My Project</name>
  <description>Aggregate Coverage Report</description>
  <dependencies>
    <dependency>
      <groupId>${project.groupId}</groupId>
      <artifactId>my-module-1</artifactId>
      <version>${project.version}</version>
    </dependency>
    <dependency>
      <groupId>${project.groupId}</groupId>
      <artifactId>my-module-2</artifactId>
      <version>${project.version}</version>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.jacoco</groupId>
        <artifactId>jacoco-maven-plugin</artifactId>
        <executions>
          <execution>
            <id>report-aggregate</id>
            <phase>verify</phase>
            <goals>
              <goal>report-aggregate</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
```

当你在这个新建的目录下调用`mvn clean verify`将会生成集成的报告并且替换掉默认位子上的文件target/site/jacoco-aggregate/jacoco.xml。



