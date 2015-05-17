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
#import "CHATROOM4.h"
#import "ChatRoom4DAO.h"


@interface AWSDynamoDB_ChatRoom4 : NSObject

@property (nonatomic, strong) ChatRoom4DAO *chatRoom4Dao;
@property (strong, nonatomic) NSArray *chatroom4s;


- (void)updateLikeByGID:(CHATROOM4 *)tableRow;
-(void) updateSubGroupTable:(CHATROOM4 *)tableRow;


- (void)insertChatroom4:(CHATROOM4 *) chatRoom4;
- (void)updateChatroom4:(CHATROOM4 *)tableRow;
-(void) deleteRoom4:(NSString *) gid;
-(CHATROOM4 *)getCHATROOM4:(NSString*) uid;

-(CHATROOM4 *)getChatroom4InsertLocal:(NSString*) uid;


- (void)refreshList;

@end
