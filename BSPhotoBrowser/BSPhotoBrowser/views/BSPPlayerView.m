//
//  BSPPlayerView.m
//  BSPhotoBrowser
//
//  Created by LonlyCat on 2017/5/3.
//  Copyright © 2017年 LonlyCat. All rights reserved.
//

#import "BSPPlayerView.h"
@import AVFoundation;

@interface BSPPlayerView ()

@property (nonatomic, strong) NSURL *videoPath;

@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation BSPPlayerView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSURL *)videoPath previewImage:(UIImage *)previewImage
{
    NSParameterAssert(videoPath != nil);
    NSParameterAssert(previewImage != nil);
    
    self = [super initWithFrame:frame];
    if (self) {
        _videoPath = videoPath;
        _previewImage = previewImage;
        
        AVAsset *asset = [AVAsset assetWithURL:_videoPath];
        
        __weak typeof(self)weakSelf = self;
        [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
            dispatch_async( dispatch_get_main_queue(), ^{
                [weakSelf prepareToPlayAsset:asset];
            });
        }];
    }
    return self;
}

- (void)dealloc {
    [_player pause];
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Prepare to play asset, URL

- (void)prepareToPlayAsset:(AVAsset *)asset {
    NSError *error = nil;
    AVKeyValueStatus keyStatus = [asset statusOfValueForKey:@"playable" error:&error];
    if (keyStatus == AVKeyValueStatusFailed) {
        [self assetFailedToPrepareForPlayback:error];
        return;
    }
    
    if (!asset.playable) {
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"Item cannot be played" code:0 userInfo:nil];
        
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        return;
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_playerLayer];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = self.bounds;
    [self.playButton setImage:[UIImage imageNamed:@"browser_play"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_loadingCompleted)
        {
            _loadingCompleted();
        }
    });
}

#pragma mark - button action
- (void)playButtonAction:(UIButton *)sender
{
    _playButton.hidden = YES;
    
    [self.player play];
}

#pragma mark - Error Handle

- (void)assetFailedToPrepareForPlayback:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Video cannot be played" message:@"Video cannot be played" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Notification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    
    _playButton.hidden = NO;
}

#pragma mark - Public

- (void)play {
    if (!self.player) {
        return;
    }
    [self.player play];
}

- (void)pause {
    if (!self.player) {
        return;
    }
    [self.player pause];
}

@end
