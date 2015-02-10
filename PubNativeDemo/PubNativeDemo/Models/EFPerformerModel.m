//
//  EFPerformerModel.m
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "EFPerformerModel.h"

@implementation EFPerformerModel

@synthesize creator;
@synthesize linker;
@synthesize name;
@synthesize url;
@synthesize Id;
@synthesize short_bio;

#pragma mark NSObject

- (void)dealloc
{
    self.creator = nil;
    self.linker = nil;
    self.name = nil;
    self.url = nil;
    self.Id = nil;
    self.short_bio = nil;
}

@end
