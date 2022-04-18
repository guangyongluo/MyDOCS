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
stubbing是一种定义mock对象行为的方法，我们使用mockito来mock一个对象时，返回给我们的是一个原对象的CGlib代理，默认当我们调用这个CGlib代理对象有返回值的方法时都将返回null。我们可以通过在mock中使用Answer来改变这个默认行为。

1. when(mockobject.function()).thenReturn(result): stubbing一个mock对象的有参方法，返回方法定义的返回值；
2. when(mockojbect.function()).thenThrow(throwable): stubbing一个mock对象的有参方法，抛出异常；
3. doReturn(result).when(mockobject).function(): stubbing一个mock对象的有参方法，与第一种方式是一样的效果；
4. doNothing().when(mockobject).function(): stubbing一个mock对象的无参方法；
5. doThrow().when(mockobject).function(): stubbing一个mock对象的无参方法，抛出异常；
6. when(mockobject.function()).thenReturn(result1, result2, result3...): stubbing一个mock对象的有参方法，根据调用的次数返回相应的值；
7. when(mockobject.function()).thenReturn(result1).thenReturn(result2)... : 与上面的stubbing相同；
8. doReturn(result).doReturn(result).doReturn(result)...when(mockobject).function(): 与上面的stubbing相同；
9. when(mockobject.function()).thenAnswer(invocation -> {}): stubbing mock对象方法返回值可以根据方法签名和参数来进行一定的逻辑处理得到最总的返回值；
10. when(mockobject.function()).thenCallRealMethod(): stubbing 调用mock对象中原对象中的方法。

##### 如何 spying

当spying一个对象时，它的作用是与mock相反的，每次你对spying对象的方法调用都是真实的方法，只有stubbing该对象的方法时，才会返回stubbing的结果。使用spy将对mock对象的部分方法做stubbing。

1. spy(mockojbect): spying一个真实对象，生成一个mock对象；
2. @spy: 同上面的方法效果一样

##### Mockito Argument Matcher

1. Mockito的Argument Matcher在stubbing一个mock对象方法中主要用于针对不同的参数返回不一样的结果；
2. 在stubbing一个mock对象方法时传递了一个参数，那么在调用mock对象的stubbing方法时，必须传递一样的参数才能放回与之对应的结果；
3. Mockito Argument Matcher在校验stubbing方法参数时使用的原生Java Object的equals方法去比较参数，如果需要可以重写equals方法但不建议这样干；
4. 除此之外，Mockito Argument Matcher提供了内建的一些Matchers比如：anyString(), anyInt(), anyCollection()等，可以使参数校验更加灵活；
5. 需要注意isA(Class clazz), any(Class clazz)和eq(primitive value)区别
6. Wildcard Matcher: 当调用stubbing方法的参数不是一个确定值时，可以使用Wildcard Matcher比如anyString(), anyInt(), anyCollection()等；

##### Mockito WildCard Matcher

当stubbing一个mock对象的方法时，我们可以使用wildcard通配所有的参数，有一点需要注意的是当使用了wildcard去通配任何方法参数时，其他的方法参数必须使用wildcard去通配，所以当你使用wildcard时需要使其中的某个参数使用具体的值，那就需要使用eq()方法将这个具体值包装起来，可以满足一些特殊子级的stubbing需要：
```
when(simpleService.method1(anyInt(), anyString(), anyCollection(), isA(Serializable.class)))
  .thenReturn(-1);
when(simpleService.method1(anyInt(), eq("luo"), anyCollection(), isA(Serializable.class)))
  .thenReturn(100);
when(simpleService.method1(anyInt(), eq("wei"), anyCollection(), isA(Serializable.class)))
  .thenReturn(100);
```
如上例子中所示，只能将通配的范围从大到小stubbing，否则如果将范围大的通配在最后stubbing的话将覆盖之前左右的stubbing。

##### Hamcrest Matcher

Hamcrest提供了一个Matcher工具集合核心类(org.hamcrest.CoreMatchers)，在这个类中包含了很多的match方法：allOf, anyOf, both, either, describedAs, everyItem, is, isA, anything, hasItem, hasItems, equalTo, any, instanceOf, not, nullValue, notNullValue, sameInstance, and theInstance。同时也包含了对字符串进行比较的match方法：startsWith, endsWith, and containsString。还有对Number及其继承类的match方法：greaterThan, lessThan, greaterThanOrEqualTo, lessThanOrEqualTo

##### Verify

在单元测试过程中，需要对哪些方法的调用和方法调用次数进行verify是一个有意义的需求。一般我们需要mock的对象是当我们需要进行测试的方法引入了第三方复杂对象，我们对该复杂对象进行mock和stubbing该对象的行为。在某些测试场景中，我们不需调用mock对象的方法或者我们需要调用多次mock对象的方法，同时我们需要验证这些调用行为是否符合预期，Mockito不会自动验证这些调用行为，所以我们需要使用verify去验证这些行为。

1. verify(mockObject, times(number)).method(parameter): 验证mock对象的方法调用的次数；
2. verify(mockObject, atLeastOnce(number)).method(parameter): 验证mock对象的方法最少调用一次；
3. verify(mockObject, atLeast(number)).method(parameter): 验证mock对象的方法最少调用的次数；
4. verify(mockObject, atMost(number)).method(parameter): 验证mock对象的方法最多调用的次数；
5. verify(mockObject, only(number)).method(parameter): 验证mock对象的所有方法有且只调用一次；
6. verifyNoMoreInteractions(mockObject): 验证mock对象之前多有调用的方法都已经被verify验证了；

##### ArgumentCaptor

一个ArgumentCaptor对象用来验证传递给mock方法的参数，想象一个场景当我们传递了一个对象给一个mock方法，这个方法对这个对象里面的属性做了一下修改，但是我们没有返回这个对象，我们怎么验证这个对象属性的修改呢？这时我们就需要ArgumentCaptor对象来捕获传递给mock方法的参数，并且验证这个对象的属性改变。
