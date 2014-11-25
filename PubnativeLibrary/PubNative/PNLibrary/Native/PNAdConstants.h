//
// PNAdConstants.h
//
// Created by Csongor Nagy on 19/06/14.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define PADDING             5
#define P_IMAGE_W           627
#define P_IMAGE_H           1200
#define L_IMAGE_W           960
#define L_IMAGE_H           640

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface PNAdConstants : NSObject

FOUNDATION_EXPORT NSString *const   kUrlString;
FOUNDATION_EXPORT NSString *const   kMethodGet;
FOUNDATION_EXPORT NSString *const   kMethodPost;
FOUNDATION_EXPORT NSInteger const   kImpressionTime;

FOUNDATION_EXPORT NSString *const   kIconSize;
FOUNDATION_EXPORT NSString *const   kIpadBannerSize;
FOUNDATION_EXPORT NSString *const   kIphoneBannerSize;
FOUNDATION_EXPORT NSString *const   kIpadDeviceName;
FOUNDATION_EXPORT NSString *const   kIphoneDeviceName;

FOUNDATION_EXPORT NSString *const   kSponsoredContent;

typedef void (^PNRequestCompletionBlock)(NSMutableArray *ads, NSError *error);
typedef void (^PNImpressionCompletionBlock)(id result, NSError *error);

+ (PNAdConstants*)sharedConstants;
- (NSString*)version;

@end
