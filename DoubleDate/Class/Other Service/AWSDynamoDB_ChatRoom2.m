/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AWSDynamoDB_ChatRoom2.h"
#import "AWSDynamoDB/AWSDynamoDB.h"
#import "BFExecutor.h"
#import "AWSDynamoDB_DDUser.h"

#define DEFAULT_COUNT 20

@implementation AWSDynamoDB_ChatRoom2

- (instancetype)init {
	if (self = [super init]) {
		_chatRoom2Dao = [[ChatRoom2DAO alloc] init];
	}
	return self;
}

- (void)insertChatroom2:(CHATROOM2 *)chatRoom2 {
	//先删除重复的
	[self removeFromAWSandLocal:chatRoom2];
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	[[dynamoDBObjectMapper save:chatRoom2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
	    if (task.error) {
	        NSLog(@"Error: [%@]", task.error);
		}
	    return nil;
	}];
	[self.chatRoom2Dao insertLocalChatroom2:chatRoom2];
}

- (void)removeFromAWSandLocal:(CHATROOM2 *)chatRoom2 {
	if (chatRoom2 != nil && chatRoom2.RID != nil) {
		AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
		[dynamoDBObjectMapper remove:chatRoom2];
		[self.chatRoom2Dao delChatRoom4ByRid:chatRoom2.RID];
	}
}

- (NSArray *)refreshListWithLocalData {
	return [self.chatRoom2Dao getLocalChatRoom2sByCount:DEFAULT_COUNT];
}

- (void)refreshListWithBlock:(SuccussCompleteBlock)successBlock {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
	scanExpression.limit = [NSNumber numberWithInt:DEFAULT_COUNT];

	[[dynamoDBObjectMapper scan:[CHATROOM2 class]
	                 expression:scanExpression]
	 continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
	    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	    if (task.error) {
	        NSLog(@"The request failed. Error: [%@]", task.error);
		}

	    if (task.exception) {
	        NSLog(@"The request failed. Exception: [%@]", task.exception);
		}

	    AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;

	    successBlock(paginatedOutput.items);

	    AWSDynamoDB_DDUser *userDynamoDB = [[AWSDynamoDB_DDUser alloc] init];

	    for (CHATROOM2 *chatroom2 in paginatedOutput.items) {
	        if (chatroom2.RID != nil && chatroom2.UID1 != nil & chatroom2.UID2 != nil) {
	            //插入本地数据 item
	            if ([self.chatRoom2Dao getLocalChatRoom2ByRid:chatroom2.RID] == nil) {
	                [self.chatRoom2Dao insertLocalChatroom2:chatroom2];
				}

	            if ([userDynamoDB.dduserDao selectDDuserByUid:chatroom2.UID1] == nil) {
	                [userDynamoDB getDDuserAndInsertLocal:chatroom2.UID1];
				}

	            if ([userDynamoDB.dduserDao selectDDuserByUid:chatroom2.UID2] == nil) {
	                [userDynamoDB getDDuserAndInsertLocal:chatroom2.UID2];
				}
			}
		}

	    return nil;
	}];
}

@end
