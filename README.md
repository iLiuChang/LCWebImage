# LCWebImage
LCWebImage 是基于[AFNetworking](https://github.com/AFNetworking/AFNetworking)实现的轻量级异步图片加载框架，支持内存和磁盘缓存，同时提供了自定义缓存、自定义图片解码、自定义网络配置等功能。

默认不支持动画播放，如果需要支持动画可以实现自定义解码（比如[YYImage](https://github.com/ibireme/YYWebImage)）。

## 用法

### 加载图片

```objective-c
// UIImageView
[imageView lc_setImageWithURL:[NSURL URLWithString:@"https://xxx"]];

// UIButton
[button lc_setImageWithURL:[NSURL URLWithString:@"https://xxx"] forState:(UIControlStateNormal)];
```

### 自定义解码播放动画

使用[YYImage](https://github.com/ibireme/YYWebImage)实现自定义解码

```objective-c
// 自定义解码
[(LCAutoPurgingImageCache *)[LCImageDownloader defaultInstance].imageCache setCustomDecodedImage:^UIImage * _Nonnull(NSData * _Nonnull data, NSString * _Nonnull identifier) {
    return [[YYImage alloc] initWithData:data scale:UIScreen.mainScreen.scale];
}];
```

加载图片

```objective-c
YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
[imageView lc_setImageWithURL:[NSURL URLWithString:@"https://xxx"]];
```



注意: iOS 14 以上YYImage存在显示问题，需要修改`YYAnimatedImageView`源码如下：

```objective-c
- (void)displayLayer:(CALayer *)layer {
    // 修改的代码
    UIImage *currentFrame = _curFrame;
    if (currentFrame) {
        layer.contentsScale = currentFrame.scale;
        layer.contents = (__bridge id)currentFrame.CGImage;
    } else {
        // If we have no animation frames, call super implementation. iOS 14+ UIImageView use this delegate method for rendering.
        if ([UIImageView instancesRespondToSelector:@selector(displayLayer:)]) {
           [super displayLayer:layer];
        }
    }

    // 源码
//    if (_curFrame) {
//        layer.contents = (__bridge id)_curFrame.CGImage;
//    }
}

```

## 安装

### CocoaPods

1. 将 cocoapods 更新至最新版本;
2. 在 Podfile 中添加`pod 'LCWebImage'`;
3. 执行 `pod install` 或 `pod update`;
4. 导入` <LCWebImage/UIImageView+LCWebImage.h>`或 `<LCWebImage/UIButton+LCWebImage.h>`;
5. 注意: LCWebImage会自动导入第三方库`AFNetworking/NSURLSession`中的代码.

### 手动安装

1. 下载 LCWebImage 文件夹内的所有内容;
2. 将 LCWebImage 内的源文件添加(拖放)到你的工程;
3. 添加`AFNetworking/NSURLSession`代码.

## 系统要求

- **iOS 9.0+**
- **Xcode 11.0+**
- **AFNetworking 4.0+**

