//
// PNVideoBannerViewController.m
//
// Created by Csongor Nagy on 12/11/14.
// Copyright (c) 2014 PubNative
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PNVideoBannerViewController.h"

#import "VastXMLParser.h"
#import "PNVideoPlayerView.h"
#import "PNInterstitialAdViewController.h"

#import "PNAdConstants.h"
#import "PNAdRequest.h"
#import "PNNativeVideoAdModel.h"
#import "PNNativeAdRenderItem.h"
#import "PNAdRenderingManager.h"

@interface PNVideoBannerViewController () <VastXMLParserDelegate, PNVideoPlayerViewDelegate, PubnativeAdDelegate>

@property (nonatomic, weak) IBOutlet    UIImageView                     *bannerView;
@property (nonatomic, weak) IBOutlet    UIButton                        *playButton;

@property (nonatomic, strong)           PNNativeVideoAdModel            *model;
@property (nonatomic, strong)           VastContainer                   *vastModel;

@property (nonatomic, strong)           UIWindow                        *appWindow;
@property (nonatomic, strong)           UIWindow                        *adWindow;

@property (nonatomic, strong)           PNVideoPlayerView               *videoAdPlayer;
@property (nonatomic, strong)           PNInterstitialAdViewController  *interstitialVC;
@property (nonatomic, strong)           NSTimer                         *impressionTimer;


- (IBAction)playButtonPressed:(id)sender;
- (IBAction)installButtonPressed:(id)sender;

@end

@implementation PNVideoBannerViewController

#pragma mark - NSObject

- (void)dealloc
{
    self.delegate = nil;
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    self.model = nil;
    self.vastModel = nil;
    
    self.appWindow = nil;
    self.adWindow = nil;
    
    self.videoAdPlayer = nil;
    self.interstitialVC = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.model)
    {
        // Initialize the view
        PNNativeAdRenderItem *renderItem = [PNNativeAdRenderItem renderItem];
        renderItem.banner = self.bannerView;
        [PNAdRenderingManager renderNativeAdItem:renderItem withAd:self.model];
        [self.bannerView setClipsToBounds:YES];
        
        // Parse model
        PNVastModel *vast = [self.model.vast firstObject];
        if (vast.ad)
        {
            [[VastXMLParser sharedParser] parseString:vast.ad andDelegate:self];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdWillShow)])
    {
        [self.delegate pnAdWillShow];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidShow)])
    {
        [self.delegate pnAdDidShow];
    }
    
    [self startImpressionTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdWillClose)])
    {
        [self.delegate pnAdWillClose];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(pnAdDidClose)])
    {
        [self.delegate pnAdDidClose];
    }
    
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
}

#pragma mark - PNVideoBannerViewController

#pragma mark public

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                          model:(PNNativeVideoAdModel*)model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.model = model;
        self.appWindow  = [UIApplication sharedApplication].keyWindow;
        self.adWindow   = [[UIWindow alloc] initWithFrame:self.appWindow.rootViewController.view.frame];
    }
    return self;
}

#pragma mark private

- (void)startImpressionTimer
{
    [self.impressionTimer invalidate];
    self.impressionTimer = nil;
    
    self.impressionTimer = [NSTimer scheduledTimerWithTimeInterval:kPNAdConstantShowTimeForImpression
                                                            target:self
                                                          selector:@selector(impressionTimerTick:)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)impressionTimerTick:(NSTimer *)timer
{
    if(self.model)
    {
        [PNTrackingManager trackImpressionWithAd:self.model completion:nil];
    }
}


#pragma mark IBActions

- (IBAction)playButtonPressed:(id)sender
{
    self.playButton.hidden = YES;
    
    [self.videoAdPlayer.videoPlayer play];
    
    self.adWindow.rootViewController = self.videoAdPlayer;
    [self.adWindow makeKeyAndVisible];
    
    __block CGSize adWindowSize = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame.size;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            weakSelf.videoAdPlayer.view.transform = CGAffineTransformIdentity;
                            weakSelf.videoAdPlayer.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                            weakSelf.videoAdPlayer.view.frame = CGRectMake(0.0f,
                                                                           0.0f,
                                                                           adWindowSize.width,
                                                                           adWindowSize.height);
                            
                            weakSelf.videoAdPlayer.view.center = CGPointMake(adWindowSize.width/2.0,
                                                                             adWindowSize.height/2.0);
                        }
                     completion:nil];
}

- (IBAction)installButtonPressed:(id)sender
{
    if (self.model && self.model.click_url)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.model.click_url]];
    }
}

#pragma mark - DELEGATES 

#pragma mark VastXMLParserDelegate

- (void)parserReady:(VastContainer*)ad
{
    self.vastModel = ad;
    [self prepareVideoPlayer];
}

- (void)prepareVideoPlayer
{
    CGRect viewFrame = self.appWindow.rootViewController.view.frame;
    PNVastModel *vast =[self.model.vast firstObject];
    self.videoAdPlayer = [[PNVideoPlayerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             viewFrame.size.height,
                                                                             viewFrame.size.width)
                                                            model:vast
                                                         delegate:self];
    [self.videoAdPlayer prepareAd:self.vastModel];
}

#pragma mark PNVideoPlayerViewDelegate

- (void)videoClicked:(NSString*)clickThroughUrl
{
}

- (void)videoReady
{
    self.playButton.hidden = NO;
}

- (void)videoPreparing
{
    
}

- (void)videoStartedWithDuration:(NSTimeInterval)duration
{
    
}

- (void)videoCompleted
{
    // Change video for interstitialVC
    self.interstitialVC = [[PNInterstitialAdViewController alloc] initWithNibName:NSStringFromClass([PNInterstitialAdViewController class])
                                                                           bundle:nil
                                                                            model:self.model];
    self.interstitialVC.delegate = self;
    self.adWindow.rootViewController = self.interstitialVC;
}

- (void)videoError:(NSInteger)errorCode details:(NSString*)description
{
}

- (void)videoProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration
{
    
}

- (void)videoTrackingEvent:(NSString*)event
{
    
}

#pragma mark PNAdViewControllerDelegate

- (void)pnAdWillClose
{
    [self.appWindow makeKeyAndVisible];
    [self prepareVideoPlayer];
}

@end
