//
//  AdViewController.m
//  PubNativeDemo
//
//  Created by David Martin on 05/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "AdViewController.h"

@interface AdViewController ()

@property (weak, nonatomic) IBOutlet UIView *adContainer;

@property (strong, nonatomic) UIViewController *currentAdVC;

@end

@implementation AdViewController

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.currentAdVC)
    {
        [self.currentAdVC.view removeFromSuperview];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark AdViewController

- (void)presentAdWithViewController:(UIViewController*)adViewController
                               type:(Pubnative_AdType)type
{
    self.currentAdVC = adViewController;
    
    switch (type)
    {
        case Pubnative_AdType_Banner:
        {
            self.currentAdVC.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.adContainer.frame), 100);
            self.currentAdVC.view.center = [self.adContainer convertPoint:self.adContainer.center
                                                                 fromView:self.view];
            self.currentAdVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                                     UIViewAutoresizingFlexibleHeight |
                                                     UIViewAutoresizingFlexibleTopMargin |
                                                     UIViewAutoresizingFlexibleBottomMargin;
            
            self.currentAdVC.view.alpha = 0;
            
            [self.adContainer addSubview:self.currentAdVC.view];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.currentAdVC.view.alpha = 1;
                             }];
        }
        break;
            
        case Pubnative_AdType_VideoBanner:
        {
            self.currentAdVC.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.adContainer.frame), 150);
            self.currentAdVC.view.center = [self.adContainer convertPoint:self.adContainer.center
                                                                 fromView:self.view];
            self.currentAdVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                     UIViewAutoresizingFlexibleRightMargin |
                                                     UIViewAutoresizingFlexibleTopMargin |
                                                     UIViewAutoresizingFlexibleBottomMargin;
            self.currentAdVC.view.alpha = 0;

            [self.adContainer addSubview:self.currentAdVC.view];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.currentAdVC.view.alpha = 1;
                             }];
        }
        break;
            
        case Pubnative_AdType_Icon:
        {
            self.currentAdVC.view.frame = CGRectMake(0, 0, 100, 100);
            self.currentAdVC.view.center = [self.adContainer convertPoint:self.adContainer.center
                                                                 fromView:self.view];
            
            self.currentAdVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                     UIViewAutoresizingFlexibleRightMargin |
                                                     UIViewAutoresizingFlexibleTopMargin |
                                                     UIViewAutoresizingFlexibleBottomMargin;
            
            self.currentAdVC.view.alpha = 0;

            [self.adContainer addSubview:self.currentAdVC.view];
            
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.currentAdVC.view.alpha = 1;
                             }];
        }
        break;
            
        default: break;
    }
}

- (IBAction)doneButtonPushed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
