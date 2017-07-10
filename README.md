# MKRouter
#### 在 [HHRouter](https://github.com/lightory/HHRouter) 的基础上做的二次开发。根据业务和实际需求做一定的改造。

由于 HHRouter 只是给出了个统跳协议的解决方案，但在实际应用中还是有很多问题需要自己解决。比如push到下一个界面后，pop回来时想带处理结果回来；比如想在block执行完后添加执行结果的回调；比如在webView内调用了一个打开webView路由的处理；比如从外部打开APP跳到指定界面 等等。

根据应用场景，在HHRoute上做了一定的扩展，并添加了一个RouterHelper, 提供统一简单的入口，一行代码执行统跳路由。

已经在自己的项目中使用的很长时间，并不断优化，觉得应该还算完善，因此抽空整理出来。
由于有些部分和业务有些关联，也不想demo弄的太复杂，主要把重要的统跳路由整理出来，至于 webView内的处理 和 外部打开的部分，大家可以在这基础上自己扩展。


## URI
#### URI: Uniform Resource Identifier 
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

#### format：

```
    scheme://authority[/path][?param=xxx]
```
## Usage
###### 具体参考Demo
#### Register Route
```
//viewController
    [[MKRouter sharedInstance] map:kRoute_vc_blue toControllerClass:[MKBlue_VC class]];
    [[MKRouter sharedInstance] map:kRoute_vc_red toControllerClass:[MKRed_VC class]];
    
//block    
    [[MKRouter sharedInstance] map:kRoute_block_alert toBlock:^id(id params) {
        NSLog(@"params: %@", params);
      	// === do someshing ====== //
      	
        MKBlock customBlock = [params objectForKey:kMKRouteCustomBlockKey];
        MKBlockExec(customBlock, @"block success");
        return params;
    }];
```
#### Exec Route
* route	
```
mkapp://vc/red 				
//其中 scheme 在app内可忽略，但是在WebView中 和 从app外部打开app指定界面时必须有。
```		
```
//  当需要带参数时，比如userId＝1234&&mode＝1 ，则创建JSON｛"userId":1234,"mode":1｝进行encode，然后将这个值拼接到"param="的后面。
mkapp://vc/red?param=%ef%bd%9b%22userId%22%3a1234%2c%22mode%22%3a1%ef%bd%9d
```	
```		
mkapp://vc/red/1234?param=%ef%bd%9b%22userId%22%3a1234%2c%22mode%22%3a1%ef%bd%9d
```

* MKRouterHelper 一行代码简单快速调用		
```
- (void)actionWithRoute:(NSString *)route
                  param:(id)param
                   onVC:(UIViewController *)currentVC
                  block:(MKBlock)block;
//例：             
 [[MKRouterHelper sharedInstance] actionWithRoute:route param:param onVC:self block:^(id result) {
	NSLog(@"back block : %@",result);
 }];
```
* route: 路由		
* param: 参数，可以转为json字符串的dictionary或model。		
* block: 回调。		
		block route 时，在执行完block的回调	
       viewController route 时，在pop 回来时执行的回调。
