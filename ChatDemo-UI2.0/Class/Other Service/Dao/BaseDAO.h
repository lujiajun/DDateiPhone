//
//  BaseDAO.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface BaseDAO : NSObject

@property (strong, nonatomic) FMDatabase *db;

- (NSString *)tableCreateSql;

- (id)fillModelWithFMResultSet:(FMResultSet *)rs;
@end
