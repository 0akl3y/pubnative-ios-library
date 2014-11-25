//
// PNAdConstants.m
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

#import "PNAdConstants.h"

@implementation PNAdConstants

NSString *const kUrlString          = @"http://api.pubnative.net/api/partner/v2/promotions/native";
NSString *const kMethodGet          = @"GET";
NSString *const kMethodPost         = @"POST";
NSInteger const kImpressionTime     = 1;

NSString *const kIconSize           = @"400x400";
NSString *const kIpadBannerSize     = @"1200x627";
NSString *const kIphoneBannerSize   = @"640x334";

NSString *const kIpadDeviceName     = @"tablet";
NSString *const kIphoneDeviceName   = @"phone";

NSString *const kSponsoredContent   = @"Sponsored by Pubnative";

+ (PNAdConstants*)sharedConstants
{
    static PNAdConstants *sharedConstants = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConstants = [[PNAdConstants alloc] init];
    });
    return sharedConstants;
}

- (NSString*)version
{
    NSString *version = @"";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PNVersion" ofType:@"plist"];
    if (path)
    {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        version = [NSString stringWithFormat:@"v.%@", [dict objectForKey:@"version"]];
    }

    return version;
}

@end
