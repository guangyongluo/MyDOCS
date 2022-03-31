### 使用 Mockito&PowerMock 做好单元测试

##### 一个好的单元测试必须具备的特征

1. 单元测试是可以自动执行的，**自动化单元测试**；
2. 单元测试执行速度要足够快，**快速得到反馈结果**；
3. 单元测试不应该依赖其他的单元测试，同时单元测试也不应该依赖执行顺序，**可以独立无序地执行**；
4. 单元测试不应该依赖数据库、文件、网络连接等**外部资源**；
5. 单元测试应该是时间和空间上透明的，**可以在任何时间、任何环境执行**；
6. 单元测试应该是有意义的，**不应该纯粹为了覆盖率而硬凑测试用例**；
7. 单元测试不应该被当成二等公民，**需要和源代码一样认真对待**。

##### 测试替身（Test Double）

当在项目中的单元测试用例依赖的外部资源时，我们经常因为环境原因或者性能原因阻碍了我们的单元测试。这时我们需要引入 Test Double 测试替身，Test Double 不必和真实的依赖组件的实现一模一样，比如不用去实现依赖组件复杂的内部逻辑等。我们只需要在满足测试需求范围内，确保对于待测系统来说 Test Double 提供的 API 是和依赖组件提供的一样的即可满足测试需求。对于 Test Double 的细分：

1. Test Stub - Test Stub 是指一个完全代替待测系统依赖组件的对象，这个对象按照我们设计的输出与待测系统进行交互，可以理解是在待测系统内部打的一个桩。
2. Mock Object - Mock Object 是指一个完全代替待测系统依赖组件，并且用于验证待测系统输出的对象。
3. Fake Object - Fake Object 是指一个轻量级的完全代替待测系统依赖组件的对象，采用更加简单的方法实现依赖组件的功能。
4. Test Spy - Test Spy 是指一个待测系统依赖组件的替身，并且会捕捉和保存待测对象对依赖系统的输出，这个输出会用于测试代码中的验证。
5. Dummy Object - Dummy Object 对象是指为了调用被测试方法而传入的假参数，为什么说是假参数呢？实际上这些传入的 Dummy 对象并不会对测试有任何作用，仅仅是为了成功调用被测试方法。

##### 如何在 Junit 中使用 Mockito 来 mock 对象

1. 使用 RunWith 注解 @Runwith(MockitoJUnitRunner.class) 和 Mockito.mock()方法来 mock 对象
2. 使用 Rule 注解 @Rule public MockitoRule mockito = MockitoJUnit.rule() 和 Mockito.mock()方法来 mock 对象
3. 将 MockitoAnnotations.openMocks(this)方法放在@Before 方法里和@Mock 注解来 mock 对象

##### 如何 stubbing

1. when(mockobject.function()).thenReturn(result): stubbing一个mock对象的有参方法，返回方法定义的返回值；
2. when(mockojbect.function()).thenThrow(throwable): stubbing一个mock对象的有参方法，抛出异常；
3. doReturn(result).when(mockobject).function(): stubbing一个mock对象的有参方法，与第一种方式是一样的效果；
4. doNothing().when(mockobject).function(): stubbing一个mock对象的无参方法；
5. doThrow().when(mockobject).function(): stubbing一个mock对象的无参方法，抛出异常；
6. when(mockobject.function()).thenReturn(result1, result2, result3...): stubbing一个mock对象的有参方法，根据调用的次数返回相应的值；
7. when(mockobject.function()).thenReturn(result1).thenReturn(result2)... : 与上面的stubbing相同；
8. doReturn(result).doReturn(result).doReturn(result)...when(mockobject).function(): 与上面的stubbing相同；
9. 

