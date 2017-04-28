//
//  BSPhotoTool.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoTool.h"
#import <Photos/Photos.h>

@interface BSPhotoTool ()

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

@end

@implementation BSPhotoTool

+ (instancetype)shareInstance
{
    static BSPhotoTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[BSPhotoTool alloc] init];
        tool.cachingImageManager = [[PHCachingImageManager alloc] init];
    });
    return tool;
}

+ (BOOL)authorizationStatusAuthorized
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied
        ||[PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusRestricted)
    {
        return NO;
    }
    return YES;
}

#pragma mark - get album
- (void)getAllAlbumsWithMediaType:(BSAssetMediaType)mediaType
                       completion:(void (^)(NSArray<BSAlbumModel *> *models))completion
{
    NSMutableArray *albumArr = [NSMutableArray array];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (mediaType != BSAssetMediaTypeAll)
    {
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", mediaType];
    }
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHAssetCollectionSubtype smartAlbumSubtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary |
    PHAssetCollectionSubtypeSmartAlbumRecentlyAdded | PHAssetCollectionSubtypeSmartAlbumVideos;
    
    // 获取只能相簿
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:smartAlbumSubtype
                                                                          options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop)
    {
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection
                                                              options:options];
        if (result.count > 0
            && !([collection.localizedTitle containsString:@"Deleted"]
                || [collection.localizedTitle containsString:@"最近删除"]))
        {
            if ([collection.localizedTitle isEqualToString:@"Camera Roll"] || [collection.localizedTitle isEqualToString:@"相机胶卷"]) {
                [albumArr insertObject:[BSAlbumModel modelWithFetchResult:result
                                                                     name:collection.localizedTitle]
                               atIndex:0];
            } else {
                [albumArr addObject:[BSAlbumModel modelWithFetchResult:result
                                                                  name:collection.localizedTitle]];
            }
        }
    }];
    
    // 获取用户相簿
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                         subtype:PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumSyncedAlbum
                                                                         options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop)
    {
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (result.count > 0)
        {
            if ([collection.localizedTitle isEqualToString:@"My Photo Stream"]) {
                [albumArr insertObject:[BSAlbumModel modelWithFetchResult:result
                                                                     name:collection.localizedTitle]
                               atIndex:1];
            } else {
                [albumArr addObject:[BSAlbumModel modelWithFetchResult:result
                                                                  name:collection.localizedTitle]];
            }
        }
    }];
    
    if (completion)
    {
        completion(albumArr);
    }
}

#pragma mark - get asset
- (void)getAssetsFromFetchResult:(PHFetchResult *)result
                      completion:(void (^)(NSArray<BSPhotoModel *> *models))completion
{
    NSMutableArray *photoArr = [NSMutableArray array];
    
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BSPhotoModel *model = [[BSPhotoModel alloc] init];
        model.asset = asset;
        [photoArr addObject:model];
    }];
    
    if (completion)
    {
        completion(photoArr);
    }
}

- (void)getPhotoWithAsset:(PHAsset *)asset
                     size:(CGSize)photoSize
            isSynchronous:(BOOL)isSynchronous
               completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = isSynchronous;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    [_cachingImageManager requestImageForAsset:asset
                                    targetSize:photoSize
                                   contentMode:PHImageContentModeAspectFit
                                       options:options
                                 resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info)
    {
        BOOL downloadFinined;
        
        downloadFinined  =  isSynchronous ? (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]):(![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        if (downloadFinined && image)
        {
            if (completion) {
                completion(image, info, [[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
        }
    }];
}

- (void)getOriginalPhotoWithAsset:(PHAsset *)asset
                       completion:(void (^)(UIImage *, NSDictionary *))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    [_cachingImageManager requestImageForAsset:asset
                                    targetSize:PHImageManagerMaximumSize
                                   contentMode:PHImageContentModeAspectFit
                                       options:option
                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
    {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result)
        {
            if (completion)
            {
                completion(result,info);
            }
        }
    }];
}

@end
