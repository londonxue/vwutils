//
//  jsonUtils.h
//  idevice
//
//  Created by london xue on 22/1/15.
//  Copyright (c) 2015 london xue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtils : NSObject
+ (NSData *)toJSONData:(id)theData;
+ (id)toArrayOrNSDictionary:(NSData *)jsonData;
+ (NSString *)encodeToPercentEscapeString: (NSString *) input;
@end
