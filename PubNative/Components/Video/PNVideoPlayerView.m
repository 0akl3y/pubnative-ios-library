//
// PNVideoPlayerView.m
//
// Created by Csongor Nagy on 06/03/14.
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

#import "PNVideoPlayerView.h"

@interface PNVideoPlayerView () <PNVideoCacherDelegate>

@property (strong)PNVideoCacher *cacher;

@property (nonatomic, assign)   BOOL                                    autoStart;
@property (nonatomic, strong)   NSObject<PNVideoPlayerViewDelegate>     *delegate;
@property (nonatomic, assign)   CGRect                                  frame;
@property (nonatomic, assign)   BOOL                                    wasStatusBarHidden;
@property (nonatomic, strong)   NSMutableArray                          *trackingEvents;

- (void)skipAd:(id)sender;

@end

@implementation PNVideoPlayerView

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.videoContainer removeFromSuperview];
    self.videoContainer = nil;
    
    [self close];
    
    self.videoPlayer = nil;
    
    self.vastAd = nil;
    
    [self.loadLabel removeFromSuperview];
    self.loadLabel = nil;
    
    [self.skipView removeFromSuperview];
    self.skipView = nil;
    
    [self.skipButton removeFromSuperview];
    self.skipButton = nil;
    
    [self.cacher cancelCaching];
    self.cacher = nil;
    
    self.delegate = nil;
    
    [self.trackingEvents removeAllObjects];
    self.trackingEvents = nil;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.wasStatusBarHidden)
    {
        if (![self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.wasStatusBarHidden)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeLeft;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - PNVideoPlayerView
#pragma mark public

- (void)prepareAd:(VastContainer*)ad
{
    [self ad:ad autoStart:NO];
}

- (void)showAd:(VastContainer*)ad
{
    [self ad:ad autoStart:YES];
}

- (void)close
{
    [self.view removeFromSuperview];

    if(self.delegate && [self.delegate respondsToSelector:@selector(videoCompleted)])
    {
        [self.delegate videoCompleted];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.videoPlayer close];
    self.videoPlayer = nil;
    self.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
              model:(PNVastModel*)model
           delegate:(id<PNVideoPlayerViewDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(close)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:NULL];
        
        self.trackingEvents = [[NSMutableArray alloc] init];
        self.wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        self.delegate = delegate;
        self.skipTime = [model.video_skip_time intValue];
        self.view.backgroundColor = [UIColor blackColor];
        self.frame = frame;
        self.view.frame = self.frame;
        
        self.videoContainer = [[UIView alloc] initWithFrame:frame];
        [self.view addSubview:self.videoContainer];
        
        UIView *gestureView = [[UIView alloc] initWithFrame:frame];
        gestureView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tapGesture:)];
        [self.view addSubview:gestureView];
        [gestureView addGestureRecognizer:tapRecognizer];
        
        self.loadLabel = [[PNProgressLabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 40, 30, 30)];
        [self.loadLabel setBorderWidth: 6.0];
        [self.loadLabel setColorTable: @{
                                         NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor clearColor],
                                         NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor whiteColor],
                                         NSStringFromProgressLabelColorTableKey(ProgressLabelFillColor):[UIColor clearColor]
                                         }];
        [self.loadLabel setTextColor:[UIColor whiteColor]];
        [self.loadLabel setShadowColor:[UIColor darkGrayColor]];
        self.loadLabel.shadowOffset = CGSizeMake(1, 1);
        [self.loadLabel setTextAlignment:NSTextAlignmentCenter];
        [self.loadLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [self.view addSubview:self.loadLabel];
        [self.view bringSubviewToFront:self.loadLabel];
        
        self.skipView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 170,
                                                                 self.view.frame.size.height - 40,
                                                                 160,
                                                                 30)];
        
        self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.skipButton addTarget:self
                            action:@selector(skipAd:)
                  forControlEvents:UIControlEventTouchDown];
        [self.skipButton setTitle:model.skip_video_button forState:UIControlStateNormal];
        [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.skipButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.skipButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
        self.skipButton.frame = CGRectMake(0,
                                           0,
                                           160,
                                           30);
        [self.skipButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [self.skipButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        
        self.muteView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 60,
                                                                 50)];
        
        self.muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.muteButton addTarget:self
                            action:@selector(muteAd:)
                  forControlEvents:UIControlEventTouchDown];
        [self.muteButton setTitle:@"Mute" forState:UIControlStateNormal];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.muteButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.muteButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
        self.muteButton.frame = self.muteView.frame;
        [self.muteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.muteButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        
        [self.muteView addSubview:self.muteButton];
        [self.view addSubview:self.muteView];
        [self.view bringSubviewToFront:self.muteView];
        
        self.learnMoreView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-90, 5, 160, 30)];
        
        self.learnMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.learnMoreButton addTarget:self
                                 action:@selector(learnMoreAd:)
                       forControlEvents:UIControlEventTouchDown];
        [self.learnMoreButton setTitle:@"Learn More" forState:UIControlStateNormal];
        [self.learnMoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.learnMoreButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.learnMoreButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
        self.learnMoreButton.frame = CGRectMake(0, 0, 160, 30);
        [self.learnMoreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.learnMoreButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        
        [self.learnMoreView addSubview:self.learnMoreButton];
        [self.view addSubview:self.learnMoreView];
        [self.view bringSubviewToFront:self.learnMoreView];
    }
    
    return self;
}

#pragma mark private

- (void)skipAd:(id)sender
{
    [self close];
}

- (void)muteAd:(id)sender
{
    [self.videoPlayer mute];
}

- (void)learnMoreAd:(id)sender
{
    [self tapGesture:nil];
}

- (void)ad:(VastContainer*)ad autoStart:(BOOL)autoStart
{
    self.vastAd = ad;
    self.autoStart = autoStart;
    
    self.cacher = [[PNVideoCacher alloc] initWithURL:self.vastAd.mediaFile];
    self.cacher.delegate = self;
    [self.cacher startCaching];
}

- (void)tapGesture:(UIGestureRecognizer*)sender
{
    [self.trackingEvents addObject:@"clickThrough"];
    if ((NSNull*)self.vastAd.clickThrough != [NSNull null])
    {
        [PNTrackingManager trackURLString:self.vastAd.clickThrough completion:nil];
    }
    if(self.delegate)
    {
        [self.delegate videoClicked:self.vastAd.mediaFile];
    }
}

#pragma mark - DELEGATES -

#pragma mark PNVideoCacherDelegate

- (void)videoCacherDidCache:(NSString *)videoFile
{
    self.videoPlayer = [[PNVideoPlayer alloc] initWithDelegate:self];
    [self.videoPlayer open:videoFile autoplay:self.autoStart];
    if(self.delegate)
    {
        [self.delegate videoReady];
    }
}

- (void)videoCacherDidFail:(NSError *)error
{
    if(self.delegate)
    {
        [self.delegate videoError:0 details:@"Ad video URL null"];
    }
}

#pragma mark PNVideoPlayerDelegate

- (void)videoViewAvailable:(UIView*)videoView
{
    if (videoView)
    {
        videoView.frame = [self.videoContainer bounds];
        [self.videoContainer addSubview:videoView];
    }
}

- (void)playbackPreparing
{
    if(self.delegate)
    {
        [self.delegate videoPreparing];
    }
    [self.videoPlayer pause];
}

- (void)playbackStartedWithDuration:(NSTimeInterval)duration
{
    [self.trackingEvents addObject:@"trackingStart"];
    if ((NSNull*)self.vastAd.trackingStart != [NSNull null])
    {
        [PNTrackingManager trackURLString:self.vastAd.trackingStart completion:nil];
    }
    
    if(self.delegate)
    {
        [self.delegate videoStartedWithDuration:duration];
    }
}

- (void)playbackCompleted
{
    [self.trackingEvents addObject:@"trackingComplete"];
    if ((NSNull*)self.vastAd.trackingComplete != [NSNull null])
    {
        [PNTrackingManager trackURLString:self.vastAd.trackingComplete completion:nil];
    }
    
    [self.loadLabel removeFromSuperview];
    self.loadLabel = nil;
    [self.skipView removeFromSuperview];
    self.skipView = nil;
    [self.videoPlayer stop];
    
    if(self.delegate)
    {
        [self.delegate videoCompleted];
    }
}

- (void)playbackProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration
{
    if (currentTime > 0)
    {
        if (currentTime >= duration/4 &&
            currentTime < duration/2 &&
            ![self.trackingEvents containsObject:@"trackingFirstQuartile"])
        {
            [self.trackingEvents addObject:@"trackingFirstQuartile"];
            if ((NSNull*)self.vastAd.trackingFirstQuartile != [NSNull null])
            {
                [PNTrackingManager trackURLString:self.vastAd.trackingFirstQuartile completion:nil];
            }
        }
        else if (currentTime > duration/2-1 &&
                 currentTime < duration/2+1 &&
                 ![self.trackingEvents containsObject:@"trackingMidpoint"])
        {
            [self.trackingEvents addObject:@"trackingMidpoint"];
            if ((NSNull*)self.vastAd.trackingMidpoint != [NSNull null])
            {
                [PNTrackingManager trackURLString:self.vastAd.trackingMidpoint completion:nil];
            }
        }
        else if (currentTime >= duration/4*3 &&
                 currentTime < duration &&
                 ![self.trackingEvents containsObject:@"trackingThirdQuartile"])
        {
            [self.trackingEvents addObject:@"trackingThirdQuartile"];
            if ((NSNull*)self.vastAd.trackingThirdQuartile != [NSNull null])
            {
                [PNTrackingManager trackURLString:self.vastAd.trackingThirdQuartile completion:nil];
            }
        }
        
        [self.loadLabel setProgress:currentTime/duration];
        [self.loadLabel setStartDegree:0.0];
        [self.loadLabel setStartDegree:359.9];
        
        if (currentTime >= self.skipTime)
        {
            [self.skipView addSubview:self.skipButton];
            [self.view addSubview:self.skipView];
            [self.view bringSubviewToFront:self.skipView];
        }
        
        self.loadLabel.text = [NSString stringWithFormat:@"%.f", duration - currentTime];
        
        if(self.delegate)
        {
            [self.delegate videoProgress:currentTime duration:duration];
        }
    }
}

- (void)playbackError:(NSInteger)errorCode
{
    if(self.delegate)
    {
        [self.delegate videoError:errorCode
                          details:[NSString stringWithFormat:@"Ad video playback failed %li", (long)errorCode]];
    }
}

@end
