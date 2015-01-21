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

@property (nonatomic, strong) UIImageView       *banner;
@property (nonatomic, strong) UIButton          *bannerButton;
@property (nonatomic, strong) UILabel           *cta_label;
@property (nonatomic, strong) PNVideoPlayerView *playerContainer;
@property (nonatomic, strong) VastContainer     *vastModel;
@property (nonatomic, strong) NSTimer           *impressionTimer;
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
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    self.vastModel = nil;
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
        
        UIImage *linkImage = [UIImage imageNamed:@"PnFullScreen.png"];
        [self.playerContainer.learnMoreButton setImage:linkImage forState:UIControlStateNormal];
        [self.contentView addSubview:self.playerContainer.view];
    
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
    
    [self.impressionTimer invalidate];
    self.impressionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(impressionTimerTick:) userInfo:nil repeats:NO];
    
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
            self.playerContainer.videoPlayer.layer.frame = self.contentView.frame;
            [self.contentView addSubview:self.playerContainer.view];
        }
    }
    
    if(self.banner)
    {
        [self.banner setImage:nil];
        self.banner.hidden = YES;
    }
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
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
    renderItem.cta_text = self.cta_label;
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
            self.bannerButton.frame = frame;
            
            if(self.playerContainer.view.superview == self.contentView)
            {
                self.playerContainer.view.frame = frame;
                self.playerContainer.videoPlayer.layer.frame = frame;
            }
        }
    }
}

- (void)openFullScreen
{
    [self.playerContainer.view removeFromSuperview];
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if(presentingController.presentedViewController)
    {
        presentingController = presentingController.presentedViewController;
    }
    
    CGRect newFrame = presentingController.view.frame;
    self.playerContainer.view.frame = newFrame;
    self.playerContainer.videoPlayer.layer.frame = newFrame;
    [presentingController.view addSubview:self.playerContainer.view];
}

- (void)bannerButtonTouchUpInside:(id)sender
{
    [self openOffer];
}

- (void)openOffer
{
    if(self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

- (void)setVideoHidden:(BOOL)hidden
{
    self.playerContainer.view.hidden = hidden;
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
        self.playerContainer.videoPlayer.layer.frame = newFrame;
    }
}

- (void)ctaLabelTouchUpInside:(id)sender
{
    [self openOffer];
}

- (void)impressionTimerTick:(NSTimer *)timer
{
    if([timer isValid])
    {
        [PNTrackingManager trackImpressionWithAd:self.model
                                      completion:nil];
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
    if(self.playerContainer.view.superview == self.contentView)
    {
        [self openFullScreen];
    }
    else
    {
        [self openOffer];
    }
}
- (void)videoReady
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playerContainer.view.hidden = NO;
        [self.playerContainer.videoPlayer play];
    });
}
- (void)videoPreparing {}
- (void)videoStartedWithDuration:(NSTimeInterval)duration {}
- (void)videoCompleted
{
    self.playerContainer.view.hidden = YES;
}
- (void)videoError:(NSInteger)errorCode details:(NSString*)description {}
- (void)videoProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {}
- (void)videoTrackingEvent:(NSString*)event {}

@end
