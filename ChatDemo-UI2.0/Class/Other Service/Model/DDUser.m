//
//  DDUserModel.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/7.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "DDUser.h"

@implementation DDUser

+ (NSString *)dynamoDBTableName {
    return @"USER";
}

+ (NSString *)hashKeyAttribute {
    return @"UID";
}

@end

