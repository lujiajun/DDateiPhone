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

@class BFTask;
@class CHATROOM4;

@interface ChatRoom4DB : NSObject


- (void)updateTable:(CHATROOM4 *)tableRow;


- (void)insertChatroom4:(CHATROOM4 *) chatRoom4;
-(void) deleteRoom4:(NSString *) gid;
-(CHATROOM4 *)getCHATROOM4:(NSString*) uid;

@end
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