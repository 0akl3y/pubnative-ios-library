//
//  EFImageModel.m
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "EFImageModel.h"

@implementation EFImageModel

@synthesize large;

#pragma makr NSObject

- (void)dealloc
{
    self.large = nil;
}

@end
