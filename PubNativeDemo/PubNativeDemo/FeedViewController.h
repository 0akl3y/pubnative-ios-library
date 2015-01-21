//
//  FeedViewController.h
//  PubNativeDemo
//
//  Created by David Martin on 08/01/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNVideoTableViewCell.h"

@interface FeedViewController : UIViewController

- (void)loadAdWithAppToken:(NSString*)appToken;
- (IBAction)dismiss:(id)sender;

@end
