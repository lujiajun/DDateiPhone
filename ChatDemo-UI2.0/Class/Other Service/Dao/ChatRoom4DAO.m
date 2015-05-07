//
//  ChatRoom2DAO.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "ChatRoom4DAO.h"
#import "DDUserDAO.h"
#import "AWSDynamoDBObjectMapper.h"
#import "CHATROOM2.h"
#import "AWSDynamoDB_DDUser.h"


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
			CHATROOM4 *chatroom4 = [self fillModelWithFMResultSet:rs];
			[rooms addObject:chatroom4];
		}
		[rs close];
		[self.db close];
	}
	return rooms;
}

- (void)insertChatroom4:(CHATROOM4 *)chatRoom4 {
	if (chatRoom4 == nil || chatRoom4.GID == nil) {
		return;
	}
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

- (NSMutableArray *)getLocalChatRoom4ByCount:(int) count {
	NSMutableArray *rooms = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ order by systemTimeNumber limit %d", ChatRoom4Table, count];
	if ([self.db open]) {
		FMResultSet *rs = [self.db executeQuery:sql];
		while ([rs next]) {
			CHATROOM4 *chatroom4 = [self fillModelWithFMResultSet:rs];
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
			chatroom4 = [self fillModelWithFMResultSet:rs];
		}
		[rs close];
		[self.db close];
	}
	return chatroom4;
}

- (CHATROOM4 *)isUniqueRoom:(NSString *)UID1 UID2:(NSString *)UID2 UID3:(NSString *)UID3 UID4:(NSString *)UID4 {
	if (UID1 != nil && UID2 != nil && UID3 != nil && UID4 != nil) {
		NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where UID1='%@' and UID2='%@' and UID3='%@' and UID4='%@' ", ChatRoom4Table, UID1, UID2, UID3, UID4];
		if ([self.db open]) {
			FMResultSet *rs = [self.db executeQuery:sql];
			while ([rs next]) {
				CHATROOM4 *chatroom4 = [self fillModelWithFMResultSet:rs];
				return chatroom4;
			}
		}
	}
	return nil;
}

- (void)delChatRoom4ByRid:(NSString *)rid {
	NSString *sql = [NSString stringWithFormat:@"delete FROM %@ where GID='%@'", ChatRoom4Table, rid];
	if ([self.db open]) {
		[self.db executeQuery:sql];
		[self.db close];
	}
}

- (id)fillModelWithFMResultSet:(FMResultSet *)rs {
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
	return chatroom4;
}

@end
