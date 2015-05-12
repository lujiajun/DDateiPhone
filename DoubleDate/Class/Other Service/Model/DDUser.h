//
//  DDUser.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/7.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSDynamoDBObjectMapper.h"

@interface DDUser : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *UID;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSNumber *isPic;
@property (nonatomic, strong) NSString *picPath;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSString *university;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic, strong) NSNumber *isDoublerID;
@property (nonatomic, strong) NSString *photos;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *hobbies;

@end

