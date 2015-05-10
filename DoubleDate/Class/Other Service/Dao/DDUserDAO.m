//
//  DDUserDAO.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "DDUserDAO.h"
#import "AWSDynamoDBObjectMapper.h"

NSString * const DDUserTable=@"DDUser";

@implementation DDUserDAO

- (NSString *)tableCreateSql {
	return [NSString stringWithFormat:@"Create table if not exists %@( \
            ID INTEGER PRIMARY KEY AUTOINCREMENT, \
            UID varchar(50), \
            nickName varchar(50), \
            password varchar(50),\
            isPic INTEGER, \
            picPath TEXT, \
            gender varchar(10), \
            university varchar(10), \
            grade varchar(10), \
            isDoublerID INTEGER, \
            photos varchar(100), \
            city varchar(50),\
            birthday varchar(50),\
            hobbies varchar(200),\
            sign varchar(200),\
            UNIQUE(UID));", DDUserTable];
}

- (DDUser *)selectDDuserByUid:(NSString *)uid {
    __block DDUser *dduser;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE UID='%@'", DDUserTable, uid];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            dduser = [self fillModelWithFMResultSet:rs];
        }
        [rs close];
    }];
    return dduser;
}


- (void)insertDDUser:(DDUser *)dduser {
    NSString *sql = [NSString stringWithFormat:@"Insert or ignore into %@ ( \
                     UID, \
                     nickName, \
                     password,\
                     isPic, \
                     picPath, \
                     gender, \
                     university, \
                     grade, \
                     photos,\
                     city,\
                     birthday,\
                     hobbies,\
                     sign,\
                     isDoublerID) \
                     values(?, ?, ?,?, ?, ?, ?, ?, ?,?,?,?,?,?)", DDUserTable];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL res = [db executeUpdate:sql,
                    dduser.UID,
                    dduser.nickName,
                    dduser.password,
                    dduser.isPic,
                    dduser.picPath,
                    dduser.gender,
                    dduser.university,
                    dduser.grade,
                    dduser.photos,
                    dduser.city,
                    dduser.birthday,
                    dduser.hobbies,
                    dduser.sign,
                    dduser.isDoublerID];
        if (res) {
            NSLog(@"DDUser: success to insert db");
        } else {
            NSLog(@"DDUser: error when insert db");
        }

    }];
}

- (void)updatePhotosByUID:(NSString *)photos uid:(NSString *)UID {
	[self.dbQueue inDatabase: ^(FMDatabase *db) {
	    BOOL res = [db executeUpdate:@"UPDATE DDUser SET photos = ? WHERE UID = ?", photos, UID];
	    if (res) {
	        NSLog(@"DDUser: success to update db");
		} else {
	        NSLog(@"DDUser: error when update db");
		}
	}];
}


- (void)updateByUID:(DDUser *)user {
	[self.dbQueue inDatabase: ^(FMDatabase *db) {
	    BOOL res = [db executeUpdate:@"UPDATE DDUser SET nickName=?, \
                    isPic=?, \
                    picPath=?, \
                    gender=?, \
                    university=?, \
                    grade=?, \
                    photos=?, \
                    city=?, \
                    birthday=?, \
                    hobbies=?, \
                    sign=?, \
                    isDoublerID=?, \
                    password=? \
                    WHERE UID=?",
                    user.nickName,
                    user.isPic,
                    user.picPath,
                    user.gender,
                    user.university,
                    user.grade,
                    user.photos,
                    user.city,
                    user.birthday,
                    user.hobbies,
                    user.sign,
                    user.isDoublerID,
                    user.password,
                    user.UID];
	    if (res) {
	        NSLog(@"DDUser: success to update db");
		} else {
	        NSLog(@"DDUser: error when update db");
		}
	}];
}


- (id)fillModelWithFMResultSet:(FMResultSet *)rs {
    DDUser * dduser = [DDUser new];
    dduser.UID = [rs stringForColumn:@"UID"];
    dduser.nickName = [rs stringForColumn:@"nickName"];
    dduser.password = [rs stringForColumn:@"password"];
    dduser.isPic = [NSNumber numberWithInt:[rs intForColumn:@"isPic"]];
    dduser.picPath = [rs stringForColumn:@"picPath"];
    dduser.gender = [rs stringForColumn:@"gender"];
    dduser.university = [rs stringForColumn:@"university"];
    dduser.grade = [rs stringForColumn:@"grade"];
    dduser.isDoublerID = [NSNumber numberWithInt:[rs intForColumn:@"isDoublerID"]];
    dduser.photos = [rs stringForColumn:@"photos"];
    dduser.birthday = [rs stringForColumn:@"birthday"];
    dduser.hobbies = [rs stringForColumn:@"hobbies"];
    dduser.city = [rs stringForColumn:@"city"];
    dduser.sign = [rs stringForColumn:@"sign"];
    return dduser;
}
@end
