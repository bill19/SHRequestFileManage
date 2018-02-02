//
//  NSString+change.m
//  SHRequestFileManage
//
//  Created by HaoSun on 2017/12/22.
//  Copyright © 2017年 YHKIT. All rights reserved.
//

#import "NSString+change.h"

@implementation NSString (change)

+ (NSString *)convertToCamelCaseFromSnakeCase:(NSString *)key {
    NSMutableString *str = [NSMutableString stringWithString:key];
    while ([str containsString:@"_"]) {
        NSRange range = [str rangeOfString:@"_"];
        if (range.location + 1 < [str length]) {
            char c = [str characterAtIndex:range.location+1];
            [str replaceCharactersInRange:NSMakeRange(range.location, range.length+1) withString:[[NSString stringWithFormat:@"%c",c] uppercaseString]];
        }
    }
    return str;
}

- (NSString *)sh_lowercaseString {
    if ([self rangeOfString:@"_"].location !=NSNotFound) {
        NSMutableString *str = [NSMutableString stringWithString:[self lowercaseString]];
        while ([str containsString:@"_"]) {
            NSRange range = [str rangeOfString:@"_"];
            if (range.location + 1 < [str length]) {
                char c = [str characterAtIndex:range.location+1];
                [str replaceCharactersInRange:NSMakeRange(range.location, range.length+1) withString:[[NSString stringWithFormat:@"%c",c] uppercaseString]];
            }
        }
        return str;
    }
    return self;
}

@end
