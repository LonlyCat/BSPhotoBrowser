//
//  BSPhotoBrowserController.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/4/27.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPhotoBrowserController.h"

#import "BSPTool.h"
#import "BSPhotoCell.h"
#import "BSPAlbumList.h"
#import "BSPhotoPreviewController.h"

@interface BSPhotoBrowserController ()
<
BSPhotoCellDelegate,
BSPAlbumListDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource
>

/** 是否是选择原图 */
@property (nonatomic, assign) BOOL isOriginal;
/** 所有相册 */
@property (nonatomic, strong) NSArray *albums;
/** 相册中的所有图片 */
@property (nonatomic, strong) NSArray *albumPhotos;
/** 确定按钮 */
@property (nonatomic, strong) UIButton *doneButton;
/** 下拉菜单按钮 */
@property (nonatomic, strong) UIButton *menuButton;
/** 下拉菜单按钮 */
@property (nonatomic, strong) UIButton *previewButton;
/** 下拉菜单按钮 */
@property (nonatomic, strong) UIButton *originalButton;
/** 下拉菜单 */
@property (nonatomic, strong) BSPAlbumList *albumList;
/** 照片展示 */
@property (nonatomic, strong) UICollectionView *collectionView;
/** 当前已选择的照片 */
@property (nonatomic, strong) NSMutableArray<BSPhotoModel *> *selectPhotos;

@property (nonatomic, assign) BSAssetMediaType selectMeidaType;
@property (nonatomic, assign) NSInteger maxVideoCount;

@end

@implementation BSPhotoBrowserController

static NSString *const identifier = @"photoCell";

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _maxVideoCount = 1;
        _selectPhotos = [NSMutableArray arrayWithCapacity:_maxImageCount];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self requestAlbums];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_menuButton removeFromSuperview];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar addSubview:_menuButton];
}
#pragma mark - UI
- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat barHeight = self.navigationController.navigationBar.frame.size.height;
    // 返回按钮
    UIImage *leftImage = [[UIImage imageNamed:@"browser_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:leftImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(leftBarButtonAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 确定按钮
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(0, 0, 70, 30);
    _doneButton.backgroundColor = [UIColor blackColor];
    _doneButton.layer.cornerRadius = 3;
    [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(rightBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_doneButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    // 下拉菜单按钮
    _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _menuButton.frame = CGRectMake(0, 0, 200, 24);
    _menuButton.center = CGPointMake(kScreenWidth / 2,
                                     barHeight / 2);
    [_menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_menuButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:17]];
    [_menuButton setImage:[UIImage imageNamed:@"browser_pull"] forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_menuButton];
    
    // collection view
    CGFloat itemMargin = 1;
    CGFloat itemWidth = (kScreenWidth - itemMargin * 5) / 4;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = itemMargin;
    layout.minimumInteritemSpacing = itemMargin;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, KScreenHeight)
                                         collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[BSPhotoCell class] forCellWithReuseIdentifier:identifier];
    [self.view addSubview:_collectionView];
    
    // 下拉菜单
    _albumList = [[BSPAlbumList alloc] initWithFrame:CGRectZero];
    _albumList.hidden = YES;
    _albumList.delegate = self;
    [self.view addSubview:_albumList];
    
    // 工具栏
    [self setupToolBar];
}

- (void)setupToolBar
{
    CGFloat tBarHeight = CGRectGetHeight(self.navigationController.toolbar.frame);
    
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previewButton.frame = CGRectMake(0, 0, 40, tBarHeight);
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _previewButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [_previewButton addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalButton.frame = CGRectMake(0, 0, 60, tBarHeight);
    [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [_originalButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_originalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_originalButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [_originalButton setImage:[UIImage imageNamed:@"browser_original"] forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"browser_choose_pressed"] forState:UIControlStateSelected];
    [_originalButton addTarget:self action:@selector(originalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *tBarItems = @[[[UIBarButtonItem alloc] initWithCustomView:_previewButton],
                           [[UIBarButtonItem alloc] initWithCustomView:_originalButton]];
    [self setToolbarItems:tBarItems animated:YES];
    
    _previewButton.enabled = NO;
}
#pragma mark - button action
- (void)previewButtonAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    BSPhotoPreviewController *previewVC = [[BSPhotoPreviewController alloc] init];
    previewVC.photos = _selectPhotos;
    previewVC.selectPhotos = _selectPhotos;
    previewVC.currentIndex = 0;
    previewVC.mediaType = BSAssetMediaTypeImage;
    previewVC.maxVideoSec = _maxVideoSec;
    previewVC.maxVideoByte = _maxVideoByte;
    previewVC.maxImageCount = _maxImageCount;
    [previewVC setPreviewCompleted:^(NSMutableArray *array)
     {
         weakSelf.selectPhotos = array;
     }];
    [previewVC setDoneButtonHandle:^(NSMutableArray *array)
     {
         weakSelf.selectPhotos = array;
         [weakSelf rightBarButtonAction:nil];
     }];
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)originalButtonAction:(id)sender
{
    _isOriginal = YES;
    _originalButton.selected = !_originalButton.selected;
}

- (void)leftBarButtonAction:(id)sender
{
    [_delegate browserCancleSelected];
    [_delegate dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightBarButtonAction:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if (_selectMeidaType != BSAssetMediaTypeVideo)
    {
        __block NSMutableArray *images = [NSMutableArray arrayWithCapacity:_selectPhotos.count];
        [self.selectPhotos enumerateObjectsUsingBlock:^(BSPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            if (_isOriginal)
            {
                [obj getOriginImageWithCompleted:^(UIImage *image)
                {
                    [images addObject:image];
                }];
            }
            else
            {
                [obj getThumbImageWithSize:CGSizeMake(kScreenWidth, KScreenHeight)
                                 completed:^(UIImage *image)
                 {
                     [images addObject:image];
                }];
            }
            
            if (idx == weakSelf.selectPhotos.count - 1)
            {
                [weakSelf.delegate browserDidSelectedImages:images];
            }
        }];
    }
    else
    {
        BSPhotoModel *model = [_selectPhotos firstObject];
        [[BSPTool shareInstance] getVideoWithAsset:model.asset
                                         limitByte:_maxVideoByte
                                        completion:^(NSURL *fileUrl, NSError *error)
        {
            if (fileUrl)
            {
                [weakSelf.delegate browserDidSelectedVideo:fileUrl];
            }
            else
            {
#warning 选择的视频超过大小限制
                return ;
            }
        }];
    }
}

- (void)menuButtonAction:(id)sender
{
    _menuButton.selected = !_menuButton.selected;
    
    if (_menuButton.selected)
    {
        [_albumList show];
        [UIView animateWithDuration:0.3 animations:^{
            _menuButton.imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }
    else
    {
        [_albumList hidden];
        [UIView animateWithDuration:0.3 animations:^{
            _menuButton.imageView.transform = CGAffineTransformMakeRotation(-2*M_PI);
        }];
    }
}

#pragma mark - data request

/**
 请求相册列表
 */
- (void)requestAlbums
{
    __weak typeof(self) weakSelf = self;
    [[BSPTool shareInstance] getAllAlbumsWithMediaType:_mediaType
                                            completion:^(NSArray<BSPAlbumModel *> *models)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.albums = models;
        [strongSelf requestAlbumPhotos:0];
    }];
}

/**
 请求相册中的照片

 @param index 第几个相册
 */
- (void)requestAlbumPhotos:(NSInteger)index
{
    if (index >= _albums.count)
    {
        return;
    }
    BSPAlbumModel *model = _albums[index];
    [_menuButton setTitle:model.name forState:UIControlStateNormal];
    
    __weak typeof(self) weakSelf = self;
    [[BSPTool shareInstance] getAssetsFromFetchResult:model.result
                                           completion:^(NSArray<BSPhotoModel *> *models)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         strongSelf.albumPhotos = models;
     }];
}

#pragma mark - BSPAlbumListDelegate
- (void)selectAlbumAtIndex:(NSInteger)index
{
    [_menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self requestAlbumPhotos:index];
}

#pragma mark - BSPhotoCellDelegate
- (void)selectButtonDidClicked:(BSPhotoCell *)cell
{
    NSInteger index = [_collectionView indexPathForCell:cell].item;
    BSPhotoModel *model = _albumPhotos[index];
    
    NSLog(@"index: %@", @(index));
    
    if (_selectMeidaType != model.mediaType
        && self.selectPhotos.count > 0)
    {
        NSLog(@"类型不同");
#warning 提示选择类型不同
        return;
    }
    
    if ([self.selectPhotos containsObject:model])
    {
        cell.hasSelected = NO;
        [self.selectPhotos removeObject:model];
    }
    else
    {
        if (_selectMeidaType != BSAssetMediaTypeVideo
            && _selectPhotos.count >= _maxImageCount)
        {
            NSLog(@"照片上限");
#warning 提示超出最大选择数
            return;
        }
        else if (_selectMeidaType == BSAssetMediaTypeVideo
                 && _selectPhotos.count >= _maxVideoCount)
        {
            NSLog(@"视频上限");
#warning 提示超出最大选择数
            return;
        }
        else if (_selectMeidaType == BSAssetMediaTypeVideo
                 && model.duration > _maxVideoSec)
        {
            NSLog(@"视频时长上限");
#warning 提示超出时长上限
            return;
        }

        cell.hasSelected = YES;
        [self.selectPhotos addObject:model];
        _selectMeidaType = model.mediaType;
    }
    
    [self refreshButtonStatus];
}

- (void)refreshButtonStatus
{
    if (self.selectPhotos.count > 0)
    {
        _doneButton.enabled = YES;
        _previewButton.enabled = YES;
        NSString *title = [NSString stringWithFormat:@"确定(%@)", @(self.selectPhotos.count)];
        [_doneButton setTitle:title forState:UIControlStateNormal];
    }
    else
    {
        _doneButton.enabled = NO;
        _previewButton.enabled = NO;
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _albumPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BSPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                  forIndexPath:indexPath];
    cell.delegate = self;
    
    BSPhotoModel *model = _albumPhotos[indexPath.item];
    [cell configWithModel:model];
    [cell setHasSelected:[self.selectPhotos containsObject:model]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    BSPhotoModel *model = _albumPhotos[indexPath.item];
    
    __weak typeof(self) weakSelf = self;
    BSPhotoPreviewController *previewVC = [[BSPhotoPreviewController alloc] init];
    if (model.mediaType == BSAssetMediaTypeImage)
    {
        previewVC.photos = _albumPhotos;
        previewVC.selectPhotos = _selectPhotos;
        previewVC.currentIndex = indexPath.item;
        previewVC.maxImageCount = _maxImageCount;
    }
    else
    {
        previewVC.photos = @[model];
        previewVC.maxVideoSec = _maxVideoSec;
        previewVC.maxVideoByte = _maxVideoByte;
    }
    
    previewVC.mediaType = model.mediaType;
    [previewVC setPreviewCompleted:^(NSMutableArray *array)
    {
        weakSelf.selectPhotos = array;
    }];
    [previewVC setDoneButtonHandle:^(NSMutableArray *array)
    {
        weakSelf.selectPhotos = array;
        [weakSelf rightBarButtonAction:nil];
    }];
    
    [self.navigationController pushViewController:previewVC animated:YES];
}

#pragma mark - set
- (void)setAlbums:(NSArray *)albums
{
    _albums = albums;
    [_albumList setAlbums:albums];
}

- (void)setAlbumPhotos:(NSArray *)albumPhotos
{
    [self.selectPhotos removeAllObjects];
    _albumPhotos = albumPhotos;
    [_collectionView reloadData];
}

- (void)setSelectPhotos:(NSMutableArray<BSPhotoModel *> *)selectPhotos
{
    if (selectPhotos.count > 0)
    {
        BSPhotoModel *model = [selectPhotos firstObject];
        _selectMeidaType = model.mediaType;
    }
    _selectPhotos = selectPhotos;
    [self refreshButtonStatus];
    [_collectionView reloadData];
}

@end
