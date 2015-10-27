//
//  DateUtils.h
//  idevice
//
//  Created by london xue on 22/1/15.
//  Copyright (c) 2015 london xue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject
+(NSString*) convert2String:(NSDate* ) date;
+(NSDate*) dateFromString:(NSString*) dateStr;
+(long long) date2Seconds:(NSDate*) date;
@end
