//
//  WeakRef.m
//  pregnant
//
//  Created by london xue on 16/10/15.
//  Copyright (c) 2015 viwing. All rights reserved.
//

#import "WeakRef.h"

@implementation WeakRef

- (id)initWithObject:(id)object
{
    self.ref = object;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    invocation.target = self.ref;
    [invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.ref methodSignatureForSelector:sel];
}

@end