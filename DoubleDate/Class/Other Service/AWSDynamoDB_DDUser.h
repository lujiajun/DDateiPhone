//
//  AWSDynamoDB_DDUser.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/6.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSDynamoDBObjectMapper.h"
#import "DDUserDAO.h"
#import "DDUser.h"

typedef void(^SuccussBlock)();

@interface AWSDynamoDB_DDUser : NSObject

@property (nonatomic, strong) DDUserDAO *dduserDao;
@property (nonatomic, strong) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;



- (void)insertDDUser:(DDUser *)dduser;

- (void)updateDDUser:(DDUser *)dduser;

- (DDUser *)getTableUser:(NSString *)uid;

- (DDUser *)getUserByUid:(NSString *)uid;

- (void)getDDuserAndInsertLocal:(NSString *)uid;
@end


