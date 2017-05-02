//
//  BSPPreviewCell.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/5/2.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPPreviewCell.h"

@interface BSPPreviewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BSPPreviewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               self.frame.size.width,
                                                               self.frame.size.height)];
    _imageView.layer.masksToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
}

- (void)configWithModel:(BSPhotoModel *)model
{
    __weak typeof(self) weakSelf = self;
    [model getOriginImageWithCompleted:^(UIImage *image) {
        [weakSelf.imageView setImage:image];
    }];
}

@end
