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

#import "DDBDynamoDB.h"
#import "AWSDynamoDB/AWSDynamoDB.h"
#import "BFExecutor.h"


@implementation DDBDynamoDB


- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}

-(void) updateTable:(DDUser *)tableRow{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
    

}

-(DDUser *)getTableUser:(NSString*) uid{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    [[dynamoDBObjectMapper load:[DDUser class] hashKey:uid rangeKey:nil]
     continueWithBlock:^id(BFTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.exception) {
             NSLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             DDUser *user=task.result;
              return  user;
          
             //Do something with the result.
         }
         return nil;
     }];
    return nil;
}

-(DDUser *)getUserByUid:(NSString*) uid{
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
   BFTask *task= [dynamoDBObjectMapper load:[DDUser class] hashKey:uid rangeKey:nil];
    if (task.result) {
        DDUser *user=task.result;
        return  user;
      
    }
    return nil;
}


#pragma mark - ChatRoom2
- (void)insertChatroom2:(CHATROOM2 *)chatRoom2 {
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	[[dynamoDBObjectMapper save:chatRoom2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
	    if (task.error) {
	      	NSLog(@"Error: [%@]", task.error);
		}
	    return nil;
	}];
}


@end

@implementation DDUser

+ (NSString *)dynamoDBTableName {
    return @"USER";
}

+ (NSString *)hashKeyAttribute {
    return @"UID";
}


@end

@implementation CHATROOM2

+ (NSString *)dynamoDBTableName {
    return @"CHATROOM2";
}

+ (NSString *)hashKeyAttribute {
    return @"RID";
}

@end
