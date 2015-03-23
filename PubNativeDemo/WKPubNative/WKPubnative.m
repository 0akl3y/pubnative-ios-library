//
//  WKPubnative.m
//
//  Created by David Martin on 23/03/2015
//  Copyright (c) 2015 PubNative
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "WKPubnative.h"

typedef  NS_ENUM(NSInteger, WKPubnative_BindingType)
{
    WKPubnative_BindingType_Request = 0,
    WKPubnative_BindingType_Track = 1
};

@interface WKPubnative ()

@property (nonatomic, weak)NSObject<WKPubnativeDelegate> *delegate;

+ (instancetype)sharedDelegate;

@end

@implementation WKPubnative

+ (instancetype)sharedDelegate
{
    static WKPubnative *_sharedDelegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDelegate = [[WKPubnative alloc] init];
    });
    return _sharedDelegate;
}

+ (void)setDelegate:(NSObject<WKPubnativeDelegate>*)delegate
{
    [WKPubnative sharedDelegate].delegate = delegate;
}

+ (void)requestWithAppToken:(NSString*)appToken
{
    [WKInterfaceController openParentApplication:@{
                                                    @"type":[NSNumber numberWithInteger:WKPubnative_BindingType_Request],
                                                    @"app_token":appToken
                                                  }
                                           reply:^(NSDictionary *replyInfo, NSError *error)
    {
        if(error)
        {
            [[WKPubnative sharedDelegate] invokePNRequestDidFail:error];
        }
        else
        {
            NSString *error = [replyInfo objectForKey:@"error"];
            if(error)
            {
                NSError *apiError = [NSError errorWithDomain:error code:0 userInfo:nil];
                [[WKPubnative sharedDelegate] invokePNRequestDidFail:apiError];
            }
            else
            {
                WKPNNativeAdModel *model = [[WKPNNativeAdModel alloc] initWithDictionary:replyInfo];
                [[WKPubnative sharedDelegate] invokePNRequestDidLoad:model];
            }
        }
    }];
}

+ (void)trackImpressionWithModel:(WKPNNativeAdModel*)model
{
    [WKInterfaceController openParentApplication:@{
                                                    @"type":[NSNumber numberWithInteger:WKPubnative_BindingType_Track],
                                                    @"url":model.impression_url
                                                  }
                                           reply:^(NSDictionary *replyInfo, NSError *error)
     {
         if(error)
         {
             [[WKPubnative sharedDelegate] invokeTrackDidFail:error];
         }
         else
         {
             NSString *error = [replyInfo objectForKey:@"error"];
             if(error)
             {
                 NSError *apiError = [NSError errorWithDomain:error code:0 userInfo:nil];
                 [[WKPubnative sharedDelegate] invokePNRequestDidFail:apiError];
             }
             {
                [[WKPubnative sharedDelegate] invokeTrackDidEnd];
             }
         }
     }];
}

- (void)invokePNRequestDidLoad:(WKPNNativeAdModel*)model
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(wkPNRequestDidLoad:)])
    {
        [self.delegate wkPNRequestDidLoad:model];
    }
}

- (void)invokePNRequestDidFail:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(wkPNRequestDidFail:)])
    {
        [self.delegate wkPNRequestDidFail:error];
    }
}

- (void)invokeTrackDidEnd
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(wkPNTrackDidEnd)])
    {
        [self.delegate wkPNTrackDidEnd];
    }
}

- (void)invokeTrackDidFail:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(wkPNTrackDidFail:)])
    {
        [self.delegate wkPNTrackDidFail:error];
    }
}

@end
