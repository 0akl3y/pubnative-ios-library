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

NSString * const kPubnativeTestAppToken = @"e1a8e9fcf8aaeff31d1ddaee1f60810957f4c297859216dea9fa283043f8680f";

@interface ViewController ()<PubnativeAdDelegate>

@property (weak, nonatomic) IBOutlet UIView                     *adContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView    *adLoadingIndicator;

@property (nonatomic, assign) Pubnative_AdType  currentType;
@property (nonatomic, strong) UIViewController  *currentAdVC;

@end

@implementation ViewController

#pragma mark NSObject

- (void)dealloc
{
    [self cleanContainer];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.currentAdVC.view removeFromSuperview];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self addCurrentAdVC];
}

#pragma mark - ViewController

- (IBAction)bannerTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_Banner;
    [Pubnative requestAdType:Pubnative_AdType_Banner
                withAppToken:kPubnativeTestAppToken
                 andDelegate:self];
}

- (IBAction)interstitialTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_Interstitial;
    [Pubnative requestAdType:Pubnative_AdType_Interstitial
                withAppToken:kPubnativeTestAppToken
                 andDelegate:self];
}

- (IBAction)iconTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_Icon;
    [Pubnative requestAdType:Pubnative_AdType_Icon
                withAppToken:kPubnativeTestAppToken
                 andDelegate:self];
}

- (IBAction)videoTouchUpInside:(id)sender
{
    [self startLoading];
    [self.currentAdVC.view removeFromSuperview];
    self.currentType = Pubnative_AdType_VideoBanner;
    [Pubnative requestAdType:Pubnative_AdType_VideoBanner
                withAppToken:kPubnativeTestAppToken
                 andDelegate:self];
}

- (void)cleanContainer
{
    [self.currentAdVC.view removeFromSuperview];
    self.currentAdVC = nil;
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

#pragma mark - DELEGATES -

#pragma mark PubnativeAdDelegate

-(void)pnAdDidLoad:(UIViewController *)adVC
{
    [self stopLoading];
    self.currentAdVC = adVC;
    [self addCurrentAdVC];
}

-(void)pnAdDidClose
{
    if(Pubnative_AdType_Banner != self.currentType)
    {
        [self cleanContainer];
    }
}

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

- (void)pnAdDidFail:(NSError *)error
{
    [self stopLoading];
    NSLog(@"Error loading ad - %@", [error description]);
}

@end
