//
//  CHATROOM4.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/7.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSDynamoDBObjectMapper.h"

@interface CHATROOM4 : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *GID;
@property (nonatomic, strong) NSString *CTIMEH;
@property (nonatomic, strong) NSString *CTIMER;
@property (nonatomic, strong) NSString *RID;
@property (nonatomic, strong) NSString *UID1;
@property (nonatomic, strong) NSString *UID2;
@property (nonatomic, strong) NSString *UID3;
@property (nonatomic, strong) NSString *UID4;
@property (nonatomic, strong) NSNumber *isLikeUID1;
@property (nonatomic, strong) NSNumber *isLikeUID2;
@property (nonatomic, strong) NSNumber *isLikeUID3;
@property (nonatomic, strong) NSNumber *isLikeUID4;
@property (nonatomic, strong) NSString *roomStatus;
@property (nonatomic, strong) NSString *subGID1;
@property (nonatomic, strong) NSString *subGID2;
@property (nonatomic,strong) NSNumber *systemTimeNumber;


@end
