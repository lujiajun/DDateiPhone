//
//  CHATROOM2.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/7.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSDynamoDBObjectMapper.h"

@interface CHATROOM2 : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *RID;
@property (nonatomic, strong) NSString *ClickNum;
@property (nonatomic, strong) NSNumber *Gender;
@property (nonatomic, strong) NSString *GradeFrom;
@property (nonatomic, strong) NSString *Motto;
@property (nonatomic, strong) NSString *PicturePath;
@property (nonatomic, strong) NSString *SchoolRestrict;
@property (nonatomic, strong) NSString *UID1;
@property (nonatomic, strong) NSString *UID2;

@end