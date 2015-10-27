//
//  UncaughtExceptionHandler.m
//  idevice
//
//  Created by london xue on 27/1/15.
//  Copyright (c) 2015 london xue. All rights reserved.
//

//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>


NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

BOOL dismissed = NO;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}
- (void)handleException:(NSException *)exception
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory , NSUserDomainMask , YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* crashLogFilePath = [documentsDirectory stringByAppendingPathComponent:@"sys_crash_log.txt"];
    
    NSMutableString* logContent = [[NSMutableString alloc] initWithCapacity:0];
    [logContent appendString:@"\r\n==========  crash log  start =============\r\n\r\n" ];
    [logContent appendFormat:@"crachTime: %@\r\n",[self getCurrentTime] ];
    [logContent appendFormat:@"platform: %@\r\n",[[UIDevice currentDevice] systemName] ];
    [logContent appendFormat:@"osVersion: %@\r\n",[[UIDevice currentDevice] systemVersion] ];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [[UIScreen mainScreen] scale];
    [logContent appendFormat:@"resolution: %.fx%.f\r\n",rect.size.width*scale,rect.size.height*scale ];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString* language = [languages objectAtIndex:0];
    [logContent appendFormat:@"language: %@\r\n",language ];
    
    CTTelephonyNetworkInfo* netInfo =[[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* carrier = [netInfo subscriberCellularProvider];
    NSString* mcc = [carrier mobileCountryCode];
    NSString* mnc = [carrier mobileNetworkCode];
    [logContent appendFormat:@"mobileCountryCode / mobileNetworkCode: %@ / %@\r\n",mcc,mnc ];
    
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [logContent appendFormat:@"App Version: %@\r\n",version ];
    BOOL isWifi = [self isWiFiAvailable];
    NSString* netWork = nil;
    if(isWifi)
    {
        netWork = @"WIFI";
    }
    else
    {
        netWork = @"2G/3G";
    }
    [logContent appendFormat:@"netWork: %@\r\n",netWork ];
    
    [logContent appendFormat:@"CRASH: %@\r\n",exception ];
    [logContent appendFormat:@"Stack Trace: %@\r\n",[exception callStackSymbols] ];
    [logContent appendFormat:@"             %@\r\n",[exception callStackReturnAddresses] ];
    [logContent appendFormat:@"             %@\r\n",[exception userInfo] ];
    [logContent appendString:@"\r\n==========  crash log  end =============\r\n" ];
    
    NSData* contentData = [logContent dataUsingEncoding:NSUTF8StringEncoding];
    [self writeFileByNSData:crashLogFilePath data:contentData];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统出错"
                                                    message:[NSString stringWithFormat:@"系统出错，你可以选择不退出程序，但可能会产生未知后果.\n"@"%@\n%@",
                                                             [exception reason],[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
                                                   delegate:self
                                          cancelButtonTitle:@"退出"
                                          otherButtonTitles:@"继续使用", nil];
    
    [alert show];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    while (!dismissed)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
}
- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
    {
        dismissed = YES;
    }
}

- (void)writeFileByNSData:(NSString *)filePath data:(NSData*) data
{
    //写文件句柄指向文件
    NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    if (nil == filehandle)
    {
        [data writeToFile:filePath atomically:YES];
    }
    else
    {
        //定位到filename的文件末端
        [filehandle truncateFileAtOffset:[filehandle seekToEndOfFile]];
        
        //写入数据
        [filehandle writeData:data];
    }
    
    //关闭
    [filehandle closeFile];
}
-(NSString *)getCurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@"Current Time 2 = %@",timeStamp);
    
    return timeStamp;
    
}
-(BOOL)isWiFiAvailable
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    if (getifaddrs(&addresses) != 0) return NO;
    
    cursor = addresses;
    while (cursor != NULL) {
        if (cursor -> ifa_addr -> sa_family == AF_INET
            && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return wiFiAvailable;
}

+(void)registerHandler
{
    InstallUncaughtExceptionHandler();
}

@end

void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack  forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo]
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
      reason:
      [NSString stringWithFormat:
       NSLocalizedString(@"Signal %d was raised.", nil),
       signal]
      userInfo:
      userInfo]
     waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}
