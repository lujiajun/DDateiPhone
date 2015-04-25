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


@implementation DDBDynamoDB

-(void) addUser{
    DDUser *user=[DDUser new];
    
    user.UID=@"liufei";
    user.nickName=@"dafei";
    user.gender=@"男";
    user.grade=@"大二";
//    user.isDoublerID=YES;
//    user.isPic=YES;
    user.password=@"ere";
    user.university=@"北京大学";
    user.picPath=@"xxx";
//    user.waitingID=@"uu";
    [self insertTableRow:user];
}

- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
//    
//    [[dynamoDBObjectMapper save:tableRow]
//     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
//         if (!task.error) {
//             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
//                                                             message:@"Successfully inserted the data into the table."
//                                                            delegate:nil
//                                                   cancelButtonTitle:@"OK"
//                                                   otherButtonTitles:nil];
//             
//         } else {
//             NSLog(@"Error: [%@]", task.error);
//             
//             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                             message:@"Failed to insert the data into the table."
//                                                            delegate:nil
//                                                   cancelButtonTitle:@"OK"
//                                                   otherButtonTitles:nil];
//             [alert show];
//         }
//         
//         return nil;
//     }];
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
              DDUser *user = task.result;
             return  user;
             //Do something with the result.
         }
         return nil;
     }];
    return nil;
}

-(DDUser *) addNewUser:(NSString *) name{
    
              DDUser  *user=[DDUser new];
                user.UID=name;
                user.nickName=@"defaultname";
                user.gender=@"男";
                user.grade=@" ";
                user.university=@"default";
                user.password=@"xxx";
                [self insertTableRow:user];
    return user;
//     continueWithBlock:^id(BFTask *task) {
//         if (task.error) {
//             NSLog(@"The request failed. Error: [%@]", task.error);
//         }
//         if (task.exception) {
//             NSLog(@"The request failed. Exception: [%@]", task.exception);
//         }
//         if (task.result) {
//             DDUser *user = task.result;
//             if(user.UID==nil){
//                 user=[DDUser new];
//                 user.UID=name;
//                 user.nickName=@"defaultname";
//                 user.gender=@"男";
//                 user.grade=@" ";
//                 user.university=@"default";
//                 user.password=@"xxx";
//                 [self insertTableRow:user];
//                 return user;
//             }
//             return  user;
//             //Do something with the result.
//         }
//         return nil;
//     }];
//    return nil;
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

@implementation DDBTableRowTopScore

+ (NSString *)dynamoDBTableName {
    return @"";
}

+ (NSString *)hashKeyAttribute {
    return @"GameTitle";
}

+ (NSString *)rangeKeyAttribute {
    return @"TopScore";
}

@end

@implementation DDBTableRowWins

+ (NSString *)dynamoDBTableName {
    return @"";
}

+ (NSString *)hashKeyAttribute {
    return @"GameTitle";
}

+ (NSString *)rangeKeyAttribute {
    return @"Wins";
}

@end

@implementation DDBTableRowLosses

+ (NSString *)dynamoDBTableName {
    return @"";
}

+ (NSString *)hashKeyAttribute {
    return @"GameTitle";
}

+ (NSString *)rangeKeyAttribute {
    return @"Losses";
}

@end
