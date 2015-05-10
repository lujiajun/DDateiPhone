#import "BaseDAO.h"
#import "FMDatabaseQueue.h"

@interface LocalDbService : NSObject

@property (strong, nonatomic) FMDatabaseQueue *dbQueue;

//获得单例
+ (LocalDbService *)defaultService;
- (void)createTableUsingDao:(BaseDAO *)dao;

@end
