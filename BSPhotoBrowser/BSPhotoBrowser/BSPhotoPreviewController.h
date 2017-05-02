//
//  BSPhotoPreviewController.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSPConst.h"

@class BSPhotoModel;
@interface BSPhotoPreviewController : UIViewController

@property (nonatomic, strong) NSMutableArray<BSPhotoModel *> *photos;
@property (nonatomic, assign) BSAssetMediaType mediaType;
@property (nonatomic, assign) NSInteger currentIndex;

@end
