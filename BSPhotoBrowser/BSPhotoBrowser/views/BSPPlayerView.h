//
//  BSPPlayerView.h
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/5/3.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BSPPlayerView : UIView

@property (nonatomic, copy) void(^loadingCompleted)();

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSURL *)videoPath previewImage:(UIImage *)previewImage;

- (void)play;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
