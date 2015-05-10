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

@implementation AWSDynamoDB_ChatRoom2

- (instancetype)init {
    if (self = [super init]) {
        _chatRoom2Dao = [[ChatRoom2DAO alloc] init];
    }
    return self;
}

- (void)insertChatroom2:(CHATROOM2 *)chatRoom2 {
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	[[dynamoDBObjectMapper save:chatRoom2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
	    if (task.error) {
	      	NSLog(@"Error: [%@]", task.error);
		}
	    return nil;
	}];
}

- (void)refreshListWithBlock:(SuccussBlock)successBlock {
    //先查询，没有在网络数据库
    self.chatRoom2s = [self.chatRoom2Dao getLocalChatRoom2ByCount:20];
    if (self.chatRoom2s == nil || [self.chatRoom2s count] == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        scanExpression.limit = @20;
        
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
             self.chatRoom2s = paginatedOutput.items;
             successBlock();
             
             AWSDynamoDB_DDUser *userDynamoDB = [[AWSDynamoDB_DDUser alloc] init];
             
             for (CHATROOM2 *chatroom2 in paginatedOutput.items) {
                 if (chatroom2.RID != nil && chatroom2.UID1 != nil & chatroom2.UID2 != nil) {
                     //插入本地数据 item
                     if ([self.chatRoom2Dao getChatRoom2ByRid:chatroom2.RID] == nil) {
                         [self.chatRoom2Dao insertChatroom2:chatroom2];
                         
//                         [self insertChatroom2:chatroom2];
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
    } else {
        successBlock();
    }
}



@end

