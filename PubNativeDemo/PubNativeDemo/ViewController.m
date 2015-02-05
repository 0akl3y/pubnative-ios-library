//
// ViewController.m
//
// Created by Csongor Nagy on 11/11/14.
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

#import "ViewController.h"
#import "Pubnative.h"
#import "FeedViewController.h"
#import "SettingsViewController.h"

NSString * const kPubnativeTestAppToken = @"e1a8e9fcf8aaeff31d1ddaee1f60810957f4c297859216dea9fa283043f8680f";

@interface ViewController ()<PubnativeAdDelegate, SettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView                     *adContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *adLoadingIndicator;
@property (strong, nonatomic) PNAdRequestParameters             *parameters;

@property (nonatomic, assign) Pubnative_AdType  currentType;
@property (nonatomic, strong) UIViewController  *currentAdVC;

- (IBAction)settingsPressed:(id)sender;

@end

@implementation ViewController

#pragma mark NSObject

- (void)dealloc
{
    [self cleanContainer];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.parameters = [PNAdRequestParameters requestParameters];
    [self.parameters fillWithDefaults];
    self.parameters.app_token = kPubnativeTestAppToken;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.currentAdVC.view removeFromSuperview];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self addCurrentAdVC];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - ViewController Methods

- (void)addCurrentAdVC
{
    switch (self.currentType)
    {
        case Pubnative_AdType_Banner:
        {
            self.currentAdVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
            self.currentAdVC.view.center = [self.adContainer convertPoint:self.adContainer.center fromView:self.view];
            [self.adContainer addSubview:self.currentAdVC.view];
            self.currentAdVC.view.alpha = 0;
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.currentAdVC.view.alpha = 1;
                             }];
        }
            break;
        case Pubnative_AdType_VideoBanner:
        {
            self.currentAdVC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 150);
            self.currentAdVC.view.center = [self.adContainer convertPoint:self.adContainer.center fromView:self.view];
            [self.adContainer addSubview:self.currentAdVC.view];
            self.currentAdVC.view.alpha = 0;
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.currentAdVC.view.alpha = 1;
                             }];
        }
            break;
        case Pubnative_AdType_Interstitial:
        {
            [self presentViewController:self.currentAdVC animated:YES completion:nil];
        }
            break;
        case Pubnative_AdType_Icon:
        {
            self.currentAdVC.view.frame = CGRectMake(0, 0, 100, 100);
            self.currentAdVC.view.center = [self.adContainer convertPoint:self.adContainer.center fromView:self.view];
            [self.adContainer addSubview:self.currentAdVC.view];
            self.currentAdVC.view.alpha = 0;
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.currentAdVC.view.alpha = 1;
                             }];
        }
            break;
    }
}

#pragma mark - Action Methods

- (IBAction)settingsPressed:(id)sender
{
    SettingsViewController *settings = [[SettingsViewController alloc] initWitParams:self.parameters
                                                                         andDelegate:self];
    [self presentViewController:settings animated:YES completion:nil];
}

- (IBAction)bannerTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_Banner;
    [Pubnative requestAdType:Pubnative_AdType_Banner
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)interstitialTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_Interstitial;
    [Pubnative requestAdType:Pubnative_AdType_Interstitial
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)iconTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_Icon;
    [Pubnative requestAdType:Pubnative_AdType_Icon
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)videoTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_VideoBanner;
    [Pubnative requestAdType:Pubnative_AdType_VideoBanner
              withParameters:self.parameters
                 andDelegate:self];
}

- (IBAction)videoFeedTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = -1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *feedVC = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self presentViewController:feedVC animated:YES completion:^{
        [feedVC loadAdWithParameters:self.parameters
                         requestType:PNAdRequest_Native_Video
                         andFeedType:PNFeed_Native_Video];
    }];
}

- (IBAction)adFeedTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = -1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *feedVC = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self presentViewController:feedVC animated:YES completion:^{
        [feedVC loadAdWithParameters:self.parameters
                         requestType:PNAdRequest_Native
                         andFeedType:PNFeed_Native_Ad];
    }];
}

- (IBAction)scrollFeedTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = -1;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *feedVC = [storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    [self presentViewController:feedVC animated:YES completion:^{
        [feedVC loadAdWithParameters:self.parameters
                         requestType:PNAdRequest_Native
                         andFeedType:PNFeed_Native_Scroller];
    }];
}

- (void)cleanContainer
{
    [self.currentAdVC.view removeFromSuperview];
    self.currentAdVC = nil;
    self.currentType = -1;
}

- (void)startLoading
{
    [self cleanContainer];
    [self.adLoadingIndicator startAnimating];
}

- (void)stopLoading
{
    [self.adLoadingIndicator stopAnimating];
}

#pragma mark - SettingsViewControllerDelegate Methods

- (void)willCloseWithParams:(PNAdRequestParameters*)parameters
{
    self.parameters = parameters;
}

#pragma mark - PubnativeAdDelegate Methods

-(void)pnAdDidLoad:(UIViewController *)adVC
{
    [self stopLoading];
    self.currentAdVC = adVC;
    [self addCurrentAdVC];
}

-(void)pnAdDidClose
{
    if (Pubnative_AdType_VideoBanner == self.currentType)
    {
        [(PNVideoBannerViewController*)self.currentAdVC prepareVideoPlayer];
    }
    else if(Pubnative_AdType_Banner != self.currentType)
    {
        [self cleanContainer];
    }
}

- (void)pnAdDidFail:(NSError *)error
{
    [self stopLoading];
    NSLog(@"Error loading ad - %@", [error description]);
}

@end
