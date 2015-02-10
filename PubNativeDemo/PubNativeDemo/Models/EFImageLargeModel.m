//
//  EFImageLargeModel.m
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "EFImageLargeModel.h"

@implementation EFImageLargeModel

@synthesize width;
@synthesize url;
@synthesize height;

#pragma makr NSObject

-(void)dealloc
{
    self.width = nil;
    self.url = nil;
    self.height = nil;
}

@end
