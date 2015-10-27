//
//  WeakRef.h
//  pregnant
//
//  Created by london xue on 16/10/15.
//  Copyright (c) 2015 viwing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakRef : NSProxy

@property (weak) id ref;
- (id)initWithObject:(id)object;

@end