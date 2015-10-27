//
//  DateUtils.m
//  idevice
//
//  Created by london xue on 22/1/15.
//  Copyright (c) 2015 london xue. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils
+(NSString*) convert2String:(NSDate* ) date{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * dateStr=[dateformatter stringFromDate:date];
    return dateStr;
}
+(NSDate*) dateFromString:(NSString*) dateStr{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[dateFormatter dateFromString:dateStr];
    return date;
}

+(NSString*) dateTimeconvert2String:(NSDate* ) date{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString * dateStr=[dateformatter stringFromDate:date];
    return dateStr;
}
+(NSDate*) datetimeFromString:(NSString*) dateStr{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:dateStr];
    return date;
}

+(long long) date2Seconds:(NSDate*) date{
    NSTimeInterval time = [date timeIntervalSinceReferenceDate];
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]/1000;
    return dTime;
}
@end
