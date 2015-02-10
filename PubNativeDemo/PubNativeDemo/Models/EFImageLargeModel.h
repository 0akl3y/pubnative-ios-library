//
//  EFImageLargeModel.h
//  PubNativeDemo
//
//  Created by Csongor Nagy on 06/02/15.
//  Copyright (c) 2015 PubNative. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol EFImageLargeModel

@property (strong, nonatomic) NSString                  *width;
@property (strong, nonatomic) NSString                  *url;
@property (strong, nonatomic) NSString                  *height;

@end

@interface EFImageLargeModel : YADMJSONApiModel <EFImageLargeModel>

@end
