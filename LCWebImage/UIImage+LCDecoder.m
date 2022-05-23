//  UIImage+LCDecoder.m
//  LCWebImage
//
//  Created by 刘畅 on 2022/5/23.
//

#import "UIImage+LCDecoder.h"
#import "objc/runtime.h"

static const size_t kBytesPerPixel = 4;
static const size_t kBitsPerComponent = 8;
static const CGFloat kBytesPerMB = 1024.0f * 1024.0f;
static const CGFloat kDestImageLimitBytes = 60.f * kBytesPerMB;
static const CGFloat kDestSeemOverlap = 2.0f;   // the numbers of pixels to overlap the seems where tiles meet.
@implementation UIImage (LCDecoder)
+ (CGColorSpaceRef)colorSpaceGetDeviceRGB {
    static CGColorSpaceRef colorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 9.0, tvOS 9.0, *)) {
            colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }
    });
    return colorSpace;
}

+ (BOOL)CGImageContainsAlpha:(CGImageRef)cgImage {
    if (!cgImage) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

+ (BOOL)shouldScaleDownImage:(nonnull UIImage *)image limitBytes:(NSUInteger)bytes {
    BOOL shouldScaleDown = YES;
    
    CGImageRef sourceImageRef = image.CGImage;
    CGSize sourceResolution = CGSizeZero;
    sourceResolution.width = CGImageGetWidth(sourceImageRef);
    sourceResolution.height = CGImageGetHeight(sourceImageRef);
    float sourceTotalPixels = sourceResolution.width * sourceResolution.height;
    if (sourceTotalPixels <= 0) {
        return NO;
    }
    CGFloat destTotalPixels;
    if (bytes == 0) {
        bytes = kDestImageLimitBytes;
    }
    bytes = MAX(bytes, kBytesPerPixel);
    destTotalPixels = bytes / kBytesPerPixel;
    float imageScale = destTotalPixels / sourceTotalPixels;
    if (imageScale < 1) {
        shouldScaleDown = YES;
    } else {
        shouldScaleDown = NO;
    }
    
    return shouldScaleDown;
}

+ (CGImageRef)CGImageCreateDecoded:(CGImageRef)cgImage orientation:(CGImagePropertyOrientation)orientation {
    if (!cgImage) {
        return NULL;
    }
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    if (width == 0 || height == 0) return NULL;
    size_t newWidth;
    size_t newHeight;
    switch (orientation) {
        case kCGImagePropertyOrientationLeft:
        case kCGImagePropertyOrientationLeftMirrored:
        case kCGImagePropertyOrientationRight:
        case kCGImagePropertyOrientationRightMirrored: {
            // These orientation should swap width & height
            newWidth = height;
            newHeight = width;
        }
            break;
        default: {
            newWidth = width;
            newHeight = height;
        }
            break;
    }
    
    BOOL hasAlpha = [self CGImageContainsAlpha:cgImage];
    // iOS prefer BGRA8888 (premultiplied) or BGRX8888 bitmapInfo for screen rendering, which is same as `UIGraphicsBeginImageContext()` or `- [CALayer drawInContext:]`
    // Though you can use any supported bitmapInfo (see: https://developer.apple.com/library/content/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html#//apple_ref/doc/uid/TP30001066-CH203-BCIBHHBB ) and let Core Graphics reorder it when you call `CGContextDrawImage`
    // But since our build-in coders use this bitmapInfo, this can have a little performance benefit
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, newWidth, newHeight, 8, 0, [self colorSpaceGetDeviceRGB], bitmapInfo);
    if (!context) {
        return NULL;
    }
    
    // Apply transform
    CGAffineTransform transform = SDCGContextTransformFromOrientation(orientation, CGSizeMake(newWidth, newHeight));
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage); // The rect is bounding box of CGImage, don't swap width & height
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return newImageRef;
}

static inline CGAffineTransform SDCGContextTransformFromOrientation(CGImagePropertyOrientation orientation, CGSize size) {
    // Inspiration from @libfeihu
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case kCGImagePropertyOrientationDown:
        case kCGImagePropertyOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case kCGImagePropertyOrientationLeft:
        case kCGImagePropertyOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case kCGImagePropertyOrientationRight:
        case kCGImagePropertyOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case kCGImagePropertyOrientationUp:
        case kCGImagePropertyOrientationUpMirrored:
            break;
    }
    
    switch (orientation) {
        case kCGImagePropertyOrientationUpMirrored:
        case kCGImagePropertyOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case kCGImagePropertyOrientationLeftMirrored:
        case kCGImagePropertyOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case kCGImagePropertyOrientationUp:
        case kCGImagePropertyOrientationDown:
        case kCGImagePropertyOrientationLeft:
        case kCGImagePropertyOrientationRight:
            break;
    }
    
    return transform;
}

+ (CGImageRef)CGImageCreateDecoded:(CGImageRef)cgImage {
    return [self CGImageCreateDecoded:cgImage orientation:kCGImagePropertyOrientationUp];
}

+ (UIImage *)lc_decodedImageWithImage:(UIImage *)image {
    if (!image) {
        return image;
    }
    
    CGImageRef imageRef = [self CGImageCreateDecoded:image.CGImage];
    if (!imageRef) {
        return image;
    }

    UIImage *decodedImage = [[UIImage alloc] initWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return decodedImage;
}

+ (UIImage *)lc_decodedAndScaledDownImageWithImage:(UIImage *)image limitBytes:(NSUInteger)bytes {
    if (!image) {
        return image;
    }
    
    if (![self shouldScaleDownImage:image limitBytes:bytes]) {
        return [self lc_decodedImageWithImage:image];
    }
    
    CGFloat destTotalPixels;
    CGFloat tileTotalPixels;
    if (bytes == 0) {
        bytes = kDestImageLimitBytes;
    }
    destTotalPixels = bytes / kBytesPerPixel;
    tileTotalPixels = destTotalPixels / 3;
    CGContextRef destContext;
    
    // autorelease the bitmap context and all vars to help system to free memory when there are memory warning.
    @autoreleasepool {
        CGImageRef sourceImageRef = image.CGImage;
        
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef);
        sourceResolution.height = CGImageGetHeight(sourceImageRef);
        CGFloat sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        // Determine the scale ratio to apply to the input image
        // that results in an output image of the defined size.
        // see kDestImageSizeMB, and how it relates to destTotalPixels.
        CGFloat imageScale = sqrt(destTotalPixels / sourceTotalPixels);
        CGSize destResolution = CGSizeZero;
        destResolution.width = MAX(1, (int)(sourceResolution.width * imageScale));
        destResolution.height = MAX(1, (int)(sourceResolution.height * imageScale));
        
        // device color space
        CGColorSpaceRef colorspaceRef = [self colorSpaceGetDeviceRGB];
        BOOL hasAlpha = [self CGImageContainsAlpha:sourceImageRef];
        // iOS display alpha info (BGRA8888/BGRX8888)
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        // kCGImageAlphaNone is not supported in CGBitmapContextCreate.
        // Since the original image here has no alpha info, use kCGImageAlphaNoneSkipFirst
        // to create bitmap graphics contexts without alpha info.
        destContext = CGBitmapContextCreate(NULL,
                                            destResolution.width,
                                            destResolution.height,
                                            kBitsPerComponent,
                                            0,
                                            colorspaceRef,
                                            bitmapInfo);
        
        if (destContext == NULL) {
            return image;
        }
        CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
        
        // Now define the size of the rectangle to be used for the
        // incremental bits from the input image to the output image.
        // we use a source tile width equal to the width of the source
        // image due to the way that iOS retrieves image data from disk.
        // iOS must decode an image from disk in full width 'bands', even
        // if current graphics context is clipped to a subrect within that
        // band. Therefore we fully utilize all of the pixel data that results
        // from a decoding operation by anchoring our tile size to the full
        // width of the input image.
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        // The source tile height is dynamic. Since we specified the size
        // of the source tile in MB, see how many rows of pixels high it
        // can be given the input image width.
        sourceTile.size.height = MAX(1, (int)(tileTotalPixels / sourceTile.size.width));
        sourceTile.origin.x = 0.0f;
        // The output tile is the same proportions as the input tile, but
        // scaled to image scale.
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        // The source seem overlap is proportionate to the destination seem overlap.
        // this is the amount of pixels to overlap each tile as we assemble the output image.
        float sourceSeemOverlap = (int)((kDestSeemOverlap/destResolution.height)*sourceResolution.height);
        CGImageRef sourceTileImageRef;
        // calculate the number of read/write operations required to assemble the
        // output image.
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // If tile height doesn't divide the image height evenly, add another iteration
        // to account for the remaining pixels.
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if(remainder) {
            iterations++;
        }
        // Add seem overlaps to the tiles, but save the original tile height for y coordinate calculations.
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += kDestSeemOverlap;
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = destResolution.height - (( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + kDestSeemOverlap);
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImageRef, sourceTile );
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
            }
        }
        
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }

        UIImage *destImage = [[UIImage alloc] initWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
}


@end

