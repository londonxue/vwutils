//
//  Utils.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "Utils.h"
//#import "OSCTweet.h"
#import "OSCNews.h"
//#import "OSCBlog.h"
//#import "OSCPost.h"
//#import "UserDetailsViewController.h"
#import "DetailsViewController.h"
//#import "PostsViewController.h"
#import "ImageViewerController.h"
//#import "TweetDetailsWithBottomBarViewController.h"
//#import "TweetsViewController.h"
#import "AppDelegate.h"

//#import "UIFont+FontAwesome.h"
//#import "NSString+FontAwesome.h"

#import <MBProgressHUD.h>
#import <objc/runtime.h>
//#import <Reachability.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <GRMustache.h>
#import <TOWebViewController.h>

@implementation Utils


#pragma mark - 处理API返回信息
//
//+ (NSAttributedString *)getAppclient:(int)clientType
//{
//    NSMutableAttributedString *attributedClientString;
//    if (clientType > 1 && clientType <= 6) {
//        NSArray *clients = @[@"", @"", @"手机", @"Android", @"iPhone", @"Windows Phone", @"微信"];
//        
//        attributedClientString = [[NSMutableAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForEnum:FAMobile]
//                                                                        attributes:@{
//                                                                                     NSFontAttributeName: [UIFont fontAwesomeFontOfSize:13],
//                                                                                     }];
//        
//        [attributedClientString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", clients[clientType]]]];
//    } else {
//        attributedClientString = [[NSMutableAttributedString alloc] initWithString:@""];
//    }
//    
//    return attributedClientString;
//}

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews
{
    if (relativeNews == nil || [relativeNews count] == 0) {
        return @"";
    }
    
    NSString *middle = @"";
    for (NSArray *news in relativeNews) {
        middle = [NSString stringWithFormat:@"%@<a href=%@ style='text-decoration:none'>%@</a><p/>", middle, news[1], news[0]];
    }
    return [NSString stringWithFormat:@"相关文章<div style='font-size:14px'><p/>%@</div>", middle];
}

+ (NSString *)GenerateTags:(NSArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    } else {
        NSString *result = @"";
        for (NSString *tag in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;", result, tag, tag];
        }
        return result;
    }
}


+ (void)analysis:(NSString *)url andNavController:(UINavigationController *)navigationController
{
    //判断是否包含 oschina.net 来确定是不是站内链接
    NSRange range = [url rangeOfString:@"oschina.net"];
    if (range.length <= 0) {
        NSString *URL = [url hasPrefix:@"http://"]? url : [NSString stringWithFormat:@"http://%@", url];
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:URL]];
        webViewController.hidesBottomBarWhenPushed = YES;
        [navigationController pushViewController:webViewController animated:YES];
    } else {
        //站内链接
        
        url = [url substringFromIndex:7];
        NSArray *pathComponents = [url pathComponents];
        NSString *prefix = [pathComponents[0] componentsSeparatedByString:@"."][0];
        UIViewController *viewController;
        
        if ([prefix isEqualToString:@"my"])
        {
            if (pathComponents.count == 2) {
                // 个人专页 my.oschina.net/dong706
                
//                viewController = [[UserDetailsViewController alloc] initWithUserName:pathComponents[1]];
//                viewController.navigationItem.title = @"用户详情";
            } else if (pathComponents.count == 3) {
                // 个人专页 my.oschina.net/u/12
                
                if ([pathComponents[1] isEqualToString:@"u"]) {
//                    viewController= [[UserDetailsViewController alloc] initWithUserID:[pathComponents[2] longLongValue]];
//                    viewController.navigationItem.title = @"用户详情";
                }
            } else if (pathComponents.count == 4) {
                NSString *type = pathComponents[2];
                if ([type isEqualToString:@"blog"]) {
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeBlog;
                    news.attachment = pathComponents[3];
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"博客详情";
//                } else if ([type isEqualToString:@"tweet"]){
//                    OSCTweet *tweet = [OSCTweet new];
//                    tweet.tweetID = [pathComponents[3] longLongValue];
//                    viewController = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
//                    viewController.navigationItem.title = @"动弹详情";
                }
            } else if(pathComponents.count == 5) {
                NSString *type = pathComponents[3];
                if ([type isEqualToString:@"blog"]) {
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeBlog;
                    news.attachment = pathComponents[4];
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"博客详情";
                }
            }
        } else if ([prefix isEqualToString:@"www"]) {
            //新闻,软件,问答
            NSArray *urlComponents = [url componentsSeparatedByString:@"/"];
            NSUInteger count = urlComponents.count;
            if (count >= 3) {
                NSString *type = urlComponents[1];
                if ([type isEqualToString:@"news"]) {
                    // 新闻
                    // www.oschina.net/news/27259/mobile-internet-market-is-small
                    
                    int64_t newsID = [urlComponents[2] longLongValue];
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeStandardNews;
                    news.newsID = newsID;
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"资讯详情";
                } else if ([type isEqualToString:@"p"]) {
                    // 软件 www.oschina.net/p/jx
                    
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeSoftWare;
                    news.attachment = urlComponents[2];
                    viewController = [[DetailsViewController alloc] initWithNews:news];
                    viewController.navigationItem.title = @"软件详情";
                } else if ([type isEqualToString:@"question"]) {
                    // 问答
                    
                    if (count == 3) {
                        // 问答 www.oschina.net/question/12_45738
                        
                        NSArray *IDs = [urlComponents[2] componentsSeparatedByString:@"_"];
                        if ([IDs count] >= 2) {
//                            OSCPost *post = [OSCPost new];
//                            post.postID = [IDs[1] longLongValue];
//                            viewController = [[DetailsViewController alloc] initWithPost:post];
//                            viewController.navigationItem.title = @"帖子详情";
                        }
                    } else if (count >= 4) {
                        // 问答-标签 www.oschina.net/question/tag/python
                        
                        NSString *tag = urlComponents.lastObject;
                        
//                        viewController = [PostsViewController new];
//                        ((PostsViewController *)viewController).generateURL = ^NSString * (NSUInteger page) {
//                            return [NSString stringWithFormat:@"%@%@?tag=%@&pageIndex=0&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, tag, OSCAPI_SUFFIX];
//                        };
                        
//                        ((PostsViewController *)viewController).objClass = [OSCPost class];
                        viewController.navigationItem.title = [tag stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                } else if ([type isEqualToString:@"tweet-topic"]) {
                    //话题
                    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    urlComponents = [url componentsSeparatedByString:@"/"];
                    
//                    viewController = [[TweetsViewController alloc] initWithTopic:urlComponents[2]];
                }
            }
        } else if ([prefix isEqualToString:@"static"]) {
            ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]]];
            
            [navigationController presentViewController:imageViewerVC animated:YES completion:nil];
            
            return;
        }
        if (viewController) {
            [navigationController pushViewController:viewController animated:YES];
        } else {
            NSString *URL = [url hasPrefix:@"http://"]? url : [NSString stringWithFormat:@"http://%@", url];
            TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:URL]];
            webViewController.hidesBottomBarWhenPushed = YES;
            [navigationController pushViewController:webViewController animated:YES];
        }
    }
}






#pragma mark - 通用

#pragma mark - emoji Dictionary

+ (NSDictionary *)emojiDict
{
    static dispatch_once_t once;
    static NSDictionary *emojiDict;
    
    dispatch_once(&once, ^ {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emoji" ofType:@"plist"];
        emojiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    });
    
    return emojiDict;
}

#pragma mark 信息处理

+ (NSDictionary *)timeIntervalArrayFromString:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *compsPast = [calendar components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger daysInLastMonth = [calendar rangeOfUnit:NSDayCalendarUnit
                                               inUnit:NSMonthCalendarUnit
                                              forDate:date].length;
    
    NSInteger years = [compsNow year] - [compsPast year];
    NSInteger months = [compsNow month] - [compsPast month] + years * 12;
    NSInteger days = [compsNow day] - [compsPast day] + months * daysInLastMonth;
    NSInteger hours = [compsNow hour] - [compsPast hour] + days * 24;
    NSInteger minutes = [compsNow minute] - [compsPast minute] + hours * 60;
    
    return @{
             kKeyYears:  @(years),
             kKeyMonths: @(months),
             kKeyDays:   @(days),
             kKeyHours:  @(hours),
             kKeyMinutes:@(minutes)
             };
}

+ (NSDateComponents *)getDateComponentsFromDate:(NSDate *)date
{
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday |
                           NSCalendarUnitDay  | NSCalendarUnitHour  | NSCalendarUnitMinute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar components:unitFlags fromDate:date];
}


+ (NSString *)getWeekdayFromDateComponents:(NSDateComponents *)dateComps
{
    switch (dateComps.weekday) {
        case 1: return @"星期天";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";
        default: return @"";
    }
}

//
//+ (NSAttributedString *)attributedTimeString:(NSString *)dateStr
//{
//    NSString *rawString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [self intervalSinceNow:dateStr]];
//    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:rawString
//                                                                         attributes:@{
//                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
//                                                                                      }];
//    
//    return attributedTime;
//}


+ (NSString *)intervalSinceNow:(NSString *)dateStr
{
    if(!dateStr){
        return @"";
    }
    NSDictionary *dic = [Utils timeIntervalArrayFromString:dateStr];
    //NSInteger years = [[dic objectForKey:kKeyYears] integerValue];
    NSInteger months = [[dic objectForKey:kKeyMonths] integerValue];
    NSInteger days = [[dic objectForKey:kKeyDays] integerValue];
    NSInteger hours = [[dic objectForKey:kKeyHours] integerValue];
    NSInteger minutes = [[dic objectForKey:kKeyMinutes] integerValue];
    
    if (minutes < 1) {
        return @"刚刚";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ld分钟前", (long)minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:@"%ld小时前", (long)hours];
    } else if (hours < 48 && days == 1) {
        return @"昨天";
    } else if (days < 30) {
        return [NSString stringWithFormat:@"%ld天前", (long)days];
    } else if (days < 60) {
        return @"一个月前";
    } else if (months < 12) {
        return [NSString stringWithFormat:@"%ld个月前", (long)months];
    } else {
        NSArray *arr = [dateStr componentsSeparatedByString:@" "];
        return arr[0];
    }
}


// 参考 http://www.cnblogs.com/ludashi/p/3962573.html

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString
{
    NSMutableAttributedString *emojiString = [[NSMutableAttributedString alloc] initWithString:rawString];
    NSDictionary *emoji = self.emojiDict;
    
    NSString *pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]|:[a-zA-Z0-9\\u4e00-\\u9fa5_]+:";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:rawString options:0 range:NSMakeRange(0, rawString.length)];
    
    NSMutableArray *emojiArray = [NSMutableArray arrayWithCapacity:resultsArray.count];
    
    for (NSTextCheckingResult *match in resultsArray) {
        NSRange range = [match range];
        NSString *emojiName = [rawString substringWithRange:range];
        
        if ([emojiName hasPrefix:@"["] && emoji[emojiName]) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:emoji[emojiName]];
            [textAttachment adjustY:-3];
            
            NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            
            [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
        } else if ([emojiName hasPrefix:@":"]) {
            if (emoji[emojiName]) {
                [emojiArray addObject:@{@"text": emoji[emojiName], @"range": [NSValue valueWithRange:range]}];
            } else {
                UIImage *emojiImage = [UIImage imageNamed:[emojiName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]];
                NSTextAttachment *textAttachment = [NSTextAttachment new];
                textAttachment.image = emojiImage;
                [textAttachment adjustY:-3];
                
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
            }
        }
    }
    
    for (NSInteger i = emojiArray.count -1; i >= 0; i--) {
        NSRange range;
        [emojiArray[i][@"range"] getValue:&range];
        if (emojiArray[i][@"image"]) {
            [emojiString replaceCharactersInRange:range withAttributedString:emojiArray[i][@"image"]];
        } else {
            [emojiString replaceCharactersInRange:range withString:emojiArray[i][@"text"]];
        }
    }
    
    return emojiString;
}

+ (NSMutableAttributedString *)attributedStringFromHTML:(NSString *)HTML
{
    return [[NSMutableAttributedString alloc] initWithData:[HTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                   options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                        documentAttributes:nil
                                                     error:nil];
}

+ (NSString *)convertRichTextToRawText:(UITextView *)textView
{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
                                                    if (!attachment) {return;}
                                        
                                                    NSString *emojiStr = objc_getAssociatedObject(attachment, @"emoji");
                                                    [rawText insertString:emojiStr atIndex:range.location];
                                                }];
    
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
    }
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSData *)compressImage:(UIImage *)image
{
    CGSize size = [self scaleSize:image.size];
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 0.7f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}

+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    } else {
        return CGSizeMake(800 * width / height, 800);
    }
}

+ (NSString *)escapeHTML:(NSString *)originalHTML
{
    if (!originalHTML) {return @"";}
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:originalHTML];
    [result replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'"  withString:@"&#39;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    return result;
}

+ (NSString *)deleteHTMLTag:(NSString *)HTML
{
    NSMutableString *trimmedHTML = [[NSMutableString alloc] initWithString:HTML];
    
    NSString *styleTagPattern = @"<style[^>]*?>[\\s\\S]*?<\\/style>";
    NSRegularExpression *styleTagRe = [NSRegularExpression regularExpressionWithPattern:styleTagPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *resultsArray = [styleTagRe matchesInString:trimmedHTML options:0 range:NSMakeRange(0, trimmedHTML.length)];
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        [trimmedHTML replaceCharactersInRange:match.range withString:@""];
    }
    
    NSString *htmlTagPattern = @"<[^>]+>";
    NSRegularExpression *normalHTMLTagRe = [NSRegularExpression regularExpressionWithPattern:htmlTagPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    resultsArray = [normalHTMLTagRe matchesInString:trimmedHTML options:0 range:NSMakeRange(0, trimmedHTML.length)];
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        [trimmedHTML replaceCharactersInRange:match.range withString:@""];
    }
    
    return trimmedHTML;
}


+ (BOOL)isURL:(NSString *)string
{
    NSString *pattern = @"^(http|https)://.*?$(net|com|.com.cn|org|me|)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    return [urlPredicate evaluateWithObject:string];
}


//+ (NSInteger)networkStatus
//{
//    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.oschina.net"];
//    return reachability.currentReachabilityStatus;
//}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}


#pragma mark UI处理

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent
{
    return min + (max - min) * percent;
}

+ (MBProgressHUD *)createHUD
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:window];
    HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    [window addSubview:HUD];
    [HUD show:YES];
    //[HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
    
    return HUD;
}

+ (UIImage *)createQRCodeFromString:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [QRFilter setValue:stringData forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CGFloat scale = 5;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:QRFilter.outputImage fromRect:QRFilter.outputImage.extent];
    
    //Scale the image usign CoreGraphics
    CGFloat width = QRFilter.outputImage.extent.size.width * scale;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return image;
}

//+ (NSAttributedString *)attributedCommentCount:(int)commentCount
//{
//    NSString *rawString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FACommentsO], commentCount];
//    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
//                                                                                 attributes:@{
//                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
//                                                                                              }];
//    
//    return attributedCommentCount;
//}


+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html" inDirectory:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *mutableData = [data mutableCopy];
    [mutableData setObject:@(((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode)
                    forKey:@"night"];
    
    return [GRMustacheTemplate renderObject:mutableData fromString:template error:nil];
}



@end
