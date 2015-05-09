//
//  CHATROOM2.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/7.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "CHATROOM2.h"

@implementation CHATROOM2

+ (NSString *)dynamoDBTableName {
    return @"CHATROOM2";
}

+ (NSString *)hashKeyAttribute {
    return @"RID";
}

@end

