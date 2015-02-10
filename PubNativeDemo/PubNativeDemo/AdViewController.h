//
//  AdViewController.h
//  PubNativeDemo
//
//  Created by David Martin on 05/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pubnative.h"
#import "PNNativeAdModel.h"

@interface AdViewController : UIViewController

- (void)presentAdWithViewController:(UIViewController*)adViewController type:(Pubnative_AdType)type;

@end
