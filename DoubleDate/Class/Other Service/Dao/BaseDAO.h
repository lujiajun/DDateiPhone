//
//  BaseDAO.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"


@interface BaseDAO : NSObject

@property (strong, nonatomic) FMDatabaseQueue *dbQueue;

- (NSString *)tableCreateSql;

- (id)fillModelWithFMResultSet:(FMResultSet *)rs;
@end
