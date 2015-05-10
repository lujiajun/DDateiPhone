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
#import "Constants.h"
#import "DDRegisterFinishController.h"
#import "DDPersonalUpdateController.h"
#import "IndexViewController.h"
#import "ChatRoomDetail.h"
#import "ChatRoom2DAO.h"
#import "DDUserDAO.h"
#import "SRRefreshView.h"
#import "AddFriendViewController.h"
#import "HomePageListCell.h"
#import "UIImageView+WebCache.h"
#import "AWSDynamoDB_ChatRoom2.h"
#import "InviteFriendByDoubleIdController.h"


@interface IndexViewController () <SRRefreshDelegate>

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;

@property (strong, nonatomic) AWSDynamoDB_ChatRoom2 *chatRoom2DynamoDB;

@property (strong, nonatomic) DDUserDAO *userDao;
@property (nonatomic) BOOL haveFriend;
@property(strong,nonatomic) UIView *bak;
@property(strong,nonatomic) UIButton *img1;
@property(strong,nonatomic) UIButton *img2;

@end

static DDUser *uuser;

@implementation IndexViewController

#define kIMGCOUNT 5

+ (DDUser *)instanceDDuser {
	return uuser;
}

+ (void)setDDUser:(DDUser *)user {
	uuser = user;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeAll;
	self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView addSubview:self.slimeView];
  
                
    if(_userDao==nil){
        _userDao=[[DDUserDAO alloc]init];
    }
    //chaxun
    [self.chatRoom2DynamoDB refreshListWithBlock:^{
        [self.tableView reloadData];
    }];
    [self initdduser];
    //判断用户是否有Double好友
    [self haveDoubleFriend];
    if(!_haveFriend){
        UIImageView *invite=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        [self.view addSubview:invite];
        
    }
    
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
-(void) haveDoubleFriend{
     NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    if(buddyList!=nil&&buddyList.count>0){
        _haveFriend=YES;
    }
    _haveFriend=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(!_haveFriend){
//        return self.chatroom2Dao.chatroom2s.count+1;
//    }
//    
    return self.chatRoom2DynamoDB.chatRoom2s.count;
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
    
	CHATROOM2 *chatRoom2 = [self.chatRoom2DynamoDB.chatRoom2s objectAtIndex:indexPath.row];

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
		for (NSUInteger i = 0; i < self.chatRoom2DynamoDB.chatRoom2s.count; i++) {
			if (indexPath.row == i) {
				CHATROOM2 *room = [[self.chatRoom2DynamoDB.chatRoom2s objectAtIndex:i] copy];
				ChatRoomDetail *chatroom = [[ChatRoomDetail alloc]initChatRoom:room uuser1:[self.userDao selectDDuserByUid:room.UID1] uuser2:[self.userDao selectDDuserByUid:room.UID2]];
				[self.navigationController pushViewController:chatroom animated:YES];
			}
		}
	}
}


#pragma mark - SRRefreshDelegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
	__weak IndexViewController *weakSelf = self;
	[self.chatRoom2DynamoDB refreshListWithBlock: ^{
	    [self.tableView reloadData];
	    [weakSelf.slimeView endRefresh];
	}];
}
//首页刷新
-(void)refreshAll{
    [self.chatRoom2DynamoDB refreshListWithBlock: ^{
        [self.tableView reloadData];
            }];
}
//邀请按钮
- (void)addFriendAction
{
    //    InviteFriendByDoubleIdController *addController = [InviteFriendByDoubleIdController alloc];
    if (_bak!=nil&&_img1!=nil&&_img2!=nil) {
        [_bak removeFromSuperview];
        _bak=nil;
        _img1=nil;
        _img2=nil;
        return;
    }
    //        [self.navigationController pushViewController:addController animated:YES];
    if(_bak==nil){
         _bak=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-120, 0,120,60)];
    }
    
    _bak.backgroundColor=[UIColor whiteColor];
    if(_img1==nil){
        _img1=[[UIButton alloc] initWithFrame:CGRectMake(0, 0,120, 30)];
        [_img1 setBackgroundColor:RGBACOLOR(228, 90, 80, 1)];
        [_img1 addTarget:self action:@selector(doInviteFriend) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *img1Click=[[UIImageView alloc] initWithFrame:CGRectMake(5,5, 20, 20)];
        img1Click.image=[UIImage imageNamed:@"inviteFriend"];
        [_img1 addSubview: img1Click];
        UILabel *lab1=[[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, 30)];
        lab1.text=@"邀请朋友";
        [_img1 addSubview:lab1];
        

    }
    [_bak addSubview:_img1];
    if(_img2==nil){
         _img2=[[UIButton alloc] initWithFrame:CGRectMake(0, 31, 120,30)];
        [_img2 addTarget:self action:@selector(doAddFriend) forControlEvents:UIControlEventTouchUpInside];
        [_img2 setBackgroundColor:RGBACOLOR(228, 90, 80, 1)];
        UIImageView *img1Click=[[UIImageView alloc] initWithFrame:CGRectMake(5,5, 20,20)];
        img1Click.image=[UIImage imageNamed:@"addFriend"];
        [_img2 addSubview: img1Click];
        UILabel *lab1=[[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, 30)];
        lab1.text=@"添加朋友";
        [_img2 addSubview:lab1];

    }
   
//    [_img2 setImage:[UIImage imageNamed:@"80"] forState:UIControlStateNormal];
    [_bak addSubview:_img2];
//
    [self.view addSubview:_bak];

}

-(void) doAddFriend{
        AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:addController animated:YES];
}
-(void) doInviteFriend{
    InviteFriendByDoubleIdController *addController = [InviteFriendByDoubleIdController alloc];
    [self.navigationController pushViewController:addController animated:YES];
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

- (AWSDynamoDB_ChatRoom2 *)chatRoom2DynamoDB {
	if (_chatRoom2DynamoDB == nil) {
		_chatRoom2DynamoDB = [[AWSDynamoDB_ChatRoom2 alloc] init];
	}
	return _chatRoom2DynamoDB;
}

- (DDUserDAO *)userDao {
    if (_userDao == nil) {
        _userDao = [[DDUserDAO alloc] init];
    }
    return _userDao;
}
@end
