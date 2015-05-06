#import "BaseDAO.h"

@interface LocalDbService: NSObject

@property(strong, nonatomic) FMDatabase *db;

//获得单例
+ (LocalDbService *)defaultService;
- (void) createTableUsingDao:(BaseDAO *)dao;

@end