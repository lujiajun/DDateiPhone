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
#import "ChatRoom2DAO.h"
#import "DDUserDAO.h"
#import "SRRefreshView.h"
#import "HomePageListCell.h"
#import "UIImageView+WebCache.h"


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
    
    if(_userDao==nil){
        _userDao=[[DDUserDAO alloc]init];
    }
    //chaxun
    [self.chatroom2Dao refreshList];
    [self initdduser];
}

- (void)initdduser {
	if (uuser == nil) {
		NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
		NSString *username = [loginInfo objectForKey:kSDKUsername];
        if(_userDao==nil){
            _userDao=[[DDUserDAO alloc]init];
        }
        uuser=[_userDao selectDDuserByUid:username];
        if(uuser==nil){
            
            _dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            [[_dynamoDBObjectMapper load:[DDUser class] hashKey:username rangeKey:nil]
             continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
                 uuser = task.result;
                 return nil;
             }];
        }
		
	}
}
-(void) initFriendUser{
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"HomePageListCell";
	HomePageListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[HomePageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	CHATROOM2 *chatRoom2 = [self.chatroom2Dao.chatroom2s objectAtIndex:indexPath.row];

	if (chatRoom2 != nil && chatRoom2.PicturePath != nil) {
		[cell.bakview sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:chatRoom2.PicturePath]]
		                placeholderImage:[UIImage imageNamed:@"Logo_new"]];
	}

	//查询用户1
	DDUser *uuser1 = [self.userDao selectDDuserByUid:chatRoom2.UID1];
	if (uuser1 != nil && uuser1.picPath != nil) {
		[cell.user1Avatar sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:uuser1.picPath]]
		                    placeholderImage:[UIImage imageNamed:@"Logo_new"]];
	}

	//查询用户2
	DDUser *uuser2 = [self.userDao selectDDuserByUid:chatRoom2.UID2];
	if (uuser2 != nil && uuser2.picPath != nil) {
		[cell.user2Avatar sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:uuser2.picPath]]
		                    placeholderImage:[UIImage imageNamed:@"Logo_new"]];
	}

	//性别
	BOOL isboy = [uuser1.gender isEqualToString:@"Male"] || [uuser1.gender isEqualToString:@"男"];
	UIImage *genderImage = isboy ? [UIImage imageNamed:@"sexboy"] : [UIImage imageNamed:@"sexgirl"];
    cell.genderView.image = genderImage;

	//点击数
	cell.clicknumber.text = chatRoom2.ClickNum;

	//宣言
	cell.motto.text = chatRoom2.Motto;

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