// UIImageView+LCWebImage.h
//
// LCWebImage(Based on AFNetworking)
//
// Created by 刘畅 on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import "LCImageDownloader.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This category adds methods to the UIKit framework's `UIImageView` class. The methods in this category provide support for loading remote images asynchronously from a URL.
 */
@interface UIImageView (LCWebImage)

///------------------------------------
/// @name Accessing the Image Downloader
///------------------------------------

/**
 Set the shared image downloader used to download images.
 
 @param imageDownloader The shared image downloader used to download images.
 */
+ (void)lc_setSharedImageDownloader:(LCImageDownloader *)imageDownloader;

/**
 The shared image downloader used to download images.
 */
+ (LCImageDownloader *)lc_sharedImageDownloader;

///--------------------
/// @name Setting Image
///--------------------

/**
 Asynchronously downloads an image from the specified URL, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 By default, URL requests have a `Accept` header field value of "image / *", a cache policy of `NSURLCacheStorageAllowed` and a timeout interval of 30 seconds, and are set not handle cookies.
 
 @param url The URL used for the image request.
 */
- (void)lc_setImageWithURL:(NSURL *)url;

/**
 Asynchronously downloads an image from the specified URL, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 By default, URL requests have a `Accept` header field value of "image / *", a cache policy of `NSURLCacheStorageAllowed` and a timeout interval of 30 seconds, and are set not handle cookies.
 
 @param url The URL used for the image request.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 */
- (void)lc_setImageWithURL:(NSURL *)url
          placeholderImage:(nullable UIImage *)placeholderImage;

/**
 Asynchronously downloads an image from the specified URL, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 By default, URL requests have a `Accept` header field value of "image / *", a cache policy of `NSURLCacheStorageAllowed` and a timeout interval of 30 seconds, and are set not handle cookies. 
 
 @param url The URL used for the image request.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 @param options The options to control image operation.
 */
- (void)lc_setImageWithURL:(NSURL *)url
          placeholderImage:(nullable UIImage *)placeholderImage
                   options:(LCWebImageOptions)options;
/**
 Asynchronously downloads an image from the specified URL request, and sets it once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 If a success block is specified, it is the responsibility of the block to set the image of the image view before returning. If no success block is specified, the default behavior of setting the image with `self.image = image` is applied.
 
 @param urlRequest The URL request used for the image request.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the image view will not change its image until the image request finishes.
 @param options The options to control image operation.
 @param success A block to be executed when the image data task finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the image created from the response data of request. If the image was returned from cache, the response parameter will be `nil`.
 @param failure A block object to be executed when the image data task finishes unsuccessfully, or that finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error object describing the network or parsing error that occurred.
 */
- (void)lc_setImageWithURLRequest:(NSURLRequest *)urlRequest
                 placeholderImage:(nullable UIImage *)placeholderImage
                          options:(LCWebImageOptions)options
                          success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                          failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;

/**
 Cancels any executing image operation for the receiver, if one exists.
 */
- (void)lc_cancelImageDownloadTask;

@end

NS_ASSUME_NONNULL_END
