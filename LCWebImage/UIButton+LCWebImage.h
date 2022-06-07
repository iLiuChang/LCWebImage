// UIButton+LCWebImage.h
//
// LCWebImage (https://github.com/iLiuChang/LCWebImage)
//
// Created by 刘畅 on 2022/5/12.
// Copyright © 2022 LiuChang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCWebImageManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This category adds methods to the UIKit framework's `UIButton` class. The methods in this category provide support for loading remote images and background images asynchronously from a URL.
 
 @warning Compound values for control `state` (such as `UIControlStateHighlighted | UIControlStateDisabled`) are unsupported.
 */
@interface UIButton (LCWebImage)

///------------------------------------
/// @name Accessing the Image Manager
///------------------------------------

/**
 Set the shared image manager used to download images.
 
 @param imageManager The shared image manager used to download images.
 */
+ (void)lc_setSharedImageManager:(LCWebImageManager *)imageManager;

/**
 The shared image manager used to download images.
 */
+ (LCWebImageManager *)lc_sharedImageManager;

///--------------------
/// @name Setting Image
///--------------------

/**
 Asynchronously downloads an image from the specified URL, and sets it as the image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 @param url The URL used for the image request.
 @param state The control state.
 */
- (void)lc_setImageWithURL:(NSURL *)url
                  forState:(UIControlState)state;

/**
 Asynchronously downloads an image from the specified URL, and sets it as the image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 @param url The URL used for the image request.
 @param state The control state.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the button will not change its image until the image request finishes.
 */
- (void)lc_setImageWithURL:(NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholderImage;

/**
 Asynchronously downloads an image from the specified URL, and sets it as the image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 @param url The URL used for the image request.
 @param state The control state.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the button will not change its image until the image request finishes.
 @param options The options to control image operation.
 */
- (void)lc_setImageWithURL:(NSURL *)url
                  forState:(UIControlState)state
          placeholderImage:(nullable UIImage *)placeholderImage
                   options:(LCWebImageOptions)options;
/**
 Asynchronously downloads an image from the specified URL request, and sets it as the image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 If a success block is specified, it is the responsibility of the block to set the image of the button before returning. If no success block is specified, the default behavior of setting the image with `setImage:forState:` is applied.
 
 @param urlRequest The URL request used for the image request.
 @param state The control state.
 @param placeholderImage The image to be set initially, until the image request finishes. If `nil`, the button will not change its image until the image request finishes.
 @param options The options to control image operation.
 @param success A block to be executed when the image data task finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the image created from the response data of request. If the image was returned from cache, the response parameter will be `nil`.
 @param failure A block object to be executed when the image data task finishes unsuccessfully, or that finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error object describing the network or parsing error that occurred.
 */
- (void)lc_setImageWithURLRequest:(NSURLRequest *)urlRequest
                         forState:(UIControlState)state
                 placeholderImage:(nullable UIImage *)placeholderImage
                          options:(LCWebImageOptions)options
                          success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                          failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;

///-------------------------------
/// @name Setting Background Image
///-------------------------------

/**
 Asynchronously downloads an image from the specified URL, and sets it as the background image for the specified state once the request is finished. Any previous background image request for the receiver will be cancelled.
 
 If the background image is cached locally, the background image is set immediately, otherwise the specified placeholder background image will be set immediately, and then the remote background image will be set once the request is finished.
 
 @param url The URL used for the background image request.
 @param state The control state.
 */
- (void)lc_setBackgroundImageWithURL:(NSURL *)url
                            forState:(UIControlState)state;
/**
 Asynchronously downloads an image from the specified URL, and sets it as the background image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 @param url The URL used for the background image request.
 @param state The control state.
 @param placeholderImage The background image to be set initially, until the background image request finishes. If `nil`, the button will not change its background image until the background image request finishes.
 */
- (void)lc_setBackgroundImageWithURL:(NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholderImage;

/**
 Asynchronously downloads an image from the specified URL, and sets it as the background image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 @param url The URL used for the background image request.
 @param state The control state.
 @param placeholderImage The background image to be set initially, until the background image request finishes. If `nil`, the button will not change its background image until the background image request finishes.
 @param options The options to control image operation.
 */
- (void)lc_setBackgroundImageWithURL:(NSURL *)url
                            forState:(UIControlState)state
                    placeholderImage:(nullable UIImage *)placeholderImage
                             options:(LCWebImageOptions)options;

/**
 Asynchronously downloads an image from the specified URL request, and sets it as the image for the specified state once the request is finished. Any previous image request for the receiver will be cancelled.
 
 If the image is cached locally, the image is set immediately, otherwise the specified placeholder image will be set immediately, and then the remote image will be set once the request is finished.
 
 If a success block is specified, it is the responsibility of the block to set the image of the button before returning. If no success block is specified, the default behavior of setting the image with `setBackgroundImage:forState:` is applied.
 
 @param urlRequest The URL request used for the image request.
 @param state The control state.
 @param placeholderImage The background image to be set initially, until the background image request finishes. If `nil`, the button will not change its background image until the background image request finishes.
 @param options The options to control image operation.
 @param success A block to be executed when the image data task finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the image created from the response data of request. If the image was returned from cache, the response parameter will be `nil`.
 @param failure A block object to be executed when the image data task finishes unsuccessfully, or that finishes successfully. This block has no return value and takes three arguments: the request sent from the client, the response received from the server, and the error object describing the network or parsing error that occurred.
 */
- (void)lc_setBackgroundImageWithURLRequest:(NSURLRequest *)urlRequest
                                   forState:(UIControlState)state
                           placeholderImage:(nullable UIImage *)placeholderImage
                                    options:(LCWebImageOptions)options
                                    success:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, UIImage *image))success
                                    failure:(nullable void (^)(NSURLRequest *request, NSHTTPURLResponse * _Nullable response, NSError *error))failure;

///------------------------------
/// @name Canceling Image Loading
///------------------------------

/**
 Cancels any executing image task for the specified control state of the receiver, if one exists.
 
 @param state The control state.
 */
- (void)lc_cancelImageDownloadTaskForState:(UIControlState)state;

/**
 Cancels any executing background image task for the specified control state of the receiver, if one exists.
 
 @param state The control state.
 */
- (void)lc_cancelBackgroundImageDownloadTaskForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
