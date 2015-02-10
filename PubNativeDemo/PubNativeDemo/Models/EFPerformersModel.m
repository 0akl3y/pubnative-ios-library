//
//  EFPerformersModel.m
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "EFPerformersModel.h"

@implementation EFPerformersModel

@synthesize performer;

#pragma mark NSObject

-(void)dealloc
{
    self.performer = nil;
}

@end
