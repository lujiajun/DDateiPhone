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

@interface IndexViewController () <UITableViewDelegate, UITableViewDataSource, SRRefreshDelegate>

@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (strong, nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;

@property (strong, nonatomic) AWSDynamoDB_ChatRoom2 *chatRoom2DynamoDB;

@property (strong, nonatomic) DDUserDAO *userDao;

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) NSMutableArray *oppositeGenderDataSource;

@property (nonatomic) BOOL haveFriend;

@end

static DDUser *uuser;

#define kIMGCOUNT 5

#define TAB_BAR_HEIGHT self.tabBarController.tabBar.frame.size.height

@implementation IndexViewController

+ (DDUser *)instanceDDuser {
	return uuser;
}

+ (void)setDDUser:(DDUser *)user {
	uuser = user;
}

- (instancetype)init {
	if (self = [super init]) {
		_userDao = [[DDUserDAO alloc] init];
		_chatRoom2DynamoDB = [[AWSDynamoDB_ChatRoom2 alloc] init];
		_dataSource = [NSMutableArray array];
        _oppositeGenderDataSource = [NSMutableArray array];
		
        //1.先用本地数据做展示
		[_dataSource addObjectsFromArray:[self.chatRoom2DynamoDB refreshListWithLocalData]];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.view addSubview:self.tableView];
	[self.tableView mas_makeConstraints: ^(MASConstraintMaker *make) {
	    make.top.equalTo(self.view.mas_top);
	    make.left.equalTo(self.view.mas_left);
	    make.right.equalTo(self.view.mas_right);
	    make.bottom.equalTo(self.view.mas_bottom).with.offset(-TAB_BAR_HEIGHT);
	}];

	//2.去网络端获取最新的数据
	[self.chatRoom2DynamoDB refreshListWithBlock: ^(NSArray *chatRoom2s) {
	    [self addDataSourceIgnoreSame:chatRoom2s];
	    [self.tableView reloadData];
	}];

	//首页button
	[self initdduser];
}

- (void)viewDidAppear:(BOOL)animated {
	//获取好友列表
	self.haveFriend = [self haveDoubleFriend];
	if (!self.haveFriend) {
		[self.view addSubview:self.headerView];
		[self.tableView mas_remakeConstraints: ^(MASConstraintMaker *make) {
		    make.top.equalTo(self.headerView.mas_bottom);
		    make.left.equalTo(self.view.mas_left);
		    make.right.equalTo(self.view.mas_right);
		    make.bottom.equalTo(self.view.mas_bottom).with.offset(-TAB_BAR_HEIGHT);
		}];
	}
}

- (void)initdduser {
	if (uuser == nil) {
		NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
		NSString *username = [loginInfo objectForKey:kSDKUsername];
		uuser = [_userDao selectDDuserByUid:username];
		if (uuser == nil) {
			_dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
			[[_dynamoDBObjectMapper load:[DDUser class] hashKey:username rangeKey:nil]
			 continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock: ^id (BFTask *task) {
			    uuser = task.result;
			    [self.userDao insertDDUser:uuser];
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
	return self.showOppositeGender ? self.oppositeGenderDataSource.count : self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"HomePageListCell";
	HomePageListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[HomePageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    
	CHATROOM2 *chatRoom2 = self.showOppositeGender ? [self.oppositeGenderDataSource objectAtIndex:indexPath.row] : [self.dataSource objectAtIndex:indexPath.row];

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
	BOOL isboy = uuser1.gender.intValue == 0;
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
		for (NSUInteger i = 0; i < self.dataSource.count; i++) {
			if (indexPath.row == i) {
				CHATROOM2 *room = [[self.dataSource objectAtIndex:i] copy];
				ChatRoomDetail *chatroom = [[ChatRoomDetail alloc]initChatRoom:room uuser1:[self.userDao selectDDuserByUid:room.UID1] uuser2:[self.userDao selectDDuserByUid:room.UID2]];
//                 self.navigationController.navigationBarHidden=YES;
                
				[self.navigationController pushViewController:chatroom animated:YES];
			}
		}
	}
}

//每行缩进
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

#pragma mark - SRRefreshDelegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
	__weak IndexViewController *weakSelf = self;
	[self.chatRoom2DynamoDB refreshListWithBlock:^(NSArray *chatRoom2s) {
        [self addDataSourceIgnoreSame:chatRoom2s];
        [self.tableView reloadData];
        [weakSelf.slimeView endRefresh];
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

#pragma mark - setter

- (void)setShowOppositeGender:(BOOL)showOppositeGender {
	if (_showOppositeGender != showOppositeGender) {
		_showOppositeGender = showOppositeGender;
		if (showOppositeGender) {
			[self.oppositeGenderDataSource removeAllObjects];
			for (CHATROOM2 *chatRoom2 in self.dataSource) {
				if (chatRoom2.Gender.intValue != uuser.gender.intValue) {
					[self.oppositeGenderDataSource addObject:chatRoom2];
				}
			}
		}
		[self.tableView reloadData];
	}
}

#pragma mark - getter
- (UITableView *)tableView {
	if (_tableView == nil) {
		_tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView addSubview:self.slimeView];
	}
	return _tableView;
}

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

#pragma mark - Private
- (void)addFriend:(id *)sender {
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    [addController initname:self.textField.text];
    [self.navigationController pushViewController:addController animated:YES];
    
}

- (void)addDataSourceIgnoreSame:(NSArray *)data {
	for (CHATROOM2 *chatRoom2 in data) {
		if (![self isInDataSource:chatRoom2]) {
			[self.dataSource addObject:chatRoom2];
		}
	}
}

- (BOOL)isInDataSource:(CHATROOM2 *)chatRoom2 {
	for (CHATROOM2 *eachDataSource in self.dataSource) {
		if ([chatRoom2.RID isEqualToString:eachDataSource.RID]) {
			return YES;
		}
	}
	return NO;
}

@end
