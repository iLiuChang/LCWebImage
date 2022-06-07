// UIImageView+LCWebImage.m
//
// LCWebImage (https://github.com/iLiuChang/LCWebImage)
//
// Created by 刘畅 on 2022/5/12.
// Copyright © 2022 LiuChang. All rights reserved.
//

#import "UIImageView+LCWebImage.h"
#import <objc/runtime.h>

@interface UIImageView (_LCWebImage)
@property (readwrite, nonatomic, strong, setter = lc_setActiveImageDownloadReceipt:) LCImageDownloadReceipt *lc_activeImageDownloadReceipt;
@end

@implementation UIImageView (_LCWebImage)

- (LCImageDownloadReceipt *)lc_activeImageDownloadReceipt {
    return (LCImageDownloadReceipt *)objc_getAssociatedObject(self, @selector(lc_activeImageDownloadReceipt));
}

- (void)lc_setActiveImageDownloadReceipt:(LCImageDownloadReceipt *)imageDownloadReceipt {
    objc_setAssociatedObject(self, @selector(lc_activeImageDownloadReceipt), imageDownloadReceipt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -

@implementation UIImageView (LCWebImage)

+ (LCWebImageManager *)lc_sharedImageManager {
    return objc_getAssociatedObject([UIImageView class], @selector(lc_sharedImageManager)) ?: [LCWebImageManager defaultInstance];
}

+ (void)lc_setSharedImageManager:(LCWebImageManager *)imageManager {
    objc_setAssociatedObject([UIImageView class], @selector(lc_sharedImageManager), imageManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)lc_setImageWithURL:(NSURL *)url {
    [self lc_setImageWithURL:url placeholderImage:nil];
}

- (void)lc_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self lc_setImageWithURLRequest:request placeholderImage:placeholderImage options:0 success:nil failure:nil];
}

- (void)lc_setImageWithURL:(NSURL *)url
          placeholderImage:(UIImage *)placeholderImage
                   options:(LCWebImageOptions)options
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self lc_setImageWithURLRequest:request placeholderImage:placeholderImage options:options success:nil failure:nil];
}

- (void)lc_setImageWithURLRequest:(NSURLRequest *)urlRequest
                 placeholderImage:(UIImage *)placeholderImage
                          options:(LCWebImageOptions)options
                          success:(void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                          failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure
{
    if ([urlRequest URL] == nil) {
        self.image = placeholderImage;
        if (failure) {
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
            failure(urlRequest, nil, error);
        }
        return;
    }
    
    if ([self isActiveTaskURLEqualToURLRequest:urlRequest]) {
        return;
    }
    
    [self lc_cancelImageDownloadTask];
    
    LCWebImageManager *downloader = [[self class] lc_sharedImageManager];
    id <LCImageCache> imageCache = downloader.imageCache;
    
    //Use the image from the image cache if it exists
    UIImage *cachedImage = [imageCache memoryImageWithIdentifier:urlRequest.URL.absoluteString];
    if (cachedImage) {
        if (success) {
            success(urlRequest, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
        [self clearActiveDownloadInformation];
    } else if (!(options & LCWebImageOptionIgnoreDiskCache) &&
               [imageCache containsDiskDataWithIdentifier:urlRequest.URL.absoluteString]) {
        NSUUID *downloadID = [NSUUID UUID];
        __weak __typeof(self)weakSelf = self;
        LCImageDownloadReceipt *receipt = [downloader diskImageForURL:urlRequest.URL withReceiptID:downloadID completion:^(UIImage * _Nonnull image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.lc_activeImageDownloadReceipt.receiptID isEqual:downloadID]) {
                if (success) {
                    success(urlRequest, nil, image);
                } else {
                    if (options & LCWebImageOptionNilImageUsePlaceHolder) {
                        strongSelf.image = image?:placeholderImage;
                    } else {
                        strongSelf.image = image;
                    }
                }
                [strongSelf clearActiveDownloadInformation];
            }
        }];
        self.lc_activeImageDownloadReceipt = receipt;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
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
            if ([strongSelf.lc_activeImageDownloadReceipt.receiptID isEqual:downloadID]) {
                if (success) {
                    success(request, response, responseObject);
                } else {
                    if (options & LCWebImageOptionNilImageUsePlaceHolder) {
                        strongSelf.image = responseObject?:placeholderImage;
                    } else {
                        strongSelf.image = responseObject;
                    }
                }
                [strongSelf clearActiveDownloadInformation];
            }
            
        }
                   failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([strongSelf.lc_activeImageDownloadReceipt.receiptID isEqual:downloadID]) {
                if (failure) {
                    failure(request, response, error);
                } else {
                    strongSelf.image = placeholderImage;
                }
                [strongSelf clearActiveDownloadInformation];
            }
        }];
        
        self.lc_activeImageDownloadReceipt = receipt;
    }
}

- (void)lc_cancelImageDownloadTask {
    if (self.lc_activeImageDownloadReceipt != nil) {
        [[self.class lc_sharedImageManager] cancelTaskForImageDownloadReceipt:self.lc_activeImageDownloadReceipt];
        [self clearActiveDownloadInformation];
    }
}

- (void)clearActiveDownloadInformation {
    self.lc_activeImageDownloadReceipt = nil;
}

- (BOOL)isActiveTaskURLEqualToURLRequest:(NSURLRequest *)urlRequest {
    return [self.lc_activeImageDownloadReceipt.url.absoluteString isEqualToString:urlRequest.URL.absoluteString];
}

@end
