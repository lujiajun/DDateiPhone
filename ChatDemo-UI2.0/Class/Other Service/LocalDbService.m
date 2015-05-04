#import "LocalDbService.h"
#import "DDBDynamoDB.h"
#import "FMDatabase.h"

NSString *const DATABASE_NAME = @"DoubleDate_%@.db";

@implementation LocalDbService


+ (LocalDbService *)defaultService {
	static LocalDbService *sInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sInstance = [[self alloc] init];
	});
	return sInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_db = [[FMDatabase alloc] initWithPath:[self dataFilePath]];
	}
	return self;
}


#pragma mark - Public 

- (void)createTableUsingDao:(BaseDAO *)dao {
    if ([self.db open]) {
        NSString *sql = [dao tableCreateSql];
        [self.db executeUpdate:sql];
        [self.db close];
    }
}


#pragma mark - Private

//获取document目录并返回数据库目录
- (NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSLog(@"Double date database path: %@", documentsDirectory);
	NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
	NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
	return [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:DATABASE_NAME, loginUsername]];//这里很神奇，可以定义成任何类型的文件，也可以不定义成.db文件，任何格式都行，定义成.sb文件都行，达到了很好的数据隐秘性
}


@end