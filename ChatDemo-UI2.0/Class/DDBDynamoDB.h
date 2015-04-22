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

@class DDUser;
@class BFTask;

@interface DDBDynamoDB : NSObject

- ( void) addUser;

- (void) insertTableRow:(DDUser *)tableRow;

- (DDUser *) getTableUser:(NSString*)uid;

- (void) updateTable:(DDUser *)tableRow;

-(void) addNewUser:(NSString *) name;

@end

@interface DDUser : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *UID;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *password;
//@property (nonatomic, assign) BOOL  *isPic;
@property (nonatomic, strong) NSString *picPath;
//@property(nonatomic,strong)   NSString *firstName;
//@property(nonatomic,strong)   NSString *lastName;
@property(nonatomic,strong)   NSString *gender;
@property(nonatomic,strong)   NSString *university;
//@property(nonatomic,strong)   NSString *city;
@property(nonatomic,strong)   NSString *grade;
//@property(nonatomic,strong)   NSString *phoneNumber;
//@property(nonatomic,assign)   BOOL     *isDoublerID;
//@property(nonatomic,strong)   NSString *doubleID;
@property(nonatomic,strong)   NSString *waitingID;
//@property(nonatomic,assign)   BOOL *autoLogin;
//@property(nonatomic,assign)   BOOL *vibrate;
//@property(nonatomic,assign)   BOOL *silent;
//@property(nonatomic,strong)   NSString *colorTheme;

@end

@interface DDBTableRowTopScore : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *GameTitle;
@property (nonatomic, strong) NSNumber *TopScore;
@property (nonatomic, strong) NSNumber *Wins;
@property (nonatomic, strong) NSNumber *Losses;

@end

@interface DDBTableRowWins : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *GameTitle;
@property (nonatomic, strong) NSNumber *TopScore;
@property (nonatomic, strong) NSNumber *Wins;
@property (nonatomic, strong) NSNumber *Losses;

@end

@interface DDBTableRowLosses : AWSDynamoDBModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *GameTitle;
@property (nonatomic, strong) NSNumber *TopScore;
@property (nonatomic, strong) NSNumber *Wins;
@property (nonatomic, strong) NSNumber *Losses;

@end