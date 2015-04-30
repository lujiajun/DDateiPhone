    #import "LocalDbService.h"
#import <sqlite3.h>
#import "DDBDynamoDB.h"
@interface LocalDbService()
@property(strong,nonatomic) DDBDynamoDB *ddbDynamoDB;
@property(strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property (nonatomic) sqlite3 *_database;
@end

static BOOL *isOpen;
static NSMutableArray *chatroom2;


@implementation LocalDbService
@synthesize _database;

+(NSMutableArray *) getChatRoom{
    return chatroom2;
}

+(BOOL) isOpen{
    return isOpen;
}

//获取document目录并返回数据库目录
- (NSString *)dataFilePath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"=======%@",documentsDirectory);
    return [documentsDirectory stringByAppendingPathComponent:@"DoubleDate.db"];//这里很神奇，可以定义成任何类型的文件，也可以不定义成.db文件，任何格式都行，定义成.sb文件都行，达到了很好的数据隐秘性
    
}

//创建，打开数据库
- (BOOL)openDB {
    
    //获取数据库路径
    NSString *path = [self dataFilePath];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断数据库是否存在
    BOOL find = [fileManager fileExistsAtPath:path];
    
    //如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
    if (find) {
        NSLog(@"Database file have already existed.");
        
        //打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
        //Objective-C)编写的，它不知道什么是NSString.
        if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
            
            //如果打开数据库失败则关闭数据库
            sqlite3_close(self._database);
            NSLog(@"Error: open database file.");
            return NO;
        }
        isOpen=YES;
        return YES;
    }else{
        //如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
        if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
            
            //创建一个新表
            NSString *ddusersql = @"create table if not exists DDUser(ID INTEGER PRIMARY KEY AUTOINCREMENT, UID varchar(50), nickName varchar(50),isPic INTEGER,picPath INTEGER,gender varchar(10),university varchar(10),grade varchar(10),isDoublerID INTEGER);";
            
            char *errmsg=NULL;
            sqlite3_exec(self._database, ddusersql.UTF8String, NULL, NULL, &errmsg);
            if (errmsg) {//如果有错误信息
                NSLog(@"数据表dduer操作失败--%s",errmsg);
            }else{
                NSLog(@"数据表dduer操作成功");
            }
            
            NSString *chatroom2sql = @"create table if not exists CHATROOM2(ID INTEGER PRIMARY KEY AUTOINCREMENT,RID varchar(50), ClickNum varchar(10),Gender varchar(10),GradeFrom varchar(10),Motto varchar(50),PicturePath varchar(50),SchoolRestrict varchar(50),UID1 varchar(50),UID2 varchar(50));";
            char *err=NULL;
            sqlite3_exec(self._database, chatroom2sql.UTF8String, NULL, NULL, &err);
            if (err) {//如果有错误信息
                NSLog(@"数据表dduer操作失败--%s",err);
            }else{
                NSLog(@"数据表dduer操作成功");
            }
            
            //第一次创建则开始初始化本地库
            isOpen=YES;
            return YES;
        } else {
            //如果创建并打开数据库失败则关闭数据库
            sqlite3_close(self._database);
            NSLog(@"Error: open database file.");
            return NO;
        }
    }
    
    
    return NO;
}


- (void)refreshList {
    //先查询，没有在网络数据库
    chatroom2= [self getTenLocalTenChatRoom2];
    if(chatroom2==nil ||[chatroom2 count]==0){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        _dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        scanExpression.limit = @10;
        BFTask *bftask= [_dynamoDBObjectMapper scan:[CHATROOM2 class] expression:scanExpression];
        bftask.waitUntilFinished;
        AWSDynamoDBPaginatedOutput *paginatedOutput = bftask.result;
        chatroom2=paginatedOutput.items;
        for (CHATROOM2 *item in paginatedOutput.items) {
            if(item.RID!=nil&&item.UID1!=nil&item.UID2!=nil){
                NSString *ClickNum=@" ";
                if(item.ClickNum!=nil){
                    ClickNum=item.ClickNum;
                }
                NSString *gender=@" ";
                if(item.Gender!=nil){
                    gender=item.Gender;
                }
                NSString *gradeform=@" ";
                if(item.GradeFrom!=nil){
                    gradeform=item.GradeFrom;
                }
                NSString * motto=@" ";
                if(item.Motto!=nil){
                    motto=item.Motto;
                }
                NSString * picpath=@" ";
                if(item.PicturePath!=nil){
                    picpath=item.PicturePath;
                }
                NSString * school=@" ";
                if(item.SchoolRestrict!=nil){
                    school=item.SchoolRestrict;
                }
                
                
                NSString *sql=[[[@"INSERT INTO " stringByAppendingString:@"CHATROOM2 "] stringByAppendingString:  @"( RID,ClickNum,Gender,GradeFrom,Motto,PicturePath,SchoolRestrict,UID1,UID2)"]stringByAppendingString:[NSString stringWithFormat:@"VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@');",item.RID,item.ClickNum,item.Gender,item.GradeFrom,item.Motto,item.PicturePath,item.SchoolRestrict,item.UID1,item.UID2]];
                //插入本地数据 item
                if([self getChatRoom2ByRid:item.RID]==nil){
                    [self doTable:sql];
                }
                
                //异步插入DDUser
                if([self selectDDuserByUid:item.UID1]==nil){
                    [self getTableRowAndInsertLocal:item.UID1];
                }
                if([self selectDDuserByUid:item.UID2]==nil){
                    [self getTableRowAndInsertLocal:item.UID2];
                }
                
            }
            
        }
    }

}

-(CHATROOM2 *) getChatRoom2ByRid:(NSString *) rid{
    CHATROOM2 *chatroom2=[CHATROOM2 new];
    NSString *quary = [[[@"SELECT * FROM CHATROOM2" stringByAppendingString:@" WHERE RID='"] stringByAppendingString:rid] stringByAppendingString:@"'"];//SELECT ROW,FIELD_DATA FROM FIELDS ORDER BY ROW
    sqlite3_stmt *stmt;
  
    //    printf(sql.UTF8String);
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(self._database, [quary UTF8String], -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
            int i=1;
                chatroom2.RID=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.ClickNum=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.Gender= [NSNumber numberWithInt:sqlite3_column_int(stmt, i++)];
                chatroom2.GradeFrom=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.Motto=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.PicturePath=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.SchoolRestrict= [[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.UID1=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
                chatroom2.UID2=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];        return chatroom2;
        }
    }else {
        NSLog(@"查询语句有问题");
    }
    return chatroom2;
}

-(NSMutableArray *)getTenLocalTenChatRoom2{
    NSMutableArray *result=[NSMutableArray arrayWithCapacity:10];
    NSString *sql=@"select * from CHATROOM2 order by ID limit 10";
    sqlite3_stmt *stmt;
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(self._database, [sql UTF8String], -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
             int i = 0;
            CHATROOM2 *chatroom2=[CHATROOM2 new];
             [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, i++)];
            chatroom2.RID=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.ClickNum=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.Gender= [NSNumber numberWithInt:sqlite3_column_int(stmt, i++)];
            chatroom2.GradeFrom=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.Motto=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.PicturePath=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.SchoolRestrict= [[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.UID1=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            chatroom2.UID2=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            [result addObject:chatroom2];
         
        }
    }else {
        NSLog(@"查询语句有问题");
    }
    
    return result;
}

- (void)getTableRowAndInsertLocal:(NSString *) uid{
    [[_dynamoDBObjectMapper load:[DDUser class]
                         hashKey:uid
                        rangeKey:nil] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            DDUser *dduser = task.result;
            NSString *sql=[[[@"INSERT INTO " stringByAppendingString:@"DDUser "] stringByAppendingString:  @"( UID,nickName,isPic,picPath,gender,university,grade,isDoublerID)"]stringByAppendingString:[NSString stringWithFormat:@"VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');",dduser.UID,dduser.nickName,dduser.isPic,dduser.picPath,dduser.gender,dduser.university,dduser.grade,dduser.isDoublerID]];
            
            [self doTable:sql];
            
        } else {
            NSLog(@"Error: [%@]", task.error);
            
        }
        return nil;
    }];
}
-(void) getRoomsFromLocal{
    
}


//数据库操作
-(void) doTable:(NSString *) sql{
    
    //先判断数据库是否打开
    if (isOpen) {
        //1.拼接SQL语句
        //2.执行SQL语句
        char *errmsg=NULL;
        sqlite3_exec(self._database, sql.UTF8String, NULL, NULL, &errmsg);
        if (errmsg) {//如果有错误信息
            NSLog(@"数据操作失败--%s",errmsg);
        }else{
            NSLog(@"数据操作成功");
        }
        
    }
}
//quary	__NSCFString *	@"SELECT * FROM DDUser WHERE UID='luck'"	0x00007f983168e740

- (DDUser *)selectDDuserByUid:(NSString *) uid {
    NSString *quary = [[[@"SELECT * FROM DDUser" stringByAppendingString:@" WHERE UID='"] stringByAppendingString:uid] stringByAppendingString:@"'"];//SELECT ROW,FIELD_DATA FROM FIELDS ORDER BY ROW
    sqlite3_stmt *stmt;
    DDUser *dduser=[DDUser new];
    //    printf(sql.UTF8String);
    //进行查询前的准备工作
    if (sqlite3_prepare_v2(self._database, [quary UTF8String], -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
        
        //每调用一次sqlite3_step函数，stmt就会指向下一条记录
        while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
            int i=1;
            dduser.UID=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            dduser.nickName=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            dduser.isPic= [NSNumber numberWithInt:sqlite3_column_int(stmt, i++)];
            dduser.picPath=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            dduser.gender=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            dduser.university= [[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            dduser.grade=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, i++) encoding:NSUTF8StringEncoding];
            dduser.isDoublerID=[NSNumber numberWithInt:sqlite3_column_int(stmt, i++)];
            return dduser;
        }
    }else {
        NSLog(@"查询语句有问题");
    }
    return nil;
}



@end