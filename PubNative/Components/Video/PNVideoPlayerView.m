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

@end

@implementation PNVideoPlayerView

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame
              model:(PNVastModel*)model
           delegate:(id<PNVideoPlayerViewDelegate>)delegate
{
    self = [super initWithNibName:NSStringFromClass([PNVideoPlayerView class]) bundle:nil];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(close)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:NULL];
        
        self.trackingEvents = [[NSMutableArray alloc] init];
        self.wasStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
        self.delegate = delegate;
        self.model = model;
        self.skipTime = [model.video_skip_time intValue];
        self.frame = frame;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self close];
    
    self.videoPlayer = nil;
    
    self.vastAd = nil;
    
    [self.loadLabel removeFromSuperview];
    self.loadLabel = nil;
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = self.frame;
    
    self.loadLabel = [[PNProgressLabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
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
    [self.loadContainer addSubview:self.loadLabel];
    
    [self.skipButton setTitle:self.model.skip_video_button forState:UIControlStateNormal];
    [self.skipButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
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



#pragma mark private

- (IBAction)skipAd:(id)sender
{
    [self close];
}

- (IBAction)muteAd:(id)sender;
{
    [self.videoPlayer mute];
    
    if (!self.videoPlayer.silenced)
    {
        [self.muteButton setSelected:NO];
    }
    else
    {
        [self.muteButton setSelected:YES];
    }
}

- (IBAction)learnMoreAd:(id)sender;
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

- (void)videoViewAvailable:(AVPlayerLayer*)videolayer
{
    if (videolayer)
    {
        for(CALayer *layer in self.videoContainer.layer.sublayers)
        {
            [layer removeFromSuperlayer];
        }
        
        videolayer.frame = [self.view bounds];
        [self.videoContainer.layer addSublayer:videolayer];
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
            [self.skipView setHidden:NO];
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
