//
//  ChatRoom2DAO.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "ChatRoom2DAO.h"
#import "DDBDynamoDB.h"
#import "AWSDynamoDBObjectMapper.h"
#import "DDUserDAO.h"

@interface ChatRoom2DAO()

@property(strong, nonatomic) DDUserDAO *userDao;

@end

NSString *const ChatRoom2Table = @"ChatRoom2";

@implementation ChatRoom2DAO

- (NSString *)tableCreateSql {
	return [NSString stringWithFormat:@"Create table if not exists %@( \
            RID varchar(50) PRIMARY KEY, \
            ClickNum varchar(10), \
            Gender varchar(10), \
            GradeFrom varchar(10), \
            Motto varchar(50), \
            PicturePath varchar(50), \
            SchoolRestrict varchar(50), \
            UID1 varchar(50), \
            UID2 varchar(50),\
            UNIQUE(RID));", ChatRoom2Table];
}

- (NSArray *)queryChatRoom2s {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", ChatRoom2Table];
    NSMutableArray *rooms = [NSMutableArray array];
    if ([self.db open]) {
        FMResultSet *rs = [self.db executeQuery:sql];
        while ([rs next]) {
            CHATROOM2 *chatroom2 = [CHATROOM2 new];
            chatroom2.RID = [rs stringForColumn:@"RID"];
            chatroom2.ClickNum = [rs stringForColumn:@"ClickNum"];
            chatroom2.Gender = [rs stringForColumn:@"Gender"];
            chatroom2.GradeFrom = [rs stringForColumn:@"GradeFrom"];
            chatroom2.Motto = [rs stringForColumn:@"Motto"];
            chatroom2.PicturePath = [rs stringForColumn:@"PicturePath"];
            chatroom2.SchoolRestrict = [rs stringForColumn:@"SchoolRestrict"];
            chatroom2.UID1 = [rs stringForColumn:@"UID1"];
            chatroom2.UID2 = [rs stringForColumn:@"UID2"];
            [rooms addObject:chatroom2];
        }
        [rs close];
        [self.db close];
    }
    return rooms;
}

#pragma mark - Public

- (void)refreshListWithBlock:(SuccussBlock)successBlock {
	//先查询，没有在网络数据库
	self.chatroom2s = [self getLocalChatRoom2ByCount:20];
	if (self.chatroom2s == nil || [self.chatroom2s count] == 0) {
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
		    self.chatroom2s = paginatedOutput.items;
		    successBlock();
		    for (CHATROOM2 *chatroom2 in paginatedOutput.items) {
		        if (chatroom2.RID != nil && chatroom2.UID1 != nil & chatroom2.UID2 != nil) {
		            //插入本地数据 item
		            if ([self getChatRoom2ByRid:chatroom2.RID] == nil) {
		                [self insertChatroom2:chatroom2];
					}

		            if ([self.userDao selectDDuserByUid:chatroom2.UID1] == nil) {
		                [self.userDao getTableRowAndInsertLocal:chatroom2.UID1];
					}
		            if ([self.userDao selectDDuserByUid:chatroom2.UID2] == nil) {
		                [self.userDao getTableRowAndInsertLocal:chatroom2.UID2];
					}
				}
			}

		    return nil;
		}];
	} else {
		successBlock();
	}
}


#pragma mark - Private

- (void)insertChatroom2:(CHATROOM2 *)chatRoom2 {
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ ( \
                     RID, \
                     ClickNum, \
                     Gender, \
                     GradeFrom, \
                     Motto, \
                     PicturePath, \
                     SchoolRestrict, \
                     UID1, \
                     UID2) \
                     values (?, ?, ?, ?, ?, ?, ?, ?, ?)" , ChatRoom2Table];
    
	if ([self.db open]) {
		[self.db executeUpdate:sql,
		 chatRoom2.RID,
		 chatRoom2.ClickNum,
		 chatRoom2.Gender,
		 chatRoom2.GradeFrom,
		 chatRoom2.Motto,
		 chatRoom2.PicturePath,
		 chatRoom2.SchoolRestrict,
		 chatRoom2.UID1,
		 chatRoom2.UID2];
		[self.db close];
	}
}

- (NSMutableArray *)getLocalChatRoom2ByCount:(int)count {
	NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:10];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by ID limit %d", ChatRoom2Table, count];
	if ([self.db open]) {
		FMResultSet *rs = [self.db executeQuery:sql];
		while ([rs next]) {
			CHATROOM2 *chatroom2 = [CHATROOM2 new];
			chatroom2.RID = [rs stringForColumn:@"RID"];
			chatroom2.ClickNum = [rs stringForColumn:@"ClickNum"];
			chatroom2.Gender = [rs stringForColumn:@"Gender"];
			chatroom2.GradeFrom = [rs stringForColumn:@"GradeFrom"];
			chatroom2.Motto = [rs stringForColumn:@"Motto"];
			chatroom2.PicturePath = [rs stringForColumn:@"PicturePath"];
			chatroom2.SchoolRestrict = [rs stringForColumn:@"SchoolRestrict"];
			chatroom2.UID1 = [rs stringForColumn:@"UID1"];
			chatroom2.UID2 = [rs stringForColumn:@"UID2"];
			[rooms addObject:chatroom2];
		}
		[rs close];
		[self.db close];
	}
	return rooms;
}

- (CHATROOM2 *)getChatRoom2ByRid:(NSString *)rid {
	CHATROOM2 *chatroom2;
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where RID='%@'", ChatRoom2Table, rid];
	if ([self.db open]) {
		FMResultSet *rs = [self.db executeQuery:sql];
		while ([rs next]) {
			chatroom2 = [CHATROOM2 new];
			chatroom2.RID = [rs stringForColumn:@"RID"];
			chatroom2.ClickNum = [rs stringForColumn:@"ClickNum"];
			chatroom2.Gender = [rs stringForColumn:@"Gender"];
			chatroom2.GradeFrom = [rs stringForColumn:@"GradeFrom"];
			chatroom2.Motto = [rs stringForColumn:@"Motto"];
			chatroom2.PicturePath = [rs stringForColumn:@"PicturePath"];
			chatroom2.SchoolRestrict = [rs stringForColumn:@"SchoolRestrict"];
			chatroom2.UID1 = [rs stringForColumn:@"UID1"];
			chatroom2.UID2 = [rs stringForColumn:@"UID2"];
		}
		[rs close];
		[self.db close];
	}
	return chatroom2;
}

#pragma mark - Getter
- (DDUserDAO *)userDao {
    if (_userDao == nil) {
        _userDao = [[DDUserDAO alloc] init];
    }
    return _userDao;
}

@end
