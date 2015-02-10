//
//  EFPerformersModel.h
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "YADMJSONApiModel.h"
#import "EFPerformerModel.h"

@protocol EFPerformersModel

@property (strong, nonatomic) EFPerformerModel          *performer;

@end

@interface EFPerformersModel : YADMJSONApiModel <EFPerformersModel>

@end
