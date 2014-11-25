//
// PNLibrary.m
//
// Created by Csongor Nagy on 12/11/14.
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

#import "PNLibrary.h"
#import "PNBannerViewController.h"
#import "PNIconViewController.h"

@interface PNLibrary ()

@property (nonatomic, weak) NSObject<PNLibraryDelegate>         *delegate;
@property (nonatomic, assign) CGRect                            frame;
@property (nonatomic, assign) PNAdType                          currentType;
@property (nonatomic, assign) BOOL                              startActionRequired;

+ (UIViewController*)createType:(PNAdType)type;

@end

@implementation PNLibrary

#pragma mark - Init

static PNLibrary *sharedInstance = nil;

+ (PNLibrary*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[PNLibrary alloc] init];
            sharedInstance.startActionRequired  = YES;
        }
    }
    
    return sharedInstance;
}



#pragma mark - Class Methods

+ (void)startWithAppID:(NSString *)appId
                 frame:(CGRect)frame
              delegate:(id<PNLibraryDelegate>)delegate
{
    [PNLibrary sharedInstance].delegate = delegate;
    [PNLibrary sharedInstance].frame = frame;
    [PNLibrary sharedInstance].startActionRequired  = NO;
    [[PNAdRequestTargeting sharedInstance] setApp_token:appId];
}

+ (void)requestType:(PNAdType)type
{
    [PNLibrary sharedInstance].currentType = type;
    [PNLibrary createType:type];
}



#pragma mark - Factory Methods

+ (UIViewController*)createType:(PNAdType)type
{
    UIViewController *result = nil;
    switch (type)
    {
        case PNAdTypeBanner:    result = [PNLibrary createAdTypeBanner];    break;
        case PNAdTypeIcon:      result = [PNLibrary createAdTypeIcon];      break;
    }
    
    return result;
}

+ (UIViewController*)createAdTypeBanner
{
    UIViewController *result = (UIViewController*)[[PNBannerViewController alloc]
                                                   initWithNibName:NSStringFromClass([PNBannerViewController class])
                                                   bundle:nil
                                                   frame:[PNLibrary sharedInstance].frame
                                                   delegate:[PNLibrary sharedInstance].delegate];
    return result;
}

+ (UIViewController*)createAdTypeIcon
{
    UIViewController *result = (UIViewController*)[[PNIconViewController alloc]
                                                   initWithNibName:NSStringFromClass([PNIconViewController class])
                                                   bundle:nil
                                                   frame:[PNLibrary sharedInstance].frame
                                                   delegate:[PNLibrary sharedInstance].delegate];
    return result;
}

@end
