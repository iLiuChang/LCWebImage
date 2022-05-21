// LCAutoPurgingImageCache.h
//
// LCWebImage(Based on AFNetworking)
//
// Created by 刘畅 on 2022/5/12.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>

#if TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Image Cache Expire Type
typedef NS_ENUM(NSUInteger, LCImageDiskCacheExpireType) {
    /**
     * When the image cache is accessed it will update this value
     */
    LCImageDiskCacheExpireTypeAccessDate,
    /**
     * When the image cache is created or modified it will update this value (Default)
     */
    LCImageDiskCacheExpireTypeModificationDate,
    /**
     * When the image cache is created it will update this value
     */
    LCImageDiskCacheExpireTypeCreationDate,
    /**
     * When the image cache is created, modified, renamed, file attribute updated (like permission, xattr)  it will update this value
     */
    LCImageDiskCacheExpireTypeChangeDate,
};

/**
 The `LCImageCache` protocol defines a set of APIs for adding, removing and fetching images from a cache synchronously.
 */
@protocol LCImageCache <NSObject>

/**
 NSData to UIImage.

 @param data The origin data.
 @param identifier The unique identifier for the image in the cache.
 
 @return An image for the data, or nil.
 */
- (nullable UIImage *)transformImageFromData:(nullable NSData *)data withIdentifier:(NSString *)identifier;

/**
 Adds the image to the cache with the given identifier.

 @param image The image to cache.
 @param identifier The unique identifier for the image in the cache.
 */
- (void)addMemoryImage:(nullable UIImage *)image withIdentifier:(NSString *)identifier;

/**
 Removes the image from the cache matching the given identifier.

 @param identifier The unique identifier for the image in the cache.

 @return A BOOL indicating whether or not the image was removed from the cache.
 */
- (BOOL)removeMemoryImageWithIdentifier:(NSString *)identifier;

/**
 Returns the image in the cache associated with the given identifier.

 @param identifier The unique identifier for the image in the cache.

 @return An image for the matching identifier, or nil.
 */
- (nullable UIImage *)memoryImageWithIdentifier:(NSString *)identifier;

/**
 Returns a boolean value that indicates whether a given identifier is in cache.
 This method may blocks the calling thread until file read finished.
 
 @param identifier A string identifying the data. If nil, just return NO.
 @return Whether the identifier is in cache.
 */
- (BOOL)containsDiskDataWithIdentifier:(NSString *)identifier;

/**
 Returns the data associated with a given identifier.
 This method may blocks the calling thread until file read finished.
 
 @param identifier A string identifying the data. If nil, just return nil.
 @return The value associated with identifier, or nil if no value is associated with identifier.
 */
- (nullable NSData *)diskDataWithIdentifier:(NSString *)identifier;

/**
 Sets the value of the specified identifier in the cache.
 This method may blocks the calling thread until file write finished.
 
 @param data The data to be stored in the cache.
 @param identifier The identifier with which to associate the value. If nil, this method has no effect.
 */
- (void)addDiskData:(nullable NSData *)data withIdentifier:(NSString *)identifier;

/**
 Removes the value of the specified key in the cache.
 This method may blocks the calling thread until file delete finished.
 
 @param identifier The value to be removed. If nil, this method has no effect.
 */
- (void)removeDiskDataWithIdentifier:(nonnull NSString *)identifier;
@end

/**
 The built-in disk cache.
 */
@interface LCImageDiskCache : NSObject

/**
 * Whether or not to disable iCloud backup
 * Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldDisableiCloud;

/*
 * The attribute which the clear cache will be checked against when clearing the disk cache
 * Default is Modified Date
 */
@property (assign, nonatomic) LCImageDiskCacheExpireType diskCacheExpireType;

/**
 * The maximum length of time to keep an image in the disk cache, in seconds.
 * Setting this to a negative value means no expiring.
 * Setting this to zero means that all cached files would be removed when do expiration check.
 * Defaults to 1 week.
 */
@property (assign, nonatomic) NSTimeInterval maxDiskAge;

/**
 * The maximum size of the disk cache, in bytes.
 * Defaults to 0. Which means there is no cache size limit.
 */
@property (assign, nonatomic) NSUInteger maxDiskSize;

/**
 * Whether or not to remove the expired disk data when application entering the background.
 * Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldRemoveExpiredDataWhenEnterBackground;

/**
 * Whether or not to remove the expired disk data when application been terminated. This operation is processed in sync to ensure clean up.
 * Defaults to YES.
 */
@property (assign, nonatomic) BOOL shouldRemoveExpiredDataWhenTerminate;

/**
 Create a new disk cache based on the specified path. You can check `maxDiskSize` and `maxDiskAge` used for disk cache.
 
 @param cachePath Full path of a directory in which the cache will write data.
 Once initialized you should not read and write to this directory.

 @return A new cache object, or nil if an error occurs.
 */
- (nullable instancetype)initWithCachePath:(NSString *)cachePath;

/**
 Returns a boolean value that indicates whether a given identifier is in cache.
 This method may blocks the calling thread until file read finished.
 
 @param identifier A string identifying the data. If nil, just return NO.
 @return Whether the identifier is in cache.
 */
- (BOOL)containsDataWithIdentifier:(NSString *)identifier;

/**
 Returns the data associated with a given identifier.
 This method may blocks the calling thread until file read finished.
 
 @param identifier A string identifying the data. If nil, just return nil.
 @return The value associated with identifier, or nil if no value is associated with identifier.
 */
- (nullable NSData *)dataWithIdentifier:(NSString *)identifier;

/**
 Sets the value of the specified identifier in the cache.
 This method may blocks the calling thread until file write finished.
 
 @param data The data to be stored in the cache.
 @param identifier The identifier with which to associate the value. If nil, this method has no effect.
 */
- (void)addData:(nullable NSData *)data withIdentifier:(NSString *)identifier;

/**
 Removes the value of the specified key in the cache.
 This method may blocks the calling thread until file delete finished.
 
 @param identifier The value to be removed. If nil, this method has no effect.
 */
- (void)removeDataWithIdentifier:(nonnull NSString *)identifier;

/**
 Empties the cache.
 This method may blocks the calling thread until file delete finished.
 */
- (void)removeAllData;

/**
 The cache path for identifier

 @param identifier A string identifying the value
 @return The cache path for identifier. Or nil if the identifier can not associate to a path
 */
- (nullable NSString *)cachePathWithIdentifier:(nonnull NSString *)identifier;

/**
 Returns the number of data in this cache.
 This method may blocks the calling thread until file read finished.
 
 @return The total data count.
 */
- (NSUInteger)totalCount;

/**
 Returns the total size (in bytes) of data in this cache.
 This method may blocks the calling thread until file read finished.
 
 @return The total data size in bytes.
 */
- (NSUInteger)totalSize;

/**
 Removes the expired data from the cache. You can choose the data to remove base on `ageLimit`, `countLimit` and `sizeLimit` options.
 */
- (void)removeExpiredData;

@end

/**
 The `AutoPurgingImageCache` in an in-memory image cache used to store images up to a given memory capacity. When the memory capacity is reached, the image cache is sorted by last access date, then the oldest image is continuously purged until the preferred memory usage after purge is met. Each time an image is accessed through the cache, the internal access date of the image is updated.
 */
@interface LCAutoPurgingImageCache : NSObject <LCImageCache>

/**
 The disk cache.
 */
@property (nonatomic, strong, nullable) LCImageDiskCache *diskCache;

/**
 NSData to UIImage.
 */
@property (nonatomic, copy, nullable) UIImage * (^customTransform)(NSData *data, NSString *identifier);

/**
 The total memory capacity of the cache in bytes.
 */
@property (nonatomic, assign) UInt64 memoryCapacity;

/**
 The preferred memory usage after purge in bytes. During a purge, images will be purged until the memory capacity drops below this limit.
 */
@property (nonatomic, assign) UInt64 preferredMemoryUsageAfterPurge;

/**
 The current total memory usage in bytes of all images stored within the cache.
 */
@property (nonatomic, assign, readonly) UInt64 memoryUsage;

/**
 Initialies the `AutoPurgingImageCache` instance with default values for memory capacity and preferred memory usage after purge limit. `memoryCapcity` defaults to `100 MB`. `preferredMemoryUsageAfterPurge` defaults to `60 MB`.

 @return The new `AutoPurgingImageCache` instance.
 */
- (instancetype)init;

/**
 Removes all images from the cache.

 @return A BOOL indicating whether or not all images were removed from the cache.
 */
- (BOOL)removeAllMemoryImages;

/**
 Adds the image to the cache with the given identifier.

 @param image The image to cache.
 @param data The image to cache.
 @param identifier The unique identifier for the image in the cache.
 */
- (void)addImage:(nullable UIImage *)image imageData:(NSData *)data withIdentifier:(NSString *)identifier;

/**
 Removes the image from the cache matching the given identifier.

 @param identifier The unique identifier for the image in the cache.
 */
- (void)removeImageWithIdentifier:(NSString *)identifier;

/**
 Removes all images from the cache.

 */
- (void)removeAllImages;

/**
 Returns the image in the cache associated with the given identifier.

 @param identifier The unique identifier for the image in the cache.

 @return An image for the matching identifier, or nil.
 */
- (nullable UIImage *)imageWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END

#endif

