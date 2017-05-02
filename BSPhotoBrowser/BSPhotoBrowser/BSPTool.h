//
//  BSPTool.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BSPAlbumModel.h"
#import "BSPhotoModel.h"
#import "BSPConst.h"

@interface BSPTool : NSObject

/**
 获取单例
 */
+ (instancetype)shareInstance;

/**
 判断是否有相簿访问权限

 @return YES:有权限  NO:无权限
 */
+ (BOOL)authorizationStatusAuthorized;

/**
 获得所有相簿

 @param mediaType  媒体类型
 @param completion 成功回调
 */
- (void)getAllAlbumsWithMediaType:(BSAssetMediaType)mediaType
                       completion:(void (^)(NSArray<BSPAlbumModel *> *models))completion;

/**
 获得某个相簿中的所有图片

 @param result 相簿查询结果
 @param completion 成功回调
 */
- (void)getAssetsFromFetchResult:(PHFetchResult *)result
                      completion:(void (^)(NSArray<BSPhotoModel *> *models))completion;

/**
 获取指定大小的图片

 @param asset PHAsset 实例
 @param photoSize 指定大小
 @param isSynchronous 是否同步加载
 @param completion 完成回调
 */
- (void)getPhotoWithAsset:(PHAsset *)asset
                     size:(CGSize)photoSize
            isSynchronous:(BOOL)isSynchronous
               completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion;

/**
 获取原始图片

 @param asset PHAsset 实例
 @param completion 成功回调
 */
- (void)getOriginalPhotoWithAsset:(PHAsset *)asset
                       completion:(void (^)(UIImage *photo,NSDictionary *info))completion;

@end
