//
//  EFImageModel.h
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "YADMJSONApiModel.h"
#import "EFImageLargeModel.h"

@protocol EFImageModel <NSObject>

@property (strong, nonatomic) EFImageLargeModel     *large;

@end

@interface EFImageModel : YADMJSONApiModel <EFImageModel>

@end
