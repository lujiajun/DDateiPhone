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
            isPic INTEGER, \
            picPath TEXT, \
            gender varchar(10), \
            university varchar(10), \
            grade varchar(10), \
            isDoublerID INTEGER);", DDUserTable];
}

- (DDUser *)selectDDuserByUid:(NSString *)uid {
    DDUser *dduser = nil;
    if ([self.db open]) {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE UID='%@'", DDUserTable, uid];
        dduser = [DDUser new];
        FMResultSet *rs = [self.db executeQuery:query];
        while ([rs next]) {
            dduser.UID = [rs stringForColumn:@"UID"];
            dduser.nickName = [rs stringForColumn:@"nickName"];
            dduser.isPic = [NSNumber numberWithInt:[rs intForColumn:@"isPic"]];
            dduser.picPath = [rs stringForColumn:@"picPath"];
            dduser.gender = [rs stringForColumn:@"gender"];
            dduser.university = [rs stringForColumn:@"university"];
            dduser.grade = [rs stringForColumn:@"grade"];
            dduser.isDoublerID = [NSNumber numberWithInt:[rs intForColumn:@"isDoublerID"]];
        }
        [rs close];
        [self.db close];
    }
    return dduser;
}



- (void)getTableRowAndInsertLocal:(NSString *)uid {
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	[[dynamoDBObjectMapper load:[DDUser class]
	                    hashKey:uid
	                   rangeKey:nil] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
	    if (!task.error) {
	        DDUser *dduser = task.result;
	        [self insertDDUser:dduser];
		} else {
	        NSLog(@"Error: [%@]", task.error);
		}
	    return nil;
	}];
}

- (void)insertDDUser:(DDUser *)dduser {
	NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@, %@)", DDUserTable,
	                 dduser.UID,
	                 dduser.nickName,
	                 dduser.isPic,
	                 dduser.gender,
	                 dduser.university,
	                 dduser.grade,
	                 dduser.isDoublerID];
	if ([self.db open]) {
		BOOL res = [self.db executeUpdate:sql];
		if (res) {
			NSLog(@"DDUser: success to insert db");
		} else {
			NSLog(@"DDUser: error when insert db");
		}
		[self.db close];
	}
}
@end
