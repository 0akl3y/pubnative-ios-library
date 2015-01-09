//
//  PNTableViewCellFeed.m
//  PubNativeDemo
//
//  Created by David Martin on 08/01/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "PNVideoTableViewCell.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"
#import "PNVastModel.h"
#import "PNVideoPlayerView.h"
#import "VastXMLParser.h"

NSString * const kPNTableViewCellContentViewFrameKey = @"contentView.frame";
FOUNDATION_IMPORT NSString * const kPNTableViewManagerClearAllNotification;

@interface PNVideoTableViewCell () <VastXMLParserDelegate, PNVideoPlayerViewDelegate>

@property (nonatomic, strong)   UIImageView         *banner;
@property (nonatomic, strong)   UIButton            *bannerButton;
@property (nonatomic, strong)   PNVideoPlayerView   *playerContainer;
@property (nonatomic, strong)   VastContainer       *vastModel;
@property (nonatomic, strong)   UIButton            *fullscreenButton;
@property (nonatomic, strong)   UIView              *fullscreenButtonView;

@end

@implementation PNVideoTableViewCell

#pragma mark NSObject

- (void)dealloc
{
    self.model = nil;
    
    [self.bannerButton removeFromSuperview];
    self.bannerButton = nil;
    
    [self.banner removeFromSuperview];
    self.banner = nil;
    
    if(self.playerContainer)
    {
        [self.playerContainer.videoPlayer stop];
        [self.playerContainer.view removeFromSuperview];
    }
    self.playerContainer = nil;
    
    
    self.vastModel = nil;

    [self.fullscreenButton removeFromSuperview];
    self.fullscreenButton = nil;
    
    [self.fullscreenButtonView removeFromSuperview];
    self.fullscreenButtonView = nil;
}

#pragma mark UITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.banner = [[UIImageView alloc] initWithFrame:self.frame];
        self.banner.contentMode = UIViewContentModeScaleAspectFit;
        self.banner.hidden = YES;
        self.backgroundView = self.banner;
    
        self.bannerButton = [[UIButton alloc] initWithFrame:self.frame];
        [self.bannerButton addTarget:self
                              action:@selector(bannerButtonTouchUpInside:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.bannerButton];
    
        self.playerContainer = [[PNVideoPlayerView alloc] initWithFrame:self.frame
                                                                  model:nil
                                                               delegate:self];
        self.playerContainer.skipView.hidden = YES;
        self.playerContainer.learnMoreView.hidden = YES;
        self.playerContainer.loadLabel.hidden = YES;
        self.playerContainer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.playerContainer.view.hidden = YES;
        [self.contentView addSubview:self.playerContainer.view];
        
        self.fullscreenButtonView = [[UIView alloc] initWithFrame:CGRectMake(self.playerContainer.view.frame.origin.x + self.playerContainer.view.frame.size.width - 50,
                                                                             self.playerContainer.view.frame.origin.y + 25,
                                                                             100,
                                                                             50)];
        self.fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fullscreenButton addTarget:self
                                  action:@selector(fullScreenTouchDown:)
                        forControlEvents:UIControlEventTouchDown];
        [self.fullscreenButton setTitle:@"Full screen" forState:UIControlStateNormal];
        [self.fullscreenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.fullscreenButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.fullscreenButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
        self.fullscreenButton.frame = CGRectMake(0,
                                                 0,
                                                 self.fullscreenButtonView.frame.size.width,
                                                 self.fullscreenButtonView.frame.size.height);
        [self.fullscreenButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.fullscreenButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [self.fullscreenButtonView addSubview:self.fullscreenButton];
        [self.playerContainer.view addSubview:self.fullscreenButtonView];
        
        [self addObserver:self
               forKeyPath:kPNTableViewCellContentViewFrameKey
                  options:NSKeyValueObservingOptionNew
                  context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearCell:)
                                                     name:kPNTableViewManagerClearAllNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark PNTableViewCellFeed

- (void)willDisplayCell
{
    self.banner.hidden = YES;
    self.playerContainer.view.hidden = YES;
    self.fullscreenButtonView.hidden = YES;
    
    [self loadAd];
}

- (void)didEndDisplayingCell
{
    if(self.playerContainer)
    {
        self.playerContainer.view.hidden = YES;
        [self.playerContainer.videoPlayer stop];
        
        if(self.playerContainer.view.superview != self.contentView)
        {
            [self.playerContainer.view removeFromSuperview];
            self.playerContainer.view.frame = self.contentView.frame;
            self.playerContainer.videoContainer.frame = self.contentView.frame;
            self.playerContainer.videoPlayer.player.view.frame = self.contentView.frame;
            [self.contentView addSubview:self.playerContainer.view];
        }
    }
    
    [self.fullscreenButton setTitle:@"Full screen" forState:UIControlStateNormal];
    self.fullscreenButtonView.hidden = YES;
    
    if(self.banner)
    {
        [self.banner setImage:nil];
        self.banner.hidden = YES;
    }
}

- (void)clearCell:(NSNotification*)notification
{
    [self didEndDisplayingCell];
}

- (void)setModel:(PNNativeVideoAdModel*)model
{
    _model = model;
    [self loadAd];
}

- (void)loadAd
{
    self.banner.hidden = NO;
    
    PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
    renderItem.banner = self.banner;
    [PNAdRenderingManager renderNativeAdItem:renderItem
                                      withAd:self.model];
    
    PNVastModel *vast = [self.model.vast firstObject];
    if (vast.ad)
    {
        [[VastXMLParser sharedParser] parseString:vast.ad andDelegate:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([kPNTableViewCellContentViewFrameKey isEqualToString:keyPath])
    {
        if([object valueForKeyPath:keyPath] != [NSNull null])
        {
            CGRect frame = [[object valueForKeyPath:keyPath] CGRectValue];
            self.fullscreenButtonView.frame = CGRectMake(frame.origin.x + frame.size.width - 100,
                                                         frame.origin.y,
                                                         100,
                                                         50);
            
            self.bannerButton.frame = frame;
            
            if(self.playerContainer.view.superview == self.contentView)
            {
                self.playerContainer.view.frame = frame;
                self.playerContainer.videoContainer.frame = frame;
                self.playerContainer.videoPlayer.player.view.frame = frame;
            }
        }
    }
}

- (void)fullScreenTouchDown:(id)sender
{
    if(self.playerContainer.view.superview == self.contentView)
    {
        [self.playerContainer.view removeFromSuperview];
        UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if(presentingController.presentedViewController)
        {
            presentingController = presentingController.presentedViewController;
        }
        
        CGRect newFrame = presentingController.view.frame;
        self.playerContainer.view.frame = newFrame;
        self.playerContainer.videoContainer.frame = newFrame;
        self.playerContainer.videoPlayer.player.view.frame = newFrame;
        [presentingController.view addSubview:self.playerContainer.view];
        [self.fullscreenButton setTitle:@"Done" forState:UIControlStateNormal];
    }
    else
    {
        [self.playerContainer.view removeFromSuperview];
        self.playerContainer.view.frame = self.contentView.frame;
        self.playerContainer.videoContainer.frame = self.contentView.frame;
        self.playerContainer.videoPlayer.player.view.frame = self.contentView.frame;
        [self.contentView addSubview:self.playerContainer.view];
        [self.fullscreenButton setTitle:@"Full screen" forState:UIControlStateNormal];
    }
}

- (void)bannerButtonTouchUpInside:(id)sender
{
    [self openOffer];
}

- (void)openOffer
{
    if(self.model &&
       self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

- (void)setVideoHidden:(BOOL)hidden
{
    self.playerContainer.view.hidden = hidden;
    self.fullscreenButtonView.hidden = hidden;
}

- (void)didRotate:(NSNotification*)notification
{
    if(self.playerContainer.view.superview != self.contentView)
    {
        UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
        if(presentingController.presentedViewController)
        {
            presentingController = presentingController.presentedViewController;
        }
        
        CGRect newFrame = presentingController.view.frame;
        self.playerContainer.view.frame = newFrame;
        self.playerContainer.videoContainer.frame = newFrame;
        self.playerContainer.videoPlayer.player.view.frame = newFrame;
    }
}

#pragma mark - DELEGATES -

#pragma mark VastXMLParserDelegate

- (void)parserReady:(VastContainer*)ad
{
    self.vastModel = ad;
    [self.playerContainer prepareAd:self.vastModel];
}

#pragma mark PNVideoPlayerViewDelegate

- (void)videoClicked:(NSString*)clickThroughUrl
{
    [self openOffer];
}
- (void)videoReady
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playerContainer.view.hidden = NO;
        self.fullscreenButtonView.hidden = NO;
        [self.playerContainer.videoPlayer play];
    });
}
- (void)videoPreparing {}
- (void)videoStartedWithDuration:(NSTimeInterval)duration {}
- (void)videoCompleted
{
    self.playerContainer.view.hidden = YES;
    self.fullscreenButtonView.hidden = YES;
}
- (void)videoError:(NSInteger)errorCode details:(NSString*)description {}
- (void)videoProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {}
- (void)videoTrackingEvent:(NSString*)event {}

@end
