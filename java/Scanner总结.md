###  Java文本扫描Scanner总结
概念：Scanner是Java util包中一个强大的文本扫描工具，它可以使用正则表达式来读取文本中的内容，同时提供了很多方法来读取文本中的Java原生类型或String类型。

##### next()方法和nextLine()方法的使用
使用：在使用Scanner的时候，要注意使用所有的next的方法默认都是使用Java的空白字符作为分隔符的，请看下面的代码：
```
public class ScannerTest {

	public static void main(String[] args) {
		Scanner scanner = new Scanner(System.in);
		//读入第一行字符串
		String next1 = scanner.next();
		System.out.println(next1);
		//读入第二行字符串
		String next2 = scanner.next();
		System.out.println(next2);
		
		System.out.println("next()方法结束");
		
		String nextLine = scanner.nextLine();
		System.out.println(nextLine);
		
		System.out.println("nextLine()方法结束");
		
		System.out.println("Java Scanner默认使用的分割符为：" + scanner.delimiter());
		System.out.println("\\p{javaWhitespace}+等效于 java.lang.Character.isWhitespace()");
		scanner.close();
	}
	
}
```
输出结果为：
```
hello world
hello
world
next()方法结束

nextLine()方法结束
Java Scanner默认使用的分割符为：\p{javaWhitespace}+
\p{javaWhitespace}+等效于 java.lang.Character.isWhitespace()
```
从结果中可以看出，next()在扫描文本时是使用的Java的空白字符进行分割的，在next()方法扫描完有效字符时扫描的游标就会停止。所以最后一个nextLine就读到了一个回车换行就结束了。
而nextLine()方法会返回回车换行之前的所有字符，并将游标重置到新的文本开始出，也就是说nextLine方法将游标重置到读取文本行的换车换行符后面。
