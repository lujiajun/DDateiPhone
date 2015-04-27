/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "NewSettingViewController.h"
#import "SettingsViewController.h"

#import "ApplyViewController.h"
#import "PushNotificationViewController.h"
#import "BlackListViewController.h"
#import "DebugViewController.h"
#import "WCAlertView.h"
#import "AliCloudController.h"
#import "DDBDynamoDB.h"
#import "Constants.h"
#import "DDRegisterFinishController.h"
#import "DDPersonalUpdateController.h"
#import "IndexViewController.h"
#import "DDBDynamoDB.h"
#import "ChatRoomDetail.h"
#import "EGOImageView.h"
#import <sqlite3.h>


@interface IndexViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;
@property(strong,nonatomic) NSMutableArray *datasouce;
@property(strong,nonatomic) DDBDynamoDB *ddbDynamoDB;
@property(strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property(nonatomic) sqlite3 *db;
@property(strong,nonatomic) NSString *database_path;
@property(strong,nonatomic) NSArray *path;
@property (nonatomic) sqlite3 *_database;

@end
static DDUser   *uuser;


@implementation IndexViewController
@synthesize _database;

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;

#define kIMGCOUNT 5
+(DDUser *) instanceDDuser{
    return uuser;
}
-(void) setDDUser:(DDUser *) user{
    uuser=user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"个人主页";
    self.view.backgroundColor = [UIColor redColor];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
    //chaxun
    self.refreshList;
    [self initdduser];
    
    
    
}

-(void)initdduser{
    if(uuser==nil){
        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        
        //同步方法
        _dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        BFTask *bftask= [_dynamoDBObjectMapper load:[DDUser class] hashKey:username rangeKey:nil];
        bftask.waitUntilFinished;
        uuser= bftask.result;
        [self openDB];
        
    }
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
        //创建一个新表
        [self createTestList:self._database];
        
        return YES;
    }
    //如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
    if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
        
        //创建一个新表
         char *ddusersql = "create table if not exists DDUser(UID text, nickName text,isPic int,picPath text,gender text,university text,grade text)";
        [self createTestList:ddusersql];
        char *chatroom2sql = "create table if not exists CHATROOM2(RID text, ClickNum text,Gender text,GradeFrom text,Motto text,PicturePath text,SchoolRestrict text,UID1 text,UID2 text)";
        [self createTestList:chatroom2sql];
        
        return YES;
    } else {
        //如果创建并打开数据库失败则关闭数据库
        sqlite3_close(self._database);
        NSLog(@"Error: open database file.");
        return NO;
    }
    return NO;
}

//创建表
- (BOOL) createTestList:(char *)sql {
    
    //这句是大家熟悉的SQL语句
//    char *sql = "create table if not exists DDUser(UID text, nickName text,isPic int,picPath text,gender text,university text,grade text)";// testID是列名，int 是数据类型，testValue是列名，text是数据类型，是字符串类型
    
    sqlite3_stmt *statement;
    //sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
    NSInteger sqlReturn = sqlite3_prepare_v2(_db, sql, -1, &statement, nil);
    //第一个参数跟前面一样，是个sqlite3 * 类型变量，
    //第二个参数是一个 sql 语句。
    //第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
    //第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
    //第五个参数是错误信息提示，一般不用,为nil就可以了。
    //如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为NULL ），那么下面就可以开始插入二进制数据。
    
    //如果SQL语句解析出错的话程序返回
    if(sqlReturn != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create test table");
        return NO;
    }
    
    //执行SQL语句
    int success = sqlite3_step(statement);
    //释放sqlite3_stmt
    sqlite3_finalize(statement);
    
    //执行SQL语句失败
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:create table test");
        return NO;
    }
    NSLog(@"Create table 'testTable' successed.");
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (UISwitch *)beInvitedSwitch
{
    //    if (_beInvitedSwitch == nil) {
    //        _beInvitedSwitch = [[UISwitch alloc] init];
    //        [_beInvitedSwitch addTarget:self action:@selector(beInvitedChanged:) forControlEvents:UIControlEventValueChanged];
    //        BOOL autoAccept = [[EaseMob sharedInstance].chatManager autoAcceptGroupInvitation];
    //        [_beInvitedSwitch setOn:!autoAccept animated:YES];
    //    }
    
    return _beInvitedSwitch;
}

- (UILabel *)beInvitedLabel
{
    if (_beInvitedLabel == nil) {
        _beInvitedLabel = [[UILabel alloc] init];
        _beInvitedLabel.backgroundColor = [UIColor clearColor];
        _beInvitedLabel.font = [UIFont systemFontOfSize:12.0];
        _beInvitedLabel.textColor = [UIColor grayColor];
    }
    
    return _beInvitedLabel;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasouce.count;
}

//每行缩进
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        return 10;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        for (NSUInteger i = 0; i < _datasouce.count; i++) {
            if (indexPath.row == i) {
                CHATROOM2 *root=[[_datasouce objectAtIndex:i] copy];
            
                
                EGOImageView *bakview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(root!=nil && root.PicturePath !=nil){
                    bakview.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:root.PicturePath]];
                }
                bakview.frame = CGRectMake(5, 5, cell.frame.size.width-10, 150);
                bakview.layer.masksToBounds =YES;
                bakview.layer.cornerRadius =25;
                [cell.contentView addSubview:bakview];

                //渐变
                UIImage *background=[UIImage imageNamed:@"jianbian"];
                UIImageView *bakgroundview=[[UIImageView alloc] initWithImage:background];
                bakgroundview.frame=CGRectMake(5, 5, cell.frame.size.width-10, 150);
                bakgroundview.layer.masksToBounds =YES;
                bakgroundview.layer.cornerRadius =25;
                [cell.contentView addSubview:bakgroundview];
                //查询用户
                
                DDUser *uuser1= [self selectDDuserByUid:root.UID1];
                //显示用户1
                EGOImageView *user1 = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(uuser1!=nil && uuser1.picPath !=nil){
                    user1.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:uuser1.picPath]];
                }
                user1.frame=CGRectMake(10, bakview.frame.origin.y+5, 50, 50);
                user1.layer.masksToBounds =YES;
                user1.layer.cornerRadius =25;
                [bakview addSubview:user1];
                //显示用户2
          
                DDUser *uuser2= [self selectDDuserByUid:root.UID2];;
                //显示用户1
               
                EGOImageView *user2 = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(uuser2!=nil && uuser2.picPath !=nil){
                    user2.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:uuser2.picPath]];
                }
                user2.frame=CGRectMake(bakview.frame.size.width-60, bakview.frame.origin.y+5, 50, 50);
                user2.layer.masksToBounds =YES;
                user2.layer.cornerRadius =25;
                [bakview addSubview:user2];
                
                //性别
                BOOL *isboy=NO;
                if(user1!=nil){
                    if(uuser1.gender==@"Male" || uuser1.gender==@"男"){
                        isboy=YES;
                    }
                }
                UIImage *isboyimg;
                if(isboy){
                    isboyimg=[UIImage imageNamed:@"sexboy"];
                }else{
                    isboyimg=[UIImage imageNamed:@"sexgirl"];
                }
                UIImageView *isboyview=[[UIImageView alloc] initWithImage:isboyimg];
                isboyview.frame=CGRectMake(bakview.frame.size.width-40, bakview.frame.origin.y+80, 20, 20);
                [bakview addSubview:isboyview];
                //点击数
                UIImage *clicknumber2=[UIImage imageNamed:@"clicknum2"];
                
                UIImageView *clicknumber2view=[[UIImageView alloc] initWithImage:clicknumber2];
                clicknumber2view.frame=CGRectMake(bakview.frame.size.width-60, bakview.frame.origin.y+110, 56, 25);
                [bakview addSubview:clicknumber2view];
                
                UIImage *clicknumber1=[UIImage imageNamed:@"clicknum1"];
                UIImageView *clicknumber1view=[[UIImageView alloc] initWithImage:clicknumber1];
                clicknumber1view.frame=CGRectMake(5, 5, 12, 12);
                [clicknumber2view addSubview:clicknumber1view];
                
                UILabel *click=[[UILabel alloc]initWithFrame:CGRectMake(19, 2, 30, 20)];
                click.text=root.ClickNum;
                click.textAlignment=NSTextAlignmentCenter;
                click.font=[UIFont fontWithName:@"Helvetica" size:11];
                click.textColor=[UIColor whiteColor];
                [clicknumber2view addSubview:click];
                
                //添加宣言
                UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(0, bakview.frame.origin.y+110, 100, 30)];
                mylable.text=root.Motto;
                mylable.textAlignment=NSTextAlignmentCenter;
                mylable.font=[UIFont fontWithName:@"Helvetica" size:14];
                mylable.textColor=[UIColor whiteColor];
                [bakview addSubview:mylable];
                
            }
        }
        
        
    }
    
    return cell;
}


- (void)refreshList {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    _dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @10;
    BFTask *bftask= [_dynamoDBObjectMapper scan:[CHATROOM2 class] expression:scanExpression];
    bftask.waitUntilFinished;
    AWSDynamoDBPaginatedOutput *paginatedOutput = bftask.result;
    _datasouce=paginatedOutput.items;
    for (CHATROOM2 *item in paginatedOutput.items) {
        
        NSString *sql=[[[@"INSERT INTO" stringByAppendingString:@"DDUser "] stringByAppendingString:  @"( RID,ClickNum,Gender,GradeFrom,Motto,PicturePath,SchoolRestrict,UID1,UID2)"]stringByAppendingString:[NSString stringWithFormat:@"VALUES ('%@',%d);",item.RID,item.ClickNum,item.Gender,item.GradeFrom,item.Motto,item.PicturePath,item.SchoolRestrict,item.UID1,item.UID2]];
        //插入本地数据 item
        [self insertTable:sql];
        //异步插入DDUser
        [self getTableRowAndInsertLocal:item.UID1];
        [self getTableRowAndInsertLocal:item.UID2];
        
    }
    
    
}

- (void)getTableRowAndInsertLocal:(NSString *) uid{
    [[_dynamoDBObjectMapper load:[DDUser class]
                        hashKey:uid
                       rangeKey:nil] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            DDUser *dduser = task.result;
            NSString *sql=[[[@"INSERT INTO" stringByAppendingString:@"DDUser "] stringByAppendingString:  @"( UID,nickName,isPic,picPath,gender,university,grade,isDoublerID)"]stringByAppendingString:[NSString stringWithFormat:@"VALUES ('%@',%d);",dduser.UID,dduser.nickName,dduser.isPic,dduser.picPath,dduser.gender,dduser.university,dduser.grade,dduser.isDoublerID]];
            [self insertTable:sql];
            
        } else {
            NSLog(@"Error: [%@]", task.error);
            
        }
        return nil;
    }];
}


//插入数据
-(void) insertTable:(NSString *) sql{
    
    //先判断数据库是否打开
    if ([self openDB]) {
        //1.拼接SQL语句
       
        //2.执行SQL语句
            char *errmsg=NULL;
            sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, &errmsg);
            if (errmsg) {//如果有错误信息
                NSLog(@"插入数据失败--%s",errmsg);
            }else{
                NSLog(@"插入数据成功");
            }
        
    }
}

- (DDUser *)selectDDuserByUid:(NSString *) uid {
    NSString  *sql=[[@"SELECT UID,nickName,isPic,picPath,gender,university,grade,isDoublerID FROM DDUser WHERE UID=" stringByAppendingString:uid] stringByAppendingString:@";"];
         sqlite3_stmt *stmt=NULL;
    DDUser *dduser=nil;
    printf(sql.UTF8String);
         //进行查询前的准备工作
//         if (sqlite3_prepare_v2(self.db, sql.UTF8String, -1, &stmt, NULL)==SQLITE_OK) {//SQL语句没有问题
//                NSLog(@"查询语句没有问题");
    
                 //每调用一次sqlite3_step函数，stmt就会指向下一条记录
                 while (sqlite3_step(stmt)==SQLITE_ROW) {//找到一条记录
                    
                        dduser.UID=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, 0) encoding:NSASCIIStringEncoding];
                        dduser.nickName=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, 1) encoding:NSASCIIStringEncoding];
                        dduser.isPic= [NSNumber numberWithInt:sqlite3_column_int(stmt, 2)];
                     dduser.picPath=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, 3) encoding:NSASCIIStringEncoding];
                     dduser.gender=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, 4) encoding:NSASCIIStringEncoding];
                     dduser.university= [[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, 5) encoding:NSASCIIStringEncoding];
                     dduser.grade=[[NSString alloc] initWithCString:(const char*)sqlite3_column_text(stmt, 6) encoding:NSASCIIStringEncoding];
                     dduser.isDoublerID=[NSNumber numberWithInt:sqlite3_column_int(stmt, 7)];
                     return dduser;
                }
//        }else {
//            NSLog(@"查询语句有问题");
//        }
    return nil;
}


- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 160;
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        for (NSUInteger i = 0; i < _datasouce.count; i++) {
            if (indexPath.row == i) {
                CHATROOM2 *room=[[_datasouce objectAtIndex:i] copy];
                ChatRoomDetail *chatroom=[[ChatRoomDetail alloc]initChatRoom:room.UID1 uuser2:room.UID2 motto:room.Motto];
                [self.navigationController pushViewController:chatroom animated:YES];
            }
        }
    }

}

#pragma mark - getter

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        }
    
    return _footerView;
}

#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch
{
    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:autoSwitch.isOn];
}

- (void)useIpChanged:(UISwitch *)ipSwitch
{
    [[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
}

- (void)beInvitedChanged:(UISwitch *)beInvitedSwitch
{
    //    if (beInvitedSwitch.isOn) {
    //        self.beInvitedLabel.text = @"允许选择";
    //    }
    //    else{
    //        self.beInvitedLabel.text = @"自动加入";
    //    }
    //
    //    [[EaseMob sharedInstance].chatManager setAutoAcceptGroupInvitation:!(beInvitedSwitch.isOn)];
}


- (void)refreshConfig
{
    [self.autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled] animated:YES];
    [self.ipSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];
    
    [self.tableView reloadData];
}

- (void)logoutAction
{
    __weak NewSettingViewController *weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [weakSelf hideHud];
        if (error && error.errorCode != EMErrorServerNotLogin) {
            [weakSelf showHint:error.description];
        }
        else{
            [[ApplyViewController shareController] clear];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    } onQueue:nil];
}

@end
