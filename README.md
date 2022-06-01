# LCWebImage
LCWebImage is an asynchronous image loading framework based on [AFNetworking](https://github.com/AFNetworking/AFNetworking), which supports memory and disk caching, and provides functions such as custom caching, custom image decoding, and custom network configuration. 

Animation playback is not supported by default. If you need to support animation, you can implement custom decoding (such as [YYImage](https://github.com/ibireme/YYWebImage)).

## Requirements

- **iOS 9.0+**
- **Xcode 11.0+**
- **AFNetworking 4.0+**

## Usage

### Load image

```objective-c
// UIImageView
[imageView lc_setImageWithURL:[NSURL URLWithString:@"https://xxx"]];

// UIButton
[button lc_setImageWithURL:[NSURL URLWithString:@"https://xxx"] forState:(UIControlStateNormal)];
```

### Custom decoding playback animation

Use [YYImage](https://github.com/ibireme/YYWebImage) to implement custom decoding

```objective-c
// custom
[(LCAutoPurgingImageCache *)[LCImageDownloader defaultInstance].imageCache setCustomDecodedImage:^UIImage * _Nonnull(NSData * _Nonnull data, NSString * _Nonnull identifier) {
    return [[YYImage alloc] initWithData:data scale:UIScreen.mainScreen.scale];
}];
```

Load image

```objective-c
YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
[imageView lc_setImageWithURL:[NSURL URLWithString:@"https://xxx"]];
```



> Note: There is a display problem with YYImage above iOS 14. The source code of `YYAnimatedImageView` needs to be modified as follows:

```objective-c
- (void)displayLayer:(CALayer *)layer {
    // modified code
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

    // source code
//    if (_curFrame) {
//        layer.contents = (__bridge id)_curFrame.CGImage;
//    }
}

```

## Installation

### CocoaPods

To integrate LCWebImage into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'LCWebImage'
```

### Manual

1. Download everything inside the LCWebImage folder;
2. Add (drag and drop) the source files in LCWebImage to your project;
3. Add `AFNetworking/NSURLSession` code.

## License

LCWebImage is provided under the MIT license. See LICENSE file for details.

