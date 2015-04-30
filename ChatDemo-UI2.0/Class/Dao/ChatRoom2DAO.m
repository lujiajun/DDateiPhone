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
            ID INTEGER PRIMARY KEY AUTOINCREMENT, \
            RID varchar(50), \
            ClickNum varchar(10), \
            Gender varchar(10), \
            GradeFrom varchar(10), \
            Motto varchar(50), \
            PicturePath varchar(50), \
            SchoolRestrict varchar(50), \
            UID1 varchar(50), \
            UID2 varchar(50));", ChatRoom2Table];
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

- (void)refreshList {
	//先查询，没有在网络数据库
	self.chatroom2s = [self getTenLocalChatRoom2];
	if (self.chatroom2s == nil || [self.chatroom2s count] == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

		AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
		scanExpression.limit = @10;
		AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
		BFTask *bftask = [dynamoDBObjectMapper scan:[CHATROOM2 class] expression:scanExpression];
		[bftask waitUntilFinished];
		AWSDynamoDBPaginatedOutput *paginatedOutput = bftask.result;
		self.chatroom2s = paginatedOutput.items;
		for (CHATROOM2 *item in paginatedOutput.items) {
			if (item.RID != nil && item.UID1 != nil & item.UID2 != nil) {
				//插入本地数据 item
				if ([self getChatRoom2ByRid:item.RID] == nil) {
					[self insertChatroom2:item];
				}

				if ([self.userDao selectDDuserByUid:item.UID1] == nil) {
					[self.userDao getTableRowAndInsertLocal:item.UID1];
				}
				if ([self.userDao selectDDuserByUid:item.UID2] == nil) {
					[self.userDao getTableRowAndInsertLocal:item.UID2];
				}
			}
		}
	}
}


#pragma mark - Private

- (void)insertChatroom2:(CHATROOM2 *)chatRoom2 {
    NSString *sql = [NSString stringWithFormat:@"Insert into %@ (%@, %@, %@, %@, %@, %@, %@, %@, %@)" , ChatRoom2Table,
                     chatRoom2.RID,
                     chatRoom2.ClickNum,
                     chatRoom2.Gender,
                     chatRoom2.GradeFrom,
                     chatRoom2.Motto,
                     chatRoom2.PicturePath,
                     chatRoom2.SchoolRestrict,
                     chatRoom2.UID1,
                     chatRoom2.UID2];
    
    if ([self.db open]) {
        [self.db executeUpdate:sql];
        [self.db close];
    }
}

- (NSMutableArray *)getTenLocalChatRoom2 {
	NSMutableArray *rooms = [NSMutableArray arrayWithCapacity:10];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ order by ID limit 10", ChatRoom2Table];
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
	NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where RID='%@", ChatRoom2Table, rid];
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
