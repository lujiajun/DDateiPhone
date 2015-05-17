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

#import "MainViewController.h"

#import "UIViewController+HUD.h"
#import "ContactsViewController.h"
#import "NewSettingViewController.h"
#import "ApplyViewController.h"
#import "CallSessionViewController.h"
#import "IndexViewController.h"
#import "CreateGroupViewController.h"
#import "MainChatListViewController.h"
#import "UIColor+Category.h"
#import "AddFriendViewController.h"
#import "DDDataManager.h"
#import "SVProgressHUD.h"
#import "DDPersonalUpdateController.h"
#import "InviteFriendByDoubleIdController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface MainViewController () <UIAlertViewDelegate, IChatManagerDelegate, EMCallManagerDelegate, UIActionSheetDelegate>
{
    IndexViewController *_indexVC;
    MainChatListViewController *_chatListVC;
    ContactsViewController *_contactsVC;
    NewSettingViewController *_settingsVC;
    CallSessionViewController *_callController;
    
    UIBarButtonItem *_addFriendItem;
    UIBarButtonItem *_inviteFriendItem;
    UIBarButtonItem *_createGroupItem;
    UIBarButtonItem *_editProfileItem;
    
    UISegmentedControl *_roomTypeControl;
    }

@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

#define BLUE_GREEN_COLOR @"#00C8D3"

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if 使tabBarController中管理的viewControllers都符合 UIRectEdgeNone
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = NSLocalizedString(@"title.index", @"Double Date");

    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];
#warning 把self注册为SDK的delegate
    [self registerNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUntreatedApplyCount) name:@"setupUntreatedApplyCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callOutWithChatter:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:@"callControllerClose" object:nil];
    
    
    //创建二人聊天室
    _createGroupItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createGroup)];
    _addFriendItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddFriend:)];
    _editProfileItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditProfile:)];

    [self setupUnreadMessageCount];
    [self setupUntreatedApplyCount];
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    DDUser* user = [DDDataManager sharedManager].user;
    if (! user) {
        [[DDDataManager sharedManager] loadUser:loginUsername];
    }
    
    [self setupSubviews];
    self.selectedIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	if ([[DDDataManager sharedManager] haveAnyFriends]) {
        _inviteFriendItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onInviteFriend:)];
	} else {
        _inviteFriendItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onInviteFriend:)];
	}
    
    if (self.selectedIndex == 0) {
        self.navigationItem.rightBarButtonItem = _inviteFriendItem;
        [self tabBar: self.tabBar didSelectItem:_indexVC.tabBarItem];
    }
}

- (void)dealloc
{
    [self unregisterNotifications];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item.tag == 0) {
		self.title = NSLocalizedString(@"title.index", @"Index");
		self.navigationItem.rightBarButtonItem = _inviteFriendItem;
        // NSArray* items = @[[UIImage imageNamed:@"all_off"], [UIImage imageNamed:@"other_on"]];
        NSArray* items =  @[@" 全部 ", @" 异性 "];
        _roomTypeControl = [[UISegmentedControl alloc] initWithItems: items];
        [_roomTypeControl addTarget:self action:@selector(onRoomTypeChanged:) forControlEvents:UIControlEventValueChanged];
        _roomTypeControl.selectedSegmentIndex = 0;
        _roomTypeControl.tintColor = [UIColor whiteColor];
        [self.navigationItem setTitleView:_roomTypeControl];
    
	} else if (item.tag == 1)  {
		self.title = NSLocalizedString(@"title.conversation", @"Conversations");
		self.navigationItem.rightBarButtonItem = _createGroupItem;
        [self.navigationItem setTitleView:nil];
	} else if (item.tag == 2)  {
		self.title = NSLocalizedString(@"title.addressbook", @"AddressBook");
		self.navigationItem.rightBarButtonItem = _addFriendItem;
        [self.navigationItem setTitleView:nil];
	} else if (item.tag == 3)  {
		self.title = NSLocalizedString(@"title.setting", @"Setting");
		self.navigationItem.rightBarButtonItem = _editProfileItem;
        [self.navigationItem setTitleView:nil];
		[_settingsVC refreshConfig];
    }
}

- (void) onRoomTypeChanged: (id) sender {
    if (_roomTypeControl.selectedSegmentIndex == 0) {
        _indexVC.showOppositeGender = NO;
    } else {
        _indexVC.showOppositeGender = YES;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                [[ApplyViewController shareController] clear];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            } onQueue:nil];
        }
    }
    else if (alertView.tag == 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    } else if (alertView.tag == 101) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    }
}

#pragma mark - private

-(void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EMSDKFull sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EMSDKFull sharedInstance].callManager removeDelegate:self];
}

- (void)setupSubviews
{
//    self.tabBar.backgroundImage = [[UIImage imageNamed:@"tabbarBackground"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
//    self.tabBar.selectionIndicatorImage = [[UIImage imageNamed:@"tabbarSelectBg"] stretchableImageWithLeftCapWidth:25 topCapHeight:25];
	self.tabBar.backgroundColor = [UIColor colorWithR:248 G:248 B:248];
    
   
    //index
    _indexVC = [[IndexViewController alloc] init];
//    [_indexVC networkChanged:_connectionState];
    
    _indexVC.tabBarItem.title=NSLocalizedString(@"title.index", @"Double Date");
    _indexVC.tabBarItem.image=[[UIImage imageNamed:@"indexoff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _indexVC.tabBarItem.selectedImage=[[UIImage imageNamed:@"indexon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _indexVC.tabBarItem.tag = 0;

    //    _indexVC.tabBarItem.imageInsets = UIEdgeInsetsMake(0, -10, -6, -10);
    [self unSelectedTapTabBarItems:_indexVC.tabBarItem];
    [self selectedTapTabBarItems:_indexVC.tabBarItem];
    
    //conversations
    _chatListVC = [[MainChatListViewController alloc] init];
    [_chatListVC networkChanged:_connectionState];
    _chatListVC.tabBarItem.title=NSLocalizedString(@"title.conversation", @"Conversations");
    _chatListVC.tabBarItem.image=[[UIImage imageNamed:@"chatoff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _chatListVC.tabBarItem.selectedImage=[[UIImage imageNamed:@"chaton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _chatListVC.tabBarItem.tag = 1;
    [self unSelectedTapTabBarItems:_chatListVC.tabBarItem];
    [self selectedTapTabBarItems:_chatListVC.tabBarItem];
    
    //address book
    _contactsVC = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    
    _contactsVC.tabBarItem.title=NSLocalizedString(@"title.addressbook", @"AddressBook");
    _contactsVC.tabBarItem.image=[[UIImage imageNamed:@"friendoff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _contactsVC.tabBarItem.selectedImage=[[UIImage imageNamed:@"friendon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _contactsVC.tabBarItem.tag = 2;
    [self unSelectedTapTabBarItems:_contactsVC.tabBarItem];
    [self selectedTapTabBarItems:_contactsVC.tabBarItem];
    
    //Setting
    _settingsVC = [[NewSettingViewController alloc] init];
    _settingsVC.title=NSLocalizedString(@"title.setting", @"Setting");
    _settingsVC.tabBarItem.image=[[UIImage imageNamed:@"settingoff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _settingsVC.tabBarItem.selectedImage=[[UIImage imageNamed:@"settingon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _settingsVC.tabBarItem.tag = 3;
    _settingsVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self unSelectedTapTabBarItems:_settingsVC.tabBarItem];
    [self selectedTapTabBarItems:_settingsVC.tabBarItem];
    
    self.viewControllers = @[_indexVC,_chatListVC, _contactsVC, _settingsVC];
    [self selectedTapTabBarItems:_indexVC.tabBarItem];
}

- (void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem {
	[tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                    [UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor colorWithR:108 G:108 B:108], NSForegroundColorAttributeName,
	                                    nil] forState:UIControlStateNormal];
}

- (void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem {
	[tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                    [UIFont systemFontOfSize:14],
	                                    NSFontAttributeName, [UIColor redColor], NSForegroundColorAttributeName,
	                                    nil] forState:UIControlStateSelected];
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatListVC) {
        if (unreadCount > 0) {
            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
    if (_contactsVC) {
        if (unreadCount > 0) {
            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _contactsVC.tabBarItem.badgeValue = nil;
        }
    }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    //链接状态修改
    _connectionState = connectionState;
    [_chatListVC networkChanged:connectionState];
}

- (void)callOutWithChatter:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSString class]]) {
        NSString *chatter = (NSString *)object;
        
        if (_callController == nil) {
            EMError *error = nil;
            EMCallSession *callSession = [[EMSDKFull sharedInstance].callManager asyncCallAudioWithChatter:chatter timeout:50 error:&error];
            
            if (callSession) {
                [[EMSDKFull sharedInstance].callManager removeDelegate:self];
                _callController = [[CallSessionViewController alloc] initCallOutWithSession:callSession];
                [self presentViewController:_callController animated:YES completion:nil];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:error.description delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        else{
            [self showHint:@"正在通话中"];
        }
    }
}

- (void)callControllerClose:(NSNotification *)notification
{
    [[EMSDKFull sharedInstance].callManager addDelegate:self delegateQueue:nil];
    _callController = nil;
}

- (void)createGroup
{
    CreateGroupViewController *createChatroom = [[CreateGroupViewController alloc] init];
    [self.navigationController pushViewController:createChatroom animated:YES];
}

- (void) onEditProfile: (id) sender {
    DDPersonalUpdateController *vc = [[DDPersonalUpdateController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) onInviteFriend: (id) sender {
    //判断状态，进行跳转
    if ([[DDDataManager sharedManager] haveAnyFriends]) {
        CreateGroupViewController *createChatroom = [[CreateGroupViewController alloc] init];
        [self.navigationController pushViewController:createChatroom animated:YES];
    } else {
        InviteFriendByDoubleIdController *addController = [[InviteFriendByDoubleIdController alloc] init];
        [self.navigationController pushViewController:addController animated:YES];
    }
}

- (void) onAddFriend: (id) sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"邀请好友",@"添加好友",nil];
    [actionSheet showInView:self.view];
}

-(void) doContactsInviteFriend{
    InviteFriendByDoubleIdController *addController = [InviteFriendByDoubleIdController alloc];
    [self.navigationController pushViewController:addController animated:YES];
}

-(void) doContactsAddFriend{
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            [self doContactsInviteFriend];
        } else {
            [self doContactsAddFriend];
        }
    }
}


#pragma mark - IChatManagerDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [_chatListVC refreshDataSource];
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
    [_chatListVC didUnreadMessagesCountChanged];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error {
    [_chatListVC refreshDataSourceWithLocalData];
}

- (void)didAcceptInvitationFromGroup:(EMGroup *)group error:(EMError *)error {
    [_chatListVC refreshDataSource];
}


- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self setupUnreadMessageCount];
    [_chatListVC didFinishedReceiveOfflineMessages:offlineMessages];
}

- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    
}

- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    return ret;
}

// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }else {
            [self playSoundAndVibration];
        }
#endif
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.vidio", @"Vidio");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        NSString *hintText = NSLocalizedString(@"reconnection.retry", @"Fail to log in your account, is try again... \nclick 'logout' button to jump to the login page \nclick 'continue to wait for' button for reconnection successful");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                                            message:hintText
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"reconnection.wait", @"continue to wait")
                                                  otherButtonTitles:NSLocalizedString(@"logout", @"Logout"),
                                  nil];
        alertView.tag = 99;
        [alertView show];
        [_chatListVC isConnect:NO];
    }
}

#pragma mark - IChatManagerDelegate 好友变化

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
#if !TARGET_IPHONE_SIMULATOR
    [self playSoundAndVibration];
    
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        //发送本地推送
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), username];
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
    }
#endif
    
    [_contactsVC reloadApplyView];
}

- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd
{
    [_contactsVC reloadDataSource];
}

- (void)didRemovedByBuddy:(NSString *)username
{
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:username deleteMessages:YES append2Chat:YES];
    [_chatListVC refreshDataSource];
    [_contactsVC reloadDataSource];
}

- (void)didAcceptedByBuddy:(NSString *)username
{
    [_contactsVC reloadDataSource];
}

- (void)didRejectedByBuddy:(NSString *)username
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.beRefusedToAdd", @"you are shameless refused by '%@'"), username];
    TTAlertNoTitle(message);
}

- (void)didAcceptBuddySucceed:(NSString *)username
{
    [_contactsVC reloadDataSource];
}

#pragma mark - IChatManagerDelegate 群组变化

- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
                              inviter:(NSString *)username
                              message:(NSString *)message
{
#if !TARGET_IPHONE_SIMULATOR
    [self playSoundAndVibration];
#endif
    
    [_contactsVC reloadGroupView];
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!error) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
#endif
        
        [_contactsVC reloadGroupView];
    }
}

- (void)didReceiveGroupRejectFrom:(NSString *)groupId
                          invitee:(NSString *)username
                           reason:(NSString *)reason
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.beRefusedToAdd", @"you are shameless refused by '%@'"), username];
    TTAlertNoTitle(message);
}


- (void)didReceiveAcceptApplyToJoinGroup:(NSString *)groupId
                               groupname:(NSString *)groupname
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedToJoin", @"agreed to join the group of \'%@\'"), groupname];
    [self showHint:message];
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        alertView.tag = 100;
        [alertView show];
        
    } onQueue:nil];
}

- (void)didRemovedFromServer
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginUserRemoveFromServer", @"your account has been removed from the server side") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

//- (void)didConnectionStateChanged:(EMConnectionState)connectionState
//{
//    [_chatListVC networkChanged:connectionState];
//}

#pragma mark - 自动登录回调

- (void)willAutoReconnect{
    [self hideHud];
    [self showHint:NSLocalizedString(@"reconnection.ongoing", @"reconnecting...")];
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    [self hideHud];
    if (error) {
        [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
    }else{
        [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
    }
}

#pragma mark - ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error
{
    if (callSession.status == eCallSessionStatusConnected)
    {
        if (_callController == nil) {
            _callController = [[CallSessionViewController alloc] initCallInWithSession:callSession];
            [self presentViewController:_callController animated:YES completion:nil];
        }
    }
}

#pragma mark - public

- (void)jumpToChatList
{
    if(_chatListVC)
    {
        [self.navigationController popToViewController:self animated:NO];
        [self setSelectedViewController:_chatListVC];
    }
}

@end
