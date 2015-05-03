//
//  ChatRoom2DAO.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "ChatRoom4DAO.h"
#import "DDBDynamoDB.h"
#import "ChatRoom4DB.h"
#import "DDUserDAO.h"
#import "AWSDynamoDBObjectMapper.h"


@interface ChatRoom4DAO ()

@property (strong, nonatomic) DDUserDAO *userDao;

@end

NSString *const ChatRoom4Table = @"ChatRoom4";

@implementation ChatRoom4DAO

- (NSString *)tableCreateSql {
	return [NSString stringWithFormat:@"Create table if not exists %@( \
            GID varchar(50) PRIMARY KEY, \
            CTIMEH varchar(50), \
            CTIMER varchar(50), \
            RID varchar(30), \
            UID1 varchar(50), \
            UID2 varchar(50), \
            UID3 varchar(50), \
            UID4 varchar(50), \
            isLikeUID1 INTEGER, \
            isLikeUID2 INTEGER, \
            isLikeUID3 INTEGER, \
            isLikeUID4 INTEGER, \
            subGID1 varchar(50), \
            subGID2 varchar(50), \
            systemTimeNumber varchar(50));", ChatRoom4Table];
}

- (NSArray *)queryChatRoom4s {
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", ChatRoom4Table];
	NSMutableArray *rooms = [NSMutableArray array];
	if ([self.db open]) {
		FMResultSet *rs = [self.db executeQuery:sql];
		while ([rs next]) {
			CHATROOM4 *chatroom4 = [CHATROOM4 new];
			chatroom4.GID = [rs stringForColumn:@"GID"];
			chatroom4.CTIMEH = [rs stringForColumn:@"CTIMEH"];
			chatroom4.CTIMER = [rs stringForColumn:@"CTIMER"];
			chatroom4.RID = [rs stringForColumn:@"RID"];
			chatroom4.UID1 = [rs stringForColumn:@"UID1"];
			chatroom4.UID2 = [rs stringForColumn:@"UID2"];
			chatroom4.UID3 = [rs stringForColumn:@"UID3"];
			chatroom4.UID4 = [rs stringForColumn:@"UID4"];
			chatroom4.isLikeUID1 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID1"]];
			chatroom4.isLikeUID2 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID2"]];
			chatroom4.isLikeUID3 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID3"]];
			chatroom4.isLikeUID4 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID4"]];
			chatroom4.subGID1 = [rs stringForColumn:@"subGID1"];
			chatroom4.subGID2 = [rs stringForColumn:@"subGID2"];
			chatroom4.systemTimeNumber = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"systemTimeNumber"]];
			[rooms addObject:chatroom4];
		}
		[rs close];
		[self.db close];
	}
	return rooms;
}

#pragma mark - Public

- (void)refreshList {
	//先查询，没有在网络数据库
	NSLog(@"Begin");
	self.chatroom4s = [self getTenLocalChatRoom4];
	NSLog(@"End");
	if (self.chatroom4s == nil || [self.chatroom4s count] == 0) {
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
		    self.chatroom4s = paginatedOutput.items;
		    for (CHATROOM4 *chatroom4 in paginatedOutput.items) {
		        if (chatroom4.GID != nil && chatroom4.UID1 != nil & chatroom4.UID2 != nil & chatroom4.UID3 != nil & chatroom4.UID4 != nil) {
		            //插入本地数据 item
		            if ([self getChatRoom4ByRid:chatroom4.GID] == nil) {
		                [self insertChatroom4:chatroom4];
					}

		            if ([self.userDao selectDDuserByUid:chatroom4.UID1] == nil) {
		                [self.userDao getTableRowAndInsertLocal:chatroom4.UID1];
					}
		            if ([self.userDao selectDDuserByUid:chatroom4.UID2] == nil) {
		                [self.userDao getTableRowAndInsertLocal:chatroom4.UID2];
					}
		            if ([self.userDao selectDDuserByUid:chatroom4.UID3] == nil) {
		                [self.userDao getTableRowAndInsertLocal:chatroom4.UID3];
					}
		            if ([self.userDao selectDDuserByUid:chatroom4.UID4] == nil) {
		                [self.userDao getTableRowAndInsertLocal:chatroom4.UID4];
					}
				}
			}

		    return nil;
		}];
	}
}

#pragma mark - Private

- (void)insertChatroom4:(CHATROOM4 *)chatRoom4 {
	NSString *sql = [NSString stringWithFormat:@"Insert or ignore into %@ ( \
                     GID, \
                     CTIMEH, \
                     CTIMER, \
                     UID1, \
                     UID2, \
                     UId3, \
                     UID4, \
                     isLikeUID1, \
                     isLikeUID2,\
                     isLikeUID3,\
                     isLikeUID4,\
                     subGID1,\
                     subGID2,\
                     systemTimeNumber) \
                     values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ChatRoom4Table];

	if ([self.db open]) {
		[self.db executeUpdate:sql,
		 chatRoom4.GID,
		 chatRoom4.CTIMEH,
		 chatRoom4.CTIMER,
		 chatRoom4.UID1,
		 chatRoom4.UID2,
		 chatRoom4.UID3,
		 chatRoom4.UID4,
		 chatRoom4.isLikeUID1,
		 chatRoom4.isLikeUID2,
		 chatRoom4.isLikeUID3,
		 chatRoom4.isLikeUID4,
		 chatRoom4.subGID1,
		 chatRoom4.subGID2,
		 chatRoom4.systemTimeNumber];
		[self.db close];
	}
}

- (NSMutableArray *)getTenLocalChatRoom4 {
	NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:10];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by systemTimeNumber limit 10", ChatRoom4Table];
	if ([self.db open]) {
		FMResultSet *rs = [self.db executeQuery:sql];
		while ([rs next]) {
			CHATROOM4 *chatroom4 = [CHATROOM4 new];
			chatroom4.GID = [rs stringForColumn:@"GID"];
			chatroom4.CTIMER = [rs stringForColumn:@"CTIMER"];
			chatroom4.CTIMEH = [rs stringForColumn:@"CTIMEH"];
			chatroom4.UID1 = [rs stringForColumn:@"UID1"];
			chatroom4.UID2 = [rs stringForColumn:@"UID2"];
			chatroom4.UID3 = [rs stringForColumn:@"UID3"];
			chatroom4.UID4 = [rs stringForColumn:@"UID4"];
			chatroom4.isLikeUID1 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID1"]];
			chatroom4.isLikeUID2 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID2"]];
			chatroom4.isLikeUID3 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID3"]];
			chatroom4.isLikeUID4 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID4"]];
			chatroom4.subGID1 = [rs stringForColumn:@"subGID1"];
			chatroom4.subGID2 = [rs stringForColumn:@"subGID2"];
			chatroom4.systemTimeNumber = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"systemTimeNumber"]];

			[rooms addObject:chatroom4];
		}
		[rs close];
		[self.db close];
	}
	return rooms;
}

- (CHATROOM4 *)getChatRoom4ByRid:(NSString *)rid {
	CHATROOM4 *chatroom4;
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where RID='%@'", ChatRoom4Table, rid];
	if ([self.db open]) {
		FMResultSet *rs = [self.db executeQuery:sql];
		while ([rs next]) {
			CHATROOM4 *chatroom4 = [CHATROOM4 new];
			chatroom4.GID = [rs stringForColumn:@"GID"];
			chatroom4.CTIMER = [rs stringForColumn:@"CTIMER"];
			chatroom4.CTIMEH = [rs stringForColumn:@"CTIMEH"];
			chatroom4.UID1 = [rs stringForColumn:@"UID1"];
			chatroom4.UID2 = [rs stringForColumn:@"UID2"];
			chatroom4.UID3 = [rs stringForColumn:@"UID3"];
			chatroom4.UID4 = [rs stringForColumn:@"UID4"];
			chatroom4.isLikeUID1 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID1"]];
			chatroom4.isLikeUID2 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID2"]];
			chatroom4.isLikeUID3 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID3"]];
			chatroom4.isLikeUID4 = [NSNumber numberWithInt:[rs intForColumn:@"isLikeUID4"]];
			chatroom4.subGID1 = [rs stringForColumn:@"subGID1"];
			chatroom4.subGID2 = [rs stringForColumn:@"subGID2"];
			chatroom4.systemTimeNumber = [NSNumber numberWithLongLong:[rs longLongIntForColumn:@"systemTimeNumber"]];
		}
		[rs close];
		[self.db close];
	}
	return chatroom4;
}

#pragma mark - Getter
- (DDUserDAO *)userDao {
	if (_userDao == nil) {
		_userDao = [[DDUserDAO alloc] init];
	}
	return _userDao;
}

@end
