//
//  CHATROOM4.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/7.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "CHATROOM4.h"

@implementation CHATROOM4

+ (NSString *)dynamoDBTableName {
    return @"CHATROOM4";
}

+ (NSString *)hashKeyAttribute {
    return @"GID";
}

- (int) count {
    int c = 0;
    if (_isLikeUID1.intValue) c++;
    if (_isLikeUID2.intValue) c++;
    if (_isLikeUID3.intValue) c++;
    if (_isLikeUID4.intValue) c++;
    return c;
}

- (BOOL) hasTimeout {
    if ([self count] < 4) {
        NSTimeInterval currentSeconds = [[NSDate date] timeIntervalSince1970];
        if ([_systemTimeNumber longLongValue]/1000 + TOTAL_SECONDS < currentSeconds) {
            return YES;
        }
    }
    return NO;
}

@end
