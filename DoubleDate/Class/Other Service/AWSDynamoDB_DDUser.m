//
//  AWSDynamoDB_DDUser.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/6.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "AWSDynamoDB_DDUser.h"
#import "BFTask.h"
#import "BFExecutor.h"

@implementation AWSDynamoDB_DDUser

- (instancetype)init {
	if (self = [super init]) {
		_dduserDao = [[DDUserDAO alloc] init];
        _dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	}
	return self;
}

- (void)insertDDUser:(DDUser *)dduser {
    [[self.dynamoDBObjectMapper save:dduser]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
            [self.dduserDao insertDDUser:dduser];
         }
         return nil;
     }];
    
//	[self.dynamoDBObjectMapper save:dduser];
    
}

- (void)updateDDUser:(DDUser *)dduser {
    [[self.dynamoDBObjectMapper save:dduser]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
            [self.dduserDao updateByUID:dduser];
         }
         return nil;
     }];
    
}

- (void)getUserByUID:(NSString *) uid withBlock:(SuccussBlock)block  {
    BFTask *task = [self.dynamoDBObjectMapper load:[DDUser class] hashKey:uid rangeKey:nil];
    [task continueWithBlock: ^id (BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             DDUser *user = task.result;
             block(user);
         } else {
             block(nil);
         }
         return nil;
     }];
}

- (void)getDDuserAndInsertLocal:(NSString *)uid {
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	[[dynamoDBObjectMapper load:[DDUser class]
	                    hashKey:uid
	                   rangeKey:nil]
	 continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
	    if (task.error) {
	        NSLog(@"The request failed. Error: [%@]", task.error);
		}
	    if (task.exception) {
	        NSLog(@"The request failed. Exception: [%@]", task.exception);
		}
	    if (task.result) {
	        DDUser *dduser = task.result;
	        [self.dduserDao insertDDUser:dduser];
		}
	    return nil;
	}];
}


- (DDUser *)getUserByUid:(NSString *)uid {
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	BFTask *task = [dynamoDBObjectMapper load:[DDUser class] hashKey:uid rangeKey:nil];
	if (task.result) {
		DDUser *user = task.result;
		return user;
	}
	return nil;
}

@end
