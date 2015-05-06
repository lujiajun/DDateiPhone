//
//  ChatRoom2DAO.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "ChatRoom2DAO.h"
#import "AWSDynamoDBObjectMapper.h"
#import "DDUserDAO.h"
#import "CHATROOM2.h"

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
            [rooms addObject:[self fillModelWithFMResultSet:rs]];
        }
        [rs close];
        [self.db close];
    }
    return rooms;
}

#pragma mark - Public



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

- (id)fillModelWithFMResultSet:(FMResultSet *)rs {
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
    return chatroom2;
}

@end
