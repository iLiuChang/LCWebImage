// UIButton+LCWebImage.m
//
// LCWebImage(Based on AFNetworking)
//
// Created by 刘畅 on 2022/5/12.
//

#import "UIButton+LCWebImage.h"
#import <objc/runtime.h>

@interface UIButton (_LCWebImage)
@end

@implementation UIButton (_LCWebImage)

#pragma mark -

static char LCImageDownloadReceiptNormal;
static char LCImageDownloadReceiptHighlighted;
static char LCImageDownloadReceiptSelected;
static char LCImageDownloadReceiptDisabled;

static const char * lc_imageDownloadReceiptKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &LCImageDownloadReceiptHighlighted;
        case UIControlStateSelected:
            return &LCImageDownloadReceiptSelected;
        case UIControlStateDisabled:
            return &LCImageDownloadReceiptDisabled;
        case UIControlStateNormal:
        default:
            return &LCImageDownloadReceiptNormal;
    }
}

- (LCImageDownloadReceipt *)lc_imageDownloadReceiptForState:(UIControlState)state {
    return (LCImageDownloadReceipt *)objc_getAssociatedObject(self, lc_imageDownloadReceiptKeyForState(state));
}

- (void)lc_setImageDownloadReceipt:(LCImageDownloadReceipt *)imageDownloadReceipt
                          forState:(UIControlState)state
{
    objc_setAssociatedObject(self, lc_imageDownloadReceiptKeyForState(state), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

static char LCBackgroundImageDownloadReceiptNormal;
static char LCBackgroundImageDownloadReceiptHighlighted;
static char LCBackgroundImageDownloadReceiptSelected;
static char LCBackgroundImageDownloadReceiptDisabled;

static const char * lc_backgroundImageDownloadReceiptKeyForState(UIControlState state) {
    switch (state) {
        case UIControlStateHighlighted:
            return &LCBackgroundImageDownloadReceiptHighlighted;
        case UIControlStateSelected:
            return &LCBackgroundImageDownloadReceiptSelected;
        case UIControlStateDisabled:
            return &LCBackgroundImageDownloadReceiptDisabled;
        case UIControlStateNormal:
        default:
            return &LCBackgroundImageDownloadReceiptNormal;
    }
}

- (LCImageDownloadReceipt *)lc_backgroundImageDownloadReceiptForState:(UIControlState)state {
    return (LCImageDownloadReceipt *)objc_getAssociatedObject(self, lc_backgroundImageDownloadReceiptKeyForState(state));
}

- (void)lc_setBackgroundImageDownloadReceipt:(LCImageDownloadReceipt *)imageDownloadReceipt
                                    forState:(UIControlState)state
{
    objc_setAssociatedObject(self, lc_backgroundImageDownloadReceiptKeyForState(state), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIButton (LCWebImage)

+ (LCImageDownloader *)lc_sharedImageDownloader {
    
    return objc_getAssociatedObject([UIButton class], @selector(lc_sharedImageDownloader)) ?: [LCImageDownloader defaultInstance];
}

+ (void)lc_setSharedImageDownloader:(LCImageDownloader *)imageDownloader {
    objc_setAssociatedObject([UIButton class], @selector(lc_sharedImageDownloader), imageDownloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)lc_setImageWithURL:(NSURL *)url
                  forState:(UIControlState)state
{
    [self lc_setImageWithURL:url forState:state placeholderImage:nil];
}

- (void)lc_setImageWithURL:(NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self lc_setImageWithURLRequest:request forState:state placeholderImage:placeholderImage options:0 success:nil failure:nil];
}

- (void)lc_setImageWithURL:(NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(UIImage *)placeholderImage
                   options:(LCWebImageOptions)options
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self lc_setImageWithURLRequest:request forState:state placeholderImage:placeholderImage options:options success:nil failure:nil];
}

- (void)lc_setImageWithURLRequest:(NSURLRequest *)urlRequest
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholderImage
                          options:(LCWebImageOptions)options
                          success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                          failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([self isActiveTaskURLEqualToURLRequest:urlRequest forState:state]) {
        return;
    }
    
    [self lc_cancelImageDownloadTaskForState:state];
    
    LCImageDownloader *downloader = [[self class] lc_sharedImageDownloader];
    id <LCImageCache> imageCache = downloader.imageCache;
    
    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache memoryImageWithIdentifier:urlRequest.URL.absoluteString];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            [self setImage:cachedImage forState:state];
        }
        [self lc_setImageDownloadReceipt:nil forState:state];
    } else if (!(options & LCWebImageOptionIgnoreDiskCache) &&
               [imageCache containsDiskDataWithIdentifier:urlRequest.URL.absoluteString]) {
        NSUUID *downloadID = [NSUUID UUID];
        __weak __typeof(self)weakSelf = self;
        LCImageDownloadReceipt *receipt = [downloader diskImageForURL:urlRequest.URL withReceiptID:downloadID completion:^(UIImage * _Nonnull image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[strongSelf lc_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                if (success) {
                    success(urlRequest, nil, image);
                } else {
                    if (options & LCWebImageOptionNilImageUsePlaceHolder) {
                        [strongSelf setImage:image?:placeholderImage forState:state];
                    } else {
                        [strongSelf setImage:image forState:state];
                    }
                }
                [strongSelf lc_setImageDownloadReceipt:nil forState:state];
            }
        }];
        [self lc_setImageDownloadReceipt:receipt forState:state];
    } else {
        if (placeholderImage) {
            [self setImage:placeholderImage forState:state];
        }
        
        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        LCImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   options:options
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[strongSelf lc_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                if (success) {
                    success(request, response, responseObject);
                } else {
                    if (options & LCWebImageOptionNilImageUsePlaceHolder) {
                        [strongSelf setImage:responseObject?:placeholderImage forState:state];
                    } else {
                        [strongSelf setImage:responseObject forState:state];
                    }
                }
                [strongSelf lc_setImageDownloadReceipt:nil forState:state];
            }
            
        }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[strongSelf lc_imageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                if (failure) {
                    failure(request, response, error);
                } else {
                    [strongSelf setImage:placeholderImage forState:state];
                }
                [strongSelf  lc_setImageDownloadReceipt:nil forState:state];
            }
        }];
        
        [self lc_setImageDownloadReceipt:receipt forState:state];
    }
}

#pragma mark -

- (void)lc_setBackgroundImageWithURL:(NSURL *)url
                            forState:(UIControlState)state
{
    [self lc_setBackgroundImageWithURL:url forState:state placeholderImage:nil];
}

- (void)lc_setBackgroundImageWithURL:(NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self lc_setBackgroundImageWithURLRequest:request forState:state placeholderImage:placeholderImage options:0 success:nil failure:nil];
}

- (void)lc_setBackgroundImageWithURL:(NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholderImage
                             options:(LCWebImageOptions)options
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self lc_setBackgroundImageWithURLRequest:request forState:state placeholderImage:placeholderImage options:options success:nil failure:nil];
}

- (void)lc_setBackgroundImageWithURLRequest:(NSURLRequest *)urlRequest
                                   forState:(UIControlState)state
                           placeholderImage:(nullable UIImage *)placeholderImage
                                    options:(LCWebImageOptions)options
                                    success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                                    failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([self isActiveBackgroundTaskURLEqualToURLRequest:urlRequest forState:state]) {
        return;
    }
    
    [self lc_cancelBackgroundImageDownloadTaskForState:state];
    
    LCImageDownloader *downloader = [[self class] lc_sharedImageDownloader];
    id <LCImageCache> imageCache = downloader.imageCache;
    
    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache memoryImageWithIdentifier:urlRequest.URL.absoluteString];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            [self setBackgroundImage:cachedImage forState:state];
        }
        [self lc_setBackgroundImageDownloadReceipt:nil forState:state];
    } else if (!(options & LCWebImageOptionIgnoreDiskCache) &&
               [imageCache containsDiskDataWithIdentifier:urlRequest.URL.absoluteString]) {
        NSUUID *downloadID = [NSUUID UUID];
        __weak __typeof(self)weakSelf = self;
        LCImageDownloadReceipt *receipt = [downloader diskImageForURL:urlRequest.URL withReceiptID:downloadID completion:^(UIImage * _Nonnull image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[strongSelf lc_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                if (success) {
                    success(urlRequest, nil, image);
                } else {
                    if (options & LCWebImageOptionNilImageUsePlaceHolder) {
                        [strongSelf setBackgroundImage:image?:placeholderImage forState:state];
                    } else {
                        [strongSelf setBackgroundImage:image forState:state];
                    }
                }
                [strongSelf lc_setBackgroundImageDownloadReceipt:nil forState:state];
            }
        }];
        [self lc_setBackgroundImageDownloadReceipt:receipt forState:state];
    } else {
        if (placeholderImage) {
            [self setBackgroundImage:placeholderImage forState:state];
        }
        
        __weak __typeof(self)weakSelf = self;
        NSUUID *downloadID = [NSUUID UUID];
        LCImageDownloadReceipt *receipt;
        receipt = [downloader
                   downloadImageForURLRequest:urlRequest
                   withReceiptID:downloadID
                   options:options
                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[strongSelf lc_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                if (success) {
                    success(request, response, responseObject);
                } else {
                    if (options & LCWebImageOptionNilImageUsePlaceHolder) {
                        [strongSelf setBackgroundImage:responseObject?:placeholderImage forState:state];
                    } else {
                        [strongSelf setBackgroundImage:responseObject forState:state];
                    }
                }
                [strongSelf lc_setBackgroundImageDownloadReceipt:nil forState:state];
            }
            
        }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[strongSelf lc_backgroundImageDownloadReceiptForState:state].receiptID isEqual:downloadID]) {
                if (failure) {
                    failure(request, response, error);
                } else {
                    [strongSelf setBackgroundImage:placeholderImage forState:state];
                }
                [strongSelf  lc_setBackgroundImageDownloadReceipt:nil forState:state];
            }
        }];
        
        [self lc_setBackgroundImageDownloadReceipt:receipt forState:state];
    }
}

#pragma mark -

- (void)lc_cancelImageDownloadTaskForState:(UIControlState)state {
    LCImageDownloadReceipt *receipt = [self lc_imageDownloadReceiptForState:state];
    if (receipt != nil) {
        [[self.class lc_sharedImageDownloader] cancelTaskForImageDownloadReceipt:receipt];
        [self lc_setImageDownloadReceipt:nil forState:state];
    }
}

- (void)lc_cancelBackgroundImageDownloadTaskForState:(UIControlState)state {
    LCImageDownloadReceipt *receipt = [self lc_backgroundImageDownloadReceiptForState:state];
    if (receipt != nil) {
        [[self.class lc_sharedImageDownloader] cancelTaskForImageDownloadReceipt:receipt];
        [self lc_setBackgroundImageDownloadReceipt:nil forState:state];
    }
}

- (BOOL)isActiveTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest forState:(UIControlState)state {
    LCImageDownloadReceipt *receipt = [self lc_imageDownloadReceiptForState:state];
    return [receipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}

- (BOOL)isActiveBackgroundTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest forState:(UIControlState)state {
    LCImageDownloadReceipt *receipt = [self lc_backgroundImageDownloadReceiptForState:state];
    return [receipt.task.originalRequest.URL.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}

@end
