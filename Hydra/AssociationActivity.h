//
//  AssociationActivity.h
//  Hydra
//
//  Created by Pieter De Baets on 21/07/12.
//  Copyright (c) 2012 Zeus WPI. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMappingProvider;

@interface AssociationActivity : NSObject

+ (void)registerObjectMappingWith:(RKObjectMappingProvider *)mappingProvider;

@end
