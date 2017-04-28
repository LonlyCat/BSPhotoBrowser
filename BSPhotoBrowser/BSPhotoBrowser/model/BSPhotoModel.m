//
//  BSPhotoModel.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoModel.h"

#import "BSPhotoTool.h"

@implementation BSPhotoModel

- (void)getThumbImageWithSize:(CGSize)size
                    completed:(void (^)(UIImage *))completed
{
    if (_thumbImage && completed)
    {
        completed(_thumbImage);
        return;
    }
    
    [[BSPhotoTool shareInstance] getPhotoWithAsset:_asset
                                              size:size
                                     isSynchronous:NO
                                        completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded)
    {
        _thumbImage = photo;
        if (photo && completed)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completed(_thumbImage);
            });
        }
    }];
}

- (void)getOriginImageWithCompleted:(void (^)(UIImage *))completed
{
    if (_originImage && completed)
    {
        completed(_originImage);
        return;
    }
    
    [[BSPhotoTool shareInstance] getOriginalPhotoWithAsset:_asset
                                                completion:^(UIImage *photo, NSDictionary *info)
     {
         _originImage = photo;
         if (photo && completed)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 completed(_originImage);
             });
         }
     }];
}

#pragma mark - setter
- (void)setAsset:(PHAsset *)asset
{
    if (_asset != asset)
    {
        _asset = asset;
        
        _thumbImage = nil;
        _originImage = nil;
    }
}

@end
