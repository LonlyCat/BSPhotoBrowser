//
//  BSPhotoBrowser.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSPConst.h"
#import "BSPhotoBrowserController.h"

@class BSPhotoModel;
@interface BSPhotoBrowser : NSObject

/** 最大照片选择数 default: 6 */
@property (nonatomic, assign) NSInteger maxImageCount;
/** 当前已选择的照片 */
@property (nonatomic, strong) NSMutableArray<BSPhotoModel *> *selectPhotos;


+ (instancetype)shareInstance;
- (void)showBrowerWithMediaType:(BSAssetMediaType)type
                       delegate:(UIViewController<BSPhotoBrowserDelegate> *)delegate;

@end
