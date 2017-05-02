//
//  BSPhotoModel.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSPConst.h"

@class PHAsset;
@interface BSPhotoModel : NSObject

@property (nonatomic, strong) PHAsset   *asset;
@property (nonatomic, strong) UIImage   *thumbImage;
@property (nonatomic, strong) UIImage   *originImage;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BSAssetMediaType mediaType;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (void)getThumbImageWithSize:(CGSize)size
                    completed:(void (^)(UIImage *))completed;

- (void)getOriginImageWithCompleted:(void(^)(UIImage *image))completed;

@end
