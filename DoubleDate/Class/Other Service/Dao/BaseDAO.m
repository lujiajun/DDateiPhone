//
//  BaseDAO.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "BaseDAO.h"
#import "LocalDbService.h"

@interface BaseDAO()
@property (strong, nonatomic) LocalDbService *dbService;

@end

@implementation BaseDAO

- (instancetype)init {
	if (self = [super init]) {
        _dbService = [LocalDbService defaultService];
        [_dbService createTableUsingDao:self];
        _dbQueue = _dbService.dbQueue;
	}
	return self;
}

- (NSString *)tableCreateSql {
    return nil;
}

- (id)fillModelWithFMResultSet:(FMResultSet *)rs {
	return nil;
}

@end
