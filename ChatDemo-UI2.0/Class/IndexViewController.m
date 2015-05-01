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
#import "ChatRoom2DAO.h"
#import "DDUserDAO.h"
#import "SRRefreshView.h"


@interface IndexViewController ()<SRRefreshDelegate>

@property (strong, nonatomic) SRRefreshView *slimeView;

@property(strong,nonatomic) DDBDynamoDB *ddbDynamoDB;
@property(strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;

@property(strong, nonatomic) ChatRoom2DAO *chatroom2Dao;
@property(strong, nonatomic) DDUserDAO *userDao;

@end

static DDUser *uuser;

@implementation IndexViewController

#define kIMGCOUNT 5

+ (DDUser *)instanceDDuser {
	return uuser;
}

- (void)setDDUser:(DDUser *)user {
	uuser = user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"个人主页";
    self.view.backgroundColor = [UIColor redColor];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView addSubview:self.slimeView];
    
    //chaxun
    [self.chatroom2Dao refreshList];
    [self initdduser];
}

- (void)initdduser {
	if (uuser == nil) {
		NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
		NSString *username = [loginInfo objectForKey:kSDKUsername];

		//同步方法
		_dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
		[[_dynamoDBObjectMapper load:[DDUser class] hashKey:username rangeKey:nil]
		 continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
		    uuser = task.result;
		    return nil;
		}];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatroom2Dao.chatroom2s.count;
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
        for (NSUInteger i = 0; i < self.chatroom2Dao.chatroom2s.count; i++) {
            if (indexPath.row == i) {
                CHATROOM2 *root=[[self.chatroom2Dao.chatroom2s objectAtIndex:i] copy];
            
                
                EGOImageView *bakview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(root!=nil && root.PicturePath !=nil){
                    bakview.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:root.PicturePath]];
                }
                bakview.frame = CGRectMake(5, 5, cell.frame.size.width-10, 150);
                bakview.layer.masksToBounds =YES;
                bakview.layer.cornerRadius =5;
                [cell.contentView addSubview:bakview];

                //渐变
                UIImage *background=[UIImage imageNamed:@"jianbian"];
                UIImageView *bakgroundview=[[UIImageView alloc] initWithImage:background];
                bakgroundview.frame=CGRectMake(5, 5, cell.frame.size.width-10, 150);
                bakgroundview.layer.masksToBounds =YES;
                bakgroundview.layer.cornerRadius =5;
                [cell.contentView addSubview:bakgroundview];
                //查询用户
                
                DDUser *uuser1= [self.userDao selectDDuserByUid:root.UID1];
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
          
                DDUser *uuser2= [self.userDao selectDDuserByUid:root.UID2];;
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
				BOOL isboy = NO;
				if (user1 != nil) {
					if ([uuser1.gender isEqualToString:@"Male"] || [uuser1.gender isEqualToString:@"男"]) {
						isboy = YES;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 160;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (indexPath.section == 0) {
		for (NSUInteger i = 0; i < self.chatroom2Dao.chatroom2s.count; i++) {
			if (indexPath.row == i) {
				CHATROOM2 *room = [[self.chatroom2Dao.chatroom2s objectAtIndex:i] copy];
				ChatRoomDetail *chatroom = [[ChatRoomDetail alloc]initChatRoom:room uuser1:[self.userDao selectDDuserByUid:room.UID1] uuser2:[self.userDao selectDDuserByUid:room.UID2]];
				[self.navigationController pushViewController:chatroom animated:YES];
			}
		}
	}
}


#pragma mark - SRRefreshDelegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
	__weak IndexViewController *weakSelf = self;
    [self.chatroom2Dao refreshList];
	[weakSelf.slimeView endRefresh];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_slimeView scrollViewDidEndDraging];
}

#pragma mark - getter

- (SRRefreshView *)slimeView {
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (ChatRoom2DAO *)chatroom2Dao {
	if (_chatroom2Dao == nil) {
		_chatroom2Dao = [[ChatRoom2DAO alloc] init];
	}
	return _chatroom2Dao;
}

- (DDUserDAO *)userDao {
    if (_userDao == nil) {
        _userDao = [[DDUserDAO alloc] init];
    }
    return _userDao;
}
@end
