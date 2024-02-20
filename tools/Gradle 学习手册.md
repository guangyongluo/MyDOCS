# Gradle 学习手册



Gradle是一种Java项目的构建工具，现在越来越多的项目使用Gradle构建，Spring官方已经使用Gradle来构建Spring的项目，为什么有了Maven我们还需要使用Gradle呢？其实Maven相对于Gradle侧重于项目依赖的管理，而Gradle使用Groovy脚本使得构建过程更加灵活，而且Gradle的构建性能比Maven要快得多，所以对于大型项目来讲Gradle则更加适合。以下是Maven和Gradle的比较：

|        | 优点                                                         | 缺点                                                         |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Maven  | 遵循一套约定大于配置的项目结构，使用统一的GAV坐标进行依赖管理，侧重于包管理 | 项目构建过程僵化，配置文件编写不够灵活、不方便自定义组件，构建速度慢于Gradle |
| Gradle | 借鉴Ant脚本的灵活性和Maven约定大于配置的项目目录结构的优点，支持多远程仓库和插件，侧重于大项目构建 | 学习成本高，资料少、脚本灵活，版本兼容性差等                 |



### 1. Gradle常用命令

|    Gradle常用命令    |            作用            |
| :------------------: | :------------------------: |
|     gradle clean     |       清空build目录        |
|    gradle classes    |   编译业务代码和配置文件   |
|     gradle test      | 编译测试代码，生成测试报告 |
|     gradle build     |          构建项目          |
| gradle build -x test |      跳过测试构建项目      |



### 2. Gradle常用的配置

- init.d文件夹：在Gradle的安装目录中，有个init.d目录，在这个目录下可以创建以多个.gradle结尾的文件，这些文件实现在build开始之前执行你需要的构建步骤。

  ```groovy
  allprojects {
      buildscript {
          repositories {
              maven { name "alibaba"; url 'https://maven.aliyun.com/repository/public/' }
              maven { name "google"; url 'https://maven.aliyun.com/repository/google/' }
          }
      }
  
      repositories {
          mavenLocal()
          maven { name "alibaba"; url 'https://maven.aliyun.com/repository/public/' }
          maven { name "google"; url 'https://maven.aliyun.com/repository/google/' }
          mavenCentral()
      }
  
      println "${it.name}: Aliyun maven mirror injected"
  }
  
  ```

  