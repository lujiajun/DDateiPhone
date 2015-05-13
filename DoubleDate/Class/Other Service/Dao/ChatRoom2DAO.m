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
            Gender INTEGER, \
            GradeFrom varchar(10), \
            Motto varchar(50), \
            PicturePath varchar(50), \
            SchoolRestrict varchar(50), \
            UID1 varchar(50), \
            UID2 varchar(50),\
            UNIQUE(RID));", ChatRoom2Table];
}




- (void)insertLocalChatroom2:(CHATROOM2 *)chatRoom2 {
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
                     values (?, ?, ?, ?, ?, ?, ?, ?, ?)", ChatRoom2Table];

	[self.dbQueue inDatabase: ^(FMDatabase *db) {
	    [db executeUpdate:sql,
	     chatRoom2.RID,
	     chatRoom2.ClickNum,
	     chatRoom2.Gender,
	     chatRoom2.GradeFrom,
	     chatRoom2.Motto,
	     chatRoom2.PicturePath,
	     chatRoom2.SchoolRestrict,
	     chatRoom2.UID1,
	     chatRoom2.UID2];
	}];
}

- (CHATROOM2 *)getLocalChatRoom2ByRid:(NSString *)rid {
    __block CHATROOM2 *chatroom2;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where RID='%@'", ChatRoom2Table, rid];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            chatroom2 = [self fillModelWithFMResultSet:rs];
        }
        [rs close];

    }];
    return chatroom2;
}

- (void)delChatRoom2ByRid:(NSString *)rid {
    NSString *sql = [NSString stringWithFormat:@"delete FROM %@ where RID='%@'", ChatRoom2Table, rid];
    [self.dbQueue inDatabase: ^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}


- (NSMutableArray *)getLocalChatRoom2sByCount:(int)count {
	NSMutableArray *rooms = [NSMutableArray array];
	NSString *sql = [NSString stringWithFormat:@"select * from %@ limit %d", ChatRoom2Table, count];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            CHATROOM2 *chatroom2 = [self fillModelWithFMResultSet:rs];
            [rooms addObject:chatroom2];
        }
        [rs close];
    }];
	return rooms;
}


- (NSArray *)queryChatRoom2s {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", ChatRoom2Table];
    NSMutableArray *rooms = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            [rooms addObject:[self fillModelWithFMResultSet:rs]];
        }
        [rs close];
    }];
    return rooms;
}



# pragma mark - Private

- (id)fillModelWithFMResultSet:(FMResultSet *)rs {
    CHATROOM2 *chatroom2 = [CHATROOM2 new];
    chatroom2.RID = [rs stringForColumn:@"RID"];
    chatroom2.ClickNum = [rs stringForColumn:@"ClickNum"];
    chatroom2.Gender = [NSNumber numberWithInt:[rs intForColumn:@"Gender"]];
    chatroom2.GradeFrom = [rs stringForColumn:@"GradeFrom"];
    chatroom2.Motto = [rs stringForColumn:@"Motto"];
    chatroom2.PicturePath = [rs stringForColumn:@"PicturePath"];
    chatroom2.SchoolRestrict = [rs stringForColumn:@"SchoolRestrict"];
    chatroom2.UID1 = [rs stringForColumn:@"UID1"];
    chatroom2.UID2 = [rs stringForColumn:@"UID2"];
    return chatroom2;
}

@end
