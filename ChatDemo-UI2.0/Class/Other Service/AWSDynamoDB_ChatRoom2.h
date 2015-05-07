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

#import <Foundation/Foundation.h>
#import "AWSDynamoDB/AWSDynamoDB.h"
#import "CHATROOM2.h"
#import "ChatRoom2DAO.h"

typedef void(^SuccussBlock)();

@interface AWSDynamoDB_ChatRoom2 : NSObject

@property(strong, nonatomic) ChatRoom2DAO *chatRoom2Dao;

@property(strong, nonatomic) NSArray *chatRoom2s;

- (void)refreshListWithBlock:(SuccussBlock)successBlock;

- (void)insertChatroom2:(CHATROOM2 *)chatRoom2;

@end


