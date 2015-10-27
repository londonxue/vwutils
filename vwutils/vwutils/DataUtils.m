//
//  DataUtils.m
//  idevice
//
//  Created by london xue on 22/1/15.
//  Copyright (c) 2015 london xue. All rights reserved.
//

#import "DataUtils.h"

@implementation DataUtils
//将data类型的数据,转成UTF8的数据
+(NSString *)dataToUTF8String:(NSData *)data
{
    NSString *buf = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return buf;
}

//将string转换为指定编码
+(NSString *)changeDataToEncodinString:(NSData *)data encodin:(NSStringEncoding )encodin{
    NSString *buf = [[NSString alloc] initWithData:data encoding:encodin];
    return buf;
}
@end
