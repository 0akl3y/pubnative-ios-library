//
//  EFPerformerModel.h
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol EFPerformerModel

@property (strong, nonatomic) NSString                  *creator;
@property (strong, nonatomic) NSString                  *linker;
@property (strong, nonatomic) NSString                  *name;
@property (strong, nonatomic) NSString                  *url;
@property (strong, nonatomic) NSString                  *Id;
@property (strong, nonatomic) NSString                  *short_bio;

@end

@interface EFPerformerModel : YADMJSONApiModel <EFPerformerModel>

@end
