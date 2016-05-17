# LaunchScreenTest
常见的几种启动图风格
-----
-----
- **静态图类型** ：微信
![微信.gif](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu01.gif)
<!-- more -->
- **图片不变，有动画效果** ：京东


![京东.gif](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu02.gif)
- **随着节日或者时间动态更换的** ：百度云、网易公开课

![网易公开课](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu03.gif)|![百度云.gif](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu04.gif)
**注意：笔者说的启动图并不是广告页，启动图是不接受点击事件的，但是广告页是接受点击事件的，点击后一般会跳转到网页。如下：**
![有道词典.gif](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu05.gif)

这几种风格的启动图怎么实现的？
-----
-----

- **静态图类型** ：这种比较简单，开发者可以使用`LaunchImage`和`LaunchScreen.storyboard`的任何一种方式添加所需的正确格式的图片，但是在使用的过程中需要注意的事项，读者可以看我的这篇文章[LaunchImage和LaunchScreen.xib混用出现的坑](http://www.jianshu.com/p/fb70d15b50d8)

- **图片不变，有动画效果** ：这种方式，笔者认为在实现方式上和第三种是一样的，就不在赘述，感兴趣的读者在看完第三种实现方式后，可以尝试去做。

- **随着节日或者时间动态更换的** ：这种方式，也就是笔者今天着重要讲的，原理及实现方式。

***像百度云或者网易公开课一样动态换APP启动图原理***
- **其实你看到的不是一张图片** ：读者仔细观察就会发现，使用这种方式的的启动图，用的不是一张图片，而是两张。我们拿百度云来举例：
![1.pic.jpg](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu06.jpg)
![2.pic.jpg](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu07.jpg)
可以看到，两张图片的区别就是，底部都是一样的，而第一张上半部分是空白。其实，网易公开课和支付宝德也是如此。`第一张图片是内容兼容性很强的图片，就是一个版权说明加上一个类似于app logo的样式，上面空白部分可以根据节日的不同，调整展示的样式`
- **这两张图片还有其他的不同吗** ：因为笔者经常使用这几款app，发现有的时候第二张图片是不显示的，显示完第一张图片直接跳到app主页了。笔者认为，第一张图片就是放在[LaunchImage或者LaunchScreen.xib中的图片，是不会改变的。第二张图片则是从网上获取的，而且可以根据是否获取到相应的图片网址决定第二张图片能否显示。
- **为什么要这么做** ：有的读者可能有疑问，为什么要这么做？难道不可以直接更换掉第一张启动图吗，或者不显示第一张只显示第二张？答案：NO!
 * 更换第一张图片？抱歉，更换不了，如果你使用的是LaunchScreen.xib或者LaunchScreen.Storyboard,只要你的app启动过，那张图片就永远的缓存在app里了，以后每次启动都会出现。我的这篇简书讲过这个问题[LaunchImage和LaunchScreen.xib混用出现的坑](http://www.jianshu.com/p/fb70d15b50d8)
 * 网络请求有延时，如果不放第一张图片，只放第二张图片，会出现短暂的黑屏。
 * 从产品的角度来讲，也不合理。比如：植树节的时候我展示了和环保有关的内容，如果过了植树节，那么正常情况下我不展示该内容就可以了，后台不返回相应的图片网址，展示完第一张图片就ok了。如果没有第一张图片，那么过了植树节，我就需要把网址更换，需要一个下载图片的过程，从用户体验来讲也不好，时间延迟也会浪费流量。


 **关于猜测的一点验证？**
* 为了验证自己的猜想，笔者使用抓包工具[青花瓷](http://www.charlesproxy.com)进行了抓包，抓包的方式可以参考[iOS使用Charles（青花瓷）抓包并篡改返回数据图文详解.](http://www.codes51.com/article/detail_147595.html)
* 笔者抓的是`百度云`的包，我们先来看第一张截图


![屏幕快照 2016-04-12 下午6.25.55.png](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu08.png)
这是一个post的请求方式，可以看到在url路径中，有image/diff这段，笔者判断这段路径返回 的参数是用来决定是否更换第二张图片的
* 我们再来看第二张截图
![屏幕快照 2016-04-12 下午6.26.19.png](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu09.png)
紧接着第一次网络请求，就进行了这次网络请求，我们在path路径下可以看到app.gif,笔者认为这个网址就是图片的地址，百度云的第二张图片有动画效果，笔者猜测可能是gif格式的图片


____
代码怎么实现这种启动图方式?
-----
-----

 * 第一张图片使用LaunchScreen.Storyboard方式
  *  这一步相信读者都会，笔者就不再赘述
 *  第二张图片如何展示
  * 第一步就是进行一次网络请求，判断有没有相应的图片网址，没有的话就就不显示，有的话拿到图片的网址进行第二次网络请求
  * 请求下来图片后，笔者参考[通过LaunchScreen自定义启动动画](http://www.jianshu.com/p/2f1149269cd0)实现启动图更换图片，而且可以给启动图添加动画效果
** 这一步是获取LaunchScreen.storyboard里的UIViewController,UIViewController 的identifer是LaunchScreen**
```objective-c
UIViewController *viewController = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    UIView *launchView = viewController.view;
    UIImageView  * Imageview= [[UIImageView  alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [launchView addSubview:Imageview];
    [self.view addSubview:launchView];
```
** 这一步是获取上次网络请求下来的图片，如果存在就展示该图片，如果不存在就展示本地保存的名为test的图片**
```objective-c
NSMutableData * data = [[NSUserDefaults standardUserDefaults]objectForKey:@"imageu"];
    if (data.length>0) {
         Imageview.image = [UIImage imageWithData:data];
    }else{
    
     Imageview.image = [UIImage imageNamed:@"Test"];
    }
```
** 下面这段代码，是调用AFN下载文件的方法，异步方式下载，但是在这里异步方式下载有一个问题，就是这次下载完成的图片，下次启动时才会展示，读者可以换成同步的，但是同步下载会有时间延迟，用户体验不好，下载完图片后，将图片以二进制的形式存在本地，笔者用的是userdefault,这是不科学的，读者可以存在其他文件夹，**
```objective-c
NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"http://s16.sinaimg.cn/large/005vePOgzy70Rd3a9pJdf&690"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
        
        NSData * image = [NSData dataWithContentsOfURL:filePath];
        [[NSUserDefaults standardUserDefaults]setObject:image forKey:@"imageu"];
 }];
    [downloadTask resume];
```
* 笔者在展示完第二张图片后，又添加了展示广告位的代码，这样就是app启动时比较完整的过程了。

** 这段代码，可以实现第二张图片有3D的动画效果，动画结束后，进行同步的网络请求，请求的是广告页图片，之所以用同步的是因为，如果用同步的话主页面显示后，图片才会加载完成显示。**
```objective-c
 [UIView animateWithDuration:6.0f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        //launchView.alpha = 0.0f;
        launchView.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5f, 1.5f, 1.0f);
    } completion:^(BOOL finished) {
     
     
                NSString * ad_imgUrl  = @"http://www.uimaker.com/uploads/allimg/121217/1_121217093327_1.jpg";
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [BBLaunchAdMonitor showAdAtPath:ad_imgUrl
                                         onView:appDelegate.window.rootViewController.view
                                   timeInterval:5
                               detailParameters:@{@"carId":@(12345), @"name":@"奥迪-品质生活"}];
                   [launchView removeFromSuperview];
    }];
```
***demo效果***

![demo.gif](http://7xu0fw.com1.z0.glb.clouddn.com/LaunchScreenModleBaidu10.gif)
####总结：
这是笔者的实现过程，希望可以给读者一点思路，如果读者觉得有什么不明白的，或者有更好的方式，希望能联系笔者，或者在评论中给出建议。


