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

#import "AWSDynamoDB_ChatRoom4.h"
#import "AWSDynamoDB/AWSDynamoDB.h"
#import "BFExecutor.h"
#import "IndexViewController.h"
#import "ChatRoom4DAO.h"
#import "AWSDynamoDBObjectMapper.h"
#import "CHATROOM2.h"

@interface AWSDynamoDB_ChatRoom4 ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;

@end


@implementation AWSDynamoDB_ChatRoom4

- (instancetype)init {
	if (self = [super init]) {
		_chatRoom4Dao = [[ChatRoom4DAO alloc] init];
		_dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	}
	return self;
}

- (void)insertChatroom4:(CHATROOM4 *)tableRow {
	if (tableRow != nil && tableRow.GID != nil) {
		[[self.dynamoDBObjectMapper save:tableRow] continueWithSuccessBlock: ^id (BFTask *task) {
		    NSLog(@"insert to aws success");
		    [self.chatRoom4Dao insertChatroom4:tableRow];
		    return nil;
		}];
	}
}

- (void)updateChatroom4:(CHATROOM4 *)tableRow {
	if (tableRow != nil && tableRow.GID != nil) {
		[[self.dynamoDBObjectMapper save:tableRow] continueWithSuccessBlock: ^id (BFTask *task) {
		    NSLog(@"insert to aws success");
		    [self.chatRoom4Dao updateChatroom4:tableRow];
		    return nil;
		}];
	}
}

- (void)updateLikeByGID:(CHATROOM4 *)tableRow {
	[[self.dynamoDBObjectMapper save:tableRow] continueWithSuccessBlock: ^id (BFTask *task) {
	    [self.chatRoom4Dao updateLikeByGID:tableRow];
	    return nil;
	}];
}

- (void)updateSubGroupTable:(CHATROOM4 *)tableRow {
	[[self.dynamoDBObjectMapper save:tableRow] continueWithSuccessBlock: ^id (BFTask *task) {
	    [self.chatRoom4Dao updateSubGroupByGID:tableRow];
	    return nil;
	}];
}

- (void)deleteRoom4:(NSString *)gid {
	CHATROOM4 *room4 = [CHATROOM4 new];
	room4.GID = gid;
	[[self.dynamoDBObjectMapper remove:room4] continueWithBlock: ^id (BFTask *task) {
	    if (task.error) {
	        NSLog(@"The request failed. Error: [%@]", task.error);
		}
	    if (task.exception) {
	        NSLog(@"The request failed. Exception: [%@]", task.exception);
		}
	    //删除
	    [self.chatRoom4Dao delChatRoom4ByRid:gid];
	    return nil;
	}];
}


- (CHATROOM4 *)syncGetChatroom4ByGid:(NSString *)gid {
	BFTask *task = [self.dynamoDBObjectMapper load:[CHATROOM4 class] hashKey:gid rangeKey:nil];
	[task waitUntilFinished];
	return task.result;
}

- (CHATROOM4 *)syncGetChatroom4AndInsertLocal:(NSString *)gid {
	BFTask *task = [self.dynamoDBObjectMapper load:[CHATROOM4 class] hashKey:gid rangeKey:nil];
	[task waitUntilFinished];
	[self.chatRoom4Dao insertChatroom4:task.result];
	return task.result;
}


- (CHATROOM4 *)getChatroom4InsertLocal:(NSString *)uid {
	[[self.dynamoDBObjectMapper load:[CHATROOM4 class] hashKey:uid rangeKey:nil]
	 continueWithBlock: ^id (BFTask *task) {
	    if (task.error) {
	        NSLog(@"The request failed. Error: [%@]", task.error);
		}
	    if (task.exception) {
	        NSLog(@"The request failed. Exception: [%@]", task.exception);
		}
	    if (task.result) {
	        CHATROOM4 *room4 = task.result;
	        if (room4 != nil && room4.GID != nil) {
	            ChatRoom4DAO *room4Dao = [[ChatRoom4DAO alloc] init];
	            [room4Dao insertChatroom4:room4];
	            return room4;
			}
		}
	    return nil;
	}];
	return nil;
}

@end
