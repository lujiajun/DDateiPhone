#import "DDBDynamoDB.h"

@interface LocalDbService: NSObject
//创建，打开数据库
- (BOOL)openDB;
- (void)refreshList;
- (void)getTableRowAndInsertLocal:(NSString *) uid;
- (DDUser *)selectDDuserByUid:(NSString *) uid ;

+(NSMutableArray *) getChatRoom;
@end