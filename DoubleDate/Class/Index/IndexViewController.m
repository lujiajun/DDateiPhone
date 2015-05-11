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
#import "Util.h"
#import "InviteFriendByDoubleIdController.h"
#import "CreateGroupViewController.h"
#import "View+MASAdditions.h"

@interface IndexViewController () <SRRefreshDelegate>

@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;

@property (strong, nonatomic) AWSDynamoDB_ChatRoom2 *chatRoom2DynamoDB;

@property (strong, nonatomic) DDUserDAO *userDao;

@property (nonatomic) BOOL haveFriend;

@property (strong, nonatomic) UITextField *textField;

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
    
    
                
	if (_userDao == nil) {
		_userDao = [[DDUserDAO alloc]init];
	}
    //chaxun
    [self.chatRoom2DynamoDB refreshListWithBlock:^{
        
        
        self.tableView.tableHeaderView = [self haveDoubleFriend] ? nil : self.headerView;
        [self.tableView reloadData];
    }];
    
    //首页button
    [self initdduser];
//    NSLog([NSString stringWithFormat:@"%@",[NSNumber numberWithInt:[[NSDate date] timeIntervalSinceNow]]]);
   
    
}
//1431006443804
//1431316020743


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

- (BOOL)haveDoubleFriend {
    
	NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
	if (buddyList != nil && buddyList.count > 0) {
		return YES;
	}
	return NO;
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

    [cell.user1Avatar sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:uuser1.picPath]]
		                    placeholderImage:[UIImage imageNamed:@"Logo_new"]];

	//查询用户2
	DDUser *uuser2 = [self.userDao selectDDuserByUid:chatRoom2.UID2];
    
    [cell.user2Avatar sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:uuser2.picPath]]
		                    placeholderImage:[UIImage imageNamed:@"Logo_new"]];

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
//                 self.navigationController.navigationBarHidden=YES;
                
				[self.navigationController pushViewController:chatroom animated:YES];
			}
		}
	}
}


#pragma mark - SRRefreshDelegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
    [self haveDoubleFriend];
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


- (void)indexAddFriendAction {
	//判断状态，进行跳转
	if ([self haveDoubleFriend]) {
		CreateGroupViewController *createChatroom = [[CreateGroupViewController alloc] init];
		[self.navigationController pushViewController:createChatroom animated:YES];
	} else {
//        AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
//        [self.navigationController pushViewController:addController animated:YES];

		InviteFriendByDoubleIdController *addController = [InviteFriendByDoubleIdController alloc];
		[self.navigationController pushViewController:addController animated:YES];
	}
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_slimeView scrollViewDidEndDraging];
}

#pragma mark - getter

-(UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] init];
        _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
        
        //Label
        UILabel *label = [[UILabel alloc] init];
		label.frame = CGRectMake(20, 0, self.view.frame.size.width - 40, 60);
        label.text = NSLocalizedString(@"homepage.paperPlane.invite", @"homepage.paperPlane.invite");
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.textColor = [UIColor lightGrayColor];
        [_headerView addSubview:label];
        
        //UITextView
        self.textField = [[UITextField alloc] init];
        self.textField.placeholder=@"快快输入好友的double号";
        self.textField.font = [UIFont systemFontOfSize:12];
        
        UIButton *button = [[UIButton alloc] init];
        button.backgroundColor = RGBACOLOR(232, 79, 60, 1);
        button.layer.cornerRadius = 5;
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        [_headerView addSubview:self.textField];
        [_headerView addSubview:button];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom);
            make.left.equalTo(self.headerView.mas_left).with.offset(60);
            make.right.equalTo(button.mas_left).with.offset(-10);
            make.bottom.equalTo(self.headerView.mas_bottom);
        }];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).with.offset(5);
            make.left.equalTo(self.textField.mas_right).with.offset(10);
            make.right.equalTo(self.headerView.mas_right).with.offset(-60);
            make.height.mas_equalTo(@30);
            make.width.mas_equalTo(@60);
        }];
        
        //line
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_headerView addSubview:line];
    }
    return _headerView;
}

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

#pragma mark - Private
- (void)addFriend:(id *)sender {
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    [addController initname:self.textField.text];
    [self.navigationController pushViewController:addController animated:YES];
    
}
@end
