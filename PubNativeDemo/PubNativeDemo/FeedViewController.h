//
//  FeedViewController.h
//  PubNativeDemo
//
//  Created by David Martin on 08/01/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNAdRequest.h"
#import "PNVideoTableViewCell.h"
#import "PNAdWallCell.h"
#import "PNScrollerContainerCell.h"

@interface FeedViewController : UIViewController

- (void)loadAdWithParameters:(PNAdRequestParameters*)parameters
                 requestType:(PNAdRequestType)reuqestType
                 andFeedType:(PNFeedType)feedType;
- (IBAction)dismiss:(id)sender;

@end
