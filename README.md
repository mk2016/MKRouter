# MKRouter
#### 在 [HHRouter](https://github.com/lightory/HHRouter) 的基础上做的二次开发。根据业务和实际需求做一定的改造。

由于 HHRouter 只是给出了个统跳协议的解决方案，但在实际应用中还是有很多问题需要自己解决。比如push到下一个界面后，pop回来时想带处理结果回来；比如想在block执行完后添加执行结果的回调；比如在webView内调用了一个打开webView路由；比如从外部打开APP跳到指定界面 等等。

根据应用场景，在HHRoute上做了一定的扩展，并添加了一个RouterHelper, 提供统一简单的入口，一行代码执行统跳路由。

已经在自己的项目中使用的很长时间，并不断优化，觉得应该还算完善，因此抽空整理出来。
由于有些部分和业务有些关联，也不想demo弄的太复杂，主要把重要的统跳路由整理出来，至于 webView内的处理 和 外部打开的部分，大家可以在这基础上自己扩展。


## URI
#### URI:统一跳转协议
为了规范客户端与js之间的互操作行为、开放客户端界面功能，定义客户端的URI统一跳转协议。

```
     foo://example.com:8042/over/there?name=ferret#nose
     \_/   \______________/\_________/ \_________/ \__/
      |           |            |            |        |
   scheme     authority       path        query   fragment
      |   _____________________|__
     / \ /                        \
     urn:example:animal:ferret:nose
```

协议格式为：

```
 	scheme://authority[/path][?param=xxx]
```
* 例1：（无query ）	 
```
mkapp://vc/red 				
```		
	其中 scheme 在app内可忽略，但是在WebView中 和 从app外部打开app指定界面时必须有。
	
* 例2：（带query ）	
当需要带参数时，比如userId＝1234&&mode＝1 ，则创建JSON｛"userId":1234,"mode":1｝进行encode，然后将这个值拼接到"param="的后面。
```
mkapp://vc/red?param=%ef%bd%9b%22userId%22%3a1234%2c%22mode%22%3a1%ef%bd%9d
```
* 例3：	
```
	注册 router : mkapp://vc/red/:userid 
```
```		
	使用 mkapp://vc/red/1234?
	param=%ef%bd%9b%22userId%22%3a1234%2c%22mode%22%3a1%ef%bd%9d
```

## MKRouterHelper


