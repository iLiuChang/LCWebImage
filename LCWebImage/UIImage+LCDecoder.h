//  UIImage+LCDecoder.h
//  LCWebImage (https://github.com/iLiuChang/LCWebImage)
//
//  Created by 刘畅 on 2022/5/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LCDecoder)

/**
 Return the decoded image by the provided image. This one unlike `CGImageCreateDecoded:`, will not decode the image which contains alpha channel or animated image
 @param image The image to be decoded
 @return The decoded image
 */
+ (UIImage *)lc_decodedImageWithImage:(UIImage *)image;

/**
 Return the decoded and probably scaled down image by the provided image. If the image pixels bytes size large than the limit bytes, will try to scale down. Or just works as `lc_decodedImageWithImage:`, never scale up.
 @warning You should not pass too small bytes, the suggestion value should be larger than 1MB. Even we use Tile Decoding to avoid OOM, however, small bytes will consume much more CPU time because we need to iterate more times to draw each tile.

 @param image The image to be decoded and scaled down
 @param bytes The limit bytes size. Provide 0 to use the build-in limit.
 @return The decoded and probably scaled down image
 */
+ (UIImage *)lc_decodedAndScaledDownImageWithImage:(UIImage *)image limitBytes:(NSUInteger)bytes;

@end

NS_ASSUME_NONNULL_END
