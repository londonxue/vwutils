//
//  UncaughtExceptionHandler.h
//  idevice
//
//  Created by london xue on 27/1/15.
//  Copyright (c) 2015 london xue. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UncaughtExceptionHandler : NSObject
-(BOOL)isWiFiAvailable;
+(void)registerHandler;
@end

void HandleException(NSException *exception);
void SignalHandler(int signal);

void InstallUncaughtExceptionHandler(void);