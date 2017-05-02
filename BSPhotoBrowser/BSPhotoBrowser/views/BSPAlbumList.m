//
//  BSPhotoAlubmList.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/28.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPAlbumList.h"
#import "BSPConst.h"
#import "BSPAlbumModel.h"
#import "BSPAlbumListCell.h"

@interface BSPAlbumList ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat maxHeight;

@end

@implementation BSPAlbumList

static CGFloat rowHeight = 63;
static NSString *const identifier = @"albumCell";

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

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
    _selectedIndex = 0;
    _maxHeight = KScreenHeight / 2;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            kScreenWidth,
                            KScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[BSPAlbumListCell class] forCellReuseIdentifier:identifier];
    [self addSubview:_tableView];
}

- (void)show
{
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        
        _tableView.frame = CGRectMake(0, 0, kScreenWidth, _maxHeight);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }];
}

- (void)hidden
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.backgroundColor = [UIColor clearColor];
        _tableView.frame = CGRectMake(0, 0, kScreenWidth, 0);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSPAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configWithModel:_albums[indexPath.row]];
    cell.selected = (indexPath.row == _selectedIndex);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndex = indexPath.row;
    BSPAlbumListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
    
    if ([_delegate respondsToSelector:@selector(selectAlbumAtIndex:)])
    {
        [_delegate selectAlbumAtIndex:indexPath.row];
    }
}

#pragma mark - setter
- (void)setAlbums:(NSArray *)albums
{
    _albums = albums;
    [_tableView reloadData];
    
    _maxHeight = MIN(KScreenHeight / 2, rowHeight * albums.count);
}

@end
