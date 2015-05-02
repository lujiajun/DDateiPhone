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

#import "ChatRoom4DB.h"
#import "AWSDynamoDB/AWSDynamoDB.h"
#import "BFExecutor.h"
#import "IndexViewController.h"
#import "ChatRoom4DAO.h"


@implementation ChatRoom4DB


- (void)insertChatroom4:(CHATROOM4 *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}

-(void) updateTable:(CHATROOM4 *)tableRow{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
    
    
}

-(void) deleteRoom4:(NSString *) gid{
    CHATROOM4 *room4 = [CHATROOM4 new];
    room4.GID = gid;
     AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper remove:room4]
     continueWithBlock:^id(BFTask *task) {
         
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             //Item deleted.
         }
         return nil;
     }];
}

-(CHATROOM4 *)getCHATROOM4:(NSString*) uid{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[CHATROOM4 class] hashKey:uid rangeKey:nil]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             CHATROOM4 *room4 = task.result;
             return  room4;
             //Do something with the result.
         }
         return nil;
     }];
    return nil;
}

-(CHATROOM4 *)getChatroom4InsertLocal:(NSString*) uid{
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        
        [[dynamoDBObjectMapper load:[CHATROOM4 class] hashKey:uid rangeKey:nil]
         continueWithBlock:^id(BFTask *task) {
             if (task.error) {
                 NSLog(@"The request failed. Error: [%@]", task.error);
             }
             if (task.exception) {
                 NSLog(@"The request failed. Exception: [%@]", task.exception);
             }
             if (task.result) {
                 CHATROOM4 *room4 = task.result;
                 ChatRoom4DAO *room4Dao=[[ChatRoom4DAO alloc] init];
                 [room4Dao insertChatroom4:room4];
                 return  room4;
                 //Do something with the result.
             }
             return nil;
         }];
        return nil;
  
}



@end


@implementation CHATROOM4

+ (NSString *)dynamoDBTableName {
    return @"CHATROOM4";
}

+ (NSString *)hashKeyAttribute {
    return @"GID";
}

@end
