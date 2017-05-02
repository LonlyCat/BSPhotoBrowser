//
//  BSPhotoCell.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/5/2.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoCell.h"
#import "BSPhotoModel.h"
#import "BSPTool.h"
#import <Photos/Photos.h>

@interface BSPhotoCell ()

/** 照片 */
@property (nonatomic, weak) UIImageView *imageView;
/** 复选框 */
@property (nonatomic, weak) UIButton *selectButton;
/** 视频时长标识 */
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, weak) BSPhotoModel *model;

@end

@implementation BSPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           selfWidth,
                                                                           selfHeight)];
    imageView.layer.masksToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imageView];
    
    UIImage *nImage = [UIImage imageNamed:@"browser_choose_normal"];
    UIImage *sImage = [UIImage imageNamed:@"browser_choose_pressed"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(selfWidth - nImage.size.width - 5,
                              6,
                              nImage.size.width,
                              nImage.size.height);
    [button setImage:nImage forState:UIControlStateNormal];
    [button setImage:sImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               selfHeight - 12 - 5,
                                                               selfWidth - 4,
                                                               12)];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.textColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 0);
    label.textAlignment = NSTextAlignmentRight;
    label.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.contentView addSubview:label];
    
    _imageView = imageView;
    _selectButton = button;
    _timeLabel = label;
}

- (void)configWithModel:(BSPhotoModel *)model
{
    _model = model;
    
    __weak typeof(self) weakSelf = self;
    [model getThumbImageWithSize:CGSizeMake(100, 100) completed:^(UIImage *image)
    {
        [weakSelf.imageView setImage:image];
    }];
    
    if (_model.mediaType == BSAssetMediaTypeVideo)
    {
        _timeLabel.hidden = NO;
        _selectButton.hidden = YES;
        
        NSInteger mm = _model.asset.duration / 60;
        NSInteger ss = (NSInteger)_model.asset.duration % 60;
        _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",mm ,ss];
    }
    else
    {
        _timeLabel.hidden = YES;
        _selectButton.hidden = NO;
    }
}

#pragma mark - button action
- (void)selectButtonAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(selectButtonDidClicked:)])
    {
        [_delegate selectButtonDidClicked:self];
    }
}

#pragma mark - set
- (void)setHasSelected:(BOOL)hasSelected
{
    _hasSelected = hasSelected;
    _selectButton.selected = _hasSelected;
}

@end
