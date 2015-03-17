//
//  PNGameListAdTableViewController.h
//  PubNativeDemo
//
//  Created by David Martin on 16/03/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PubnativeAdDelegate.h"
#import "PNNativeAdModel.h"

@interface PNGameListAdViewController : UIViewController

@property (nonatomic, strong) NSObject<PubnativeAdDelegate> *delegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                            ads:(NSArray *)ads;

@end
