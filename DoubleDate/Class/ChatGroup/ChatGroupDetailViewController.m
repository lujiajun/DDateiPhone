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

#import "ChatGroupDetailViewController.h"

#import "ContactSelectionViewController.h"
#import "GroupSettingViewController.h"
#import "EMGroup.h"
#import "ContactView.h"
#import "GroupBansViewController.h"
#import "GroupSubjectChangingViewController.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "DDUserDAO.h"
#import "Util.h"

#pragma mark - ChatGroupDetailViewController

#define kColOfRow 5
#define kContactSize 60

@interface ChatGroupDetailViewController ()<IChatManagerDelegate, EMChooseViewDelegate, UIActionSheetDelegate>

- (void)unregisterNotifications;
- (void)registerNotifications;

@property (nonatomic) GroupOccupantType occupantType;
@property (strong, nonatomic) EMGroup *chatGroup;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *addButton;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *dissolveButton;
@property (strong, nonatomic) UIButton *configureButton;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) ContactView *selectedContact;

@property(strong,nonatomic) DDUser *uuser1;
@property(strong,nonatomic) DDUser *uuser2;
@property(strong,nonatomic) DDUser *uuser3;
@property(strong,nonatomic) DDUser *uuser4;
@property(strong,nonatomic) CHATROOM4  *chatroom4;


- (void)dissolveAction;
- (void)clearAction;
- (void)exitAction;
- (void)configureAction;

@end

@implementation ChatGroupDetailViewController

- (void)registerNotifications {
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc {
    [self unregisterNotifications];
}

- (instancetype)initWithGroup:(EMGroup *)chatGroup
{
    self = [super init];
    if (self) {
        // Custom initialization
        _chatGroup = chatGroup;
        _dataSource = [NSMutableArray array];
        _occupantType = GroupOccupantTypeMember;
        [self registerNotifications];
    }
    return self;
}

- (instancetype)initWithGroupId:(NSString *)chatGroupId chatroom4:(CHATROOM4 *) chatroom4
{
    //查询
    if(_chatroom4==nil){
        _chatroom4=chatroom4;
        [self getDDusers];
    }
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:chatGroupId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:chatGroupId];
    }
    
    self = [self initWithGroup:chatGroup];
    if (self) {
        //
    }
    
    return self;
}

-(void) getDDusers{
    //查询数据库
    DDUserDAO *dao=[[DDUserDAO alloc] init];
    _uuser1=[dao selectDDuserByUid:_chatroom4.UID1];
    _uuser2=[dao selectDDuserByUid:_chatroom4.UID2];
    _uuser3=[dao selectDDuserByUid:_chatroom4.UID3];
    _uuser4=[dao selectDDuserByUid:_chatroom4.UID4];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    self.tableView.tableFooterView = self.footerView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupBansChanged) name:@"GroupBansChanged" object:nil];
    
    
    [self fetchGroupInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, kContactSize)];
        _scrollView.tag = 0;
        
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kContactSize - 10, kContactSize - 10)];
        [_addButton setImage:[UIImage imageNamed:@"group_participant_add"] forState:UIControlStateNormal];
        [_addButton setImage:[UIImage imageNamed:@"group_participant_addHL"] forState:UIControlStateHighlighted];
        [_addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteContactBegin:)];
        _longPress.minimumPressDuration = 0.5;
    }
    
    return _scrollView;
}

- (UIButton *)clearButton
{
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] init];
        [_clearButton setTitle:NSLocalizedString(@"group.removeAllMessages", @"remove all messages") forState:UIControlStateNormal];
        [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        [_clearButton setBackgroundColor:[UIColor colorWithRed:87 / 255.0 green:186 / 255.0 blue:205 / 255.0 alpha:1.0]];
    }
    
    return _clearButton;
}

- (UIButton *)dissolveButton
{
    if (_dissolveButton == nil) {
        _dissolveButton = [[UIButton alloc] init];
        [_dissolveButton setTitle:NSLocalizedString(@"group.destroy", @"dissolution of the group") forState:UIControlStateNormal];
        [_dissolveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dissolveButton addTarget:self action:@selector(dissolveAction) forControlEvents:UIControlEventTouchUpInside];
        [_dissolveButton setBackgroundColor: [UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];
    }
    
    return _dissolveButton;
}

- (UIButton *)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [[UIButton alloc] init];
        [_exitButton setTitle:NSLocalizedString(@"group.leave", @"quit the group") forState:UIControlStateNormal];
        [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [_exitButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];
    }
    
    return _exitButton;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 160)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        self.clearButton.frame = CGRectMake(20, 40, _footerView.frame.size.width - 40, 35);
        [_footerView addSubview:self.clearButton];
        
        self.dissolveButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
        
        self.exitButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
    }
    
    return _footerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.occupantType == GroupOccupantTypeOwner)
    {
        return 7;
    }
    else
    {
        return 6;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        [self showUser1:cell.contentView uuser1:_uuser1];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [cell.contentView addSubview:self.scrollView];
    }
    else if (indexPath.row == 1)
    {
      [self showUser1:cell.contentView uuser1:_uuser2];
//        cell.textLabel.text = NSLocalizedString(@"group.id", @"group ID");
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.detailTextLabel.text = _chatGroup.groupId;
    }
    else if (indexPath.row == 2)
    {
     [self showUser1:cell.contentView uuser1:_uuser3] ;
        //        cell.textLabel.text = NSLocalizedString(@"group.occupantCount", @"members count");
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i", (int)[_chatGroup.occupants count], (int)_chatGroup.groupSetting.groupMaxUsersCount];
    }
    else if (indexPath.row == 3)
    {
       [self showUser1:cell.contentView uuser1:_uuser4];
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = NSLocalizedString(@"title.groupSetting", @"Group Setting");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = NSLocalizedString(@"title.groupSubjectChanging", @"Change group name");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

//        cell.textLabel.text = NSLocalizedString(@"title.groupBlackList", @"Group black list");
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}
-(void)showUser1:(UIView *) bakview uuser1:(DDUser *) user{
    
    UIImageView *headview=[[UIImageView alloc]initWithFrame:CGRectMake(bakview.frame.origin.x+10, bakview.frame.origin.y+10, 80, 80)];

    [headview sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user.picPath]]
          placeholderImage:[UIImage imageNamed:@"Logo_new"]];

    
    headview.frame=CGRectMake(bakview.frame.origin.x+5, bakview.frame.origin.y+10, 80, 80);
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =40;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, headview.frame.origin.y+15, self.view.frame.size.width-120, 12)];
    nickname.text=user.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:nickname];
    //性别
    BOOL isboy=NO;
    if(user!=nil){
        if(user.gender.intValue==0){
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
    isboyview.frame=CGRectMake(150, 6, 20, 20);
    [bakview addSubview:isboyview];
    //学校
    UILabel *university=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, nickname.frame.origin.y+nickname.frame.size.height+5, self.view.frame.size.width-120, 12)];
    university.text=user.city;
    university.textAlignment=NSTextAlignmentLeft;
    university.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:university];
    //学校图片
//    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//    schoolview.frame=CGRectMake(university.frame.origin.x+university.frame.size.width+15, university.frame.origin.y, 20, 10);
//    [bakview addSubview:schoolview];
    //年级
    UILabel *gender=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+12, university.frame.origin.y+university.frame.size.height+5, self.view.frame.size.width-120, 12)];
    gender.text=user.birthday;
    gender.textAlignment=NSTextAlignmentLeft;
    gender.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:gender];

    
    
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    if (row == 0 ||row == 1||row==2||row==3) {
        return 130;
    }
    else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 4) {
        GroupSettingViewController *settingController = [[GroupSettingViewController alloc] initWithGroup:_chatGroup];
        [self.navigationController pushViewController:settingController animated:YES];
    }
    else if (indexPath.row == 5)
    {
        GroupSubjectChangingViewController *changingController = [[GroupSubjectChangingViewController alloc] initWithGroup:_chatGroup];
        [self.navigationController pushViewController:changingController animated:YES];
    }
//    else if (indexPath.row == 5) {
//        GroupBansViewController *bansController = [[GroupBansViewController alloc] initWithGroup:_chatGroup];
//        [self.navigationController pushViewController:bansController animated:YES];
//    }
}

#pragma mark - EMChooseViewDelegate
- (void)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources
{
    [self showHudInView:self.view hint:NSLocalizedString(@"group.addingOccupant", @"add a group member...")];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *source = [NSMutableArray array];
        for (EMBuddy *buddy in selectedSources) {
            [source addObject:buddy.username];
        }
        
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", @"%@ invite you to join group \'%@\'"), username, weakSelf.chatGroup.groupSubject];
        EMError *error = nil;
        weakSelf.chatGroup = [[EaseMob sharedInstance].chatManager addOccupants:source toGroup:weakSelf.chatGroup.groupId welcomeMessage:messageStr error:&error];
        if (!error) {
            [weakSelf reloadDataSource];
        }
    });
}

- (void)groupBansChanged
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:self.chatGroup.occupants];
    [self refreshScrollView];
}

#pragma mark - data

- (void)fetchGroupInfo
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:_chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (!error) {
                weakSelf.chatGroup = group;
                [weakSelf reloadDataSource];
                
//                NSString *tmp = [group.members objectAtIndex:0];
//                NSString *tmp = @"zxcvbn";
//                [[EaseMob sharedInstance].chatManager asyncBlockOccupants:@[tmp] fromGroup:group.groupId completion:^(EMGroup *group, EMError *error){
//                    if (!error) {
//                        //
//                    }
//                    
//                } onQueue:nil];
                
//                [[EaseMob sharedInstance].chatManager asyncUnblockOccupants:@[tmp] forGroup:group.groupId completion:^(EMGroup *group, EMError *error) {
//                    if (!error) {
//                        //
//                    }
//                } onQueue:nil];
                
//                [[EaseMob sharedInstance].chatManager asyncFetchGroupBansList:group.groupId completion:^(NSArray *groupBans, EMError *error) {
//                    if (!error) {
//                        //
//                    }
//                } onQueue:nil];
                
//                [[EaseMob sharedInstance].chatManager asyncLeaveGroup:@"1413452243774" completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
//                    if (!error) {
//                        //
//                    }
//                } onQueue:nil];
            }
            else{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
//                [weakSelf reloadDataSource];
            }
        });
    } onQueue:nil];
}

- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    
    self.occupantType = GroupOccupantTypeMember;
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    if ([self.chatGroup.owner isEqualToString:loginUsername]) {
        self.occupantType = GroupOccupantTypeOwner;
    }
    
    if (self.occupantType != GroupOccupantTypeOwner) {
        for (NSString *str in self.chatGroup.members) {
            if ([str isEqualToString:loginUsername]) {
                self.occupantType = GroupOccupantTypeMember;
                break;
            }
        }
    }
    
    [self.dataSource addObjectsFromArray:self.chatGroup.occupants];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self refreshScrollView];
//        [self refreshFooterView];
        [self hideHud];
    });
}

- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView removeGestureRecognizer:_longPress];
    [self.addButton removeFromSuperview];
    
    BOOL showAddButton = NO;
    if (self.occupantType == GroupOccupantTypeOwner) {
        [self.scrollView addGestureRecognizer:_longPress];
        [self.scrollView addSubview:self.addButton];
        showAddButton = YES;
    }
    else if (self.chatGroup.groupSetting.groupStyle == eGroupStyle_PrivateMemberCanInvite && self.occupantType == GroupOccupantTypeMember) {
        [self.scrollView addSubview:self.addButton];
        showAddButton = YES;
    }
    
    int tmp = ([self.dataSource count] + 1) % kColOfRow;
    int row = (int)([self.dataSource count] + 1) / kColOfRow;
    row += tmp == 0 ? 0 : 1;
    self.scrollView.tag = row;
    self.scrollView.frame = CGRectMake(10, 20, self.tableView.frame.size.width - 20, row * kContactSize);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, row * kContactSize);
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    
    int i = 0;
    int j = 0;
    BOOL isEditing = self.addButton.hidden ? YES : NO;
    BOOL isEnd = NO;
    for (i = 0; i < row; i++) {
        for (j = 0; j < kColOfRow; j++) {
            NSInteger index = i * kColOfRow + j;
            if (index < [self.dataSource count]) {
                NSString *username = [self.dataSource objectAtIndex:index];
                ContactView *contactView = [[ContactView alloc] initWithFrame:CGRectMake(j * kContactSize, i * kContactSize, kContactSize, kContactSize)];
                contactView.index = i * kColOfRow + j;
                contactView.image = [UIImage imageNamed:@"chatListCellHead.png"];
                contactView.remark = username;
                if (![username isEqualToString:loginUsername]) {
                    contactView.editing = isEditing;
                }
                
                __weak typeof(self) weakSelf = self;
                [contactView setDeleteContact:^(NSInteger index) {
                    [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"group.removingOccupant", @"deleting member...")];
                    NSArray *occupants = [NSArray arrayWithObject:[weakSelf.dataSource objectAtIndex:index]];
                    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:weakSelf.chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
                        [weakSelf hideHud];
                        if (!error) {
                            weakSelf.chatGroup = group;
                            [weakSelf.dataSource removeObjectAtIndex:index];
                            [weakSelf refreshScrollView];
                        }
                        else{
                            [weakSelf showHint:error.description];
                        }
                    } onQueue:nil];
                }];
                
                [self.scrollView addSubview:contactView];
            }
            else{
                if(showAddButton && index == self.dataSource.count)
                {
                    self.addButton.frame = CGRectMake(j * kContactSize + 5, i * kContactSize + 10, kContactSize - 10, kContactSize - 10);
                }
                
                isEnd = YES;
                break;
            }
        }
        
        if (isEnd) {
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)refreshFooterView
{
    if (self.occupantType == GroupOccupantTypeOwner) {
        [_exitButton removeFromSuperview];
        [_footerView addSubview:self.dissolveButton];
    }
    else{
        [_dissolveButton removeFromSuperview];
        [_footerView addSubview:self.exitButton];
    }
}

#pragma mark - action

- (void)tapView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        if (self.addButton.hidden) {
            [self setScrollViewEditing:NO];
        }
    }
}

- (void)deleteContactBegin:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        for (ContactView *contactView in self.scrollView.subviews)
        {
            CGPoint locaton = [longPress locationInView:contactView];
            if (CGRectContainsPoint(contactView.bounds, locaton))
            {
                if ([contactView isKindOfClass:[ContactView class]]) {
                    if ([contactView.remark isEqualToString:loginUsername]) {
                        return;
                    }
                    _selectedContact = contactView;
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"delete", @"deleting member..."), NSLocalizedString(@"friend.block", @"add to black list"), nil];
                    [sheet showInView:self.view];
                }
            }
        }
    }
}

- (void)setScrollViewEditing:(BOOL)isEditing
{
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    
    for (ContactView *contactView in self.scrollView.subviews)
    {
        if ([contactView isKindOfClass:[ContactView class]]) {
            if ([contactView.remark isEqualToString:loginUsername]) {
                continue;
            }
            
            [contactView setEditing:isEditing];
        }
    }
    
    self.addButton.hidden = isEditing;
}

- (void)addContact:(id)sender
{
    ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] initWithBlockSelectedUsernames:_chatGroup.occupants];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

//清空聊天记录
- (void)clearAction
{
    __weak typeof(self) weakSelf = self;
    [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"sureToDelete", @"please make sure to delete") customizationBlock:nil completionBlock:
     ^(NSUInteger buttonIndex, WCAlertView *alertView) {
         if (buttonIndex == 1) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:weakSelf.chatGroup.groupId];
         }
     } cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
}

//解散群组
- (void)dissolveAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"group.destroy", @"dissolution of the group")];
    [[EaseMob sharedInstance].chatManager asyncDestroyGroup:_chatGroup.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:NSLocalizedString(@"group.destroyFail", @"dissolution of group failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
    
//    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId];
}

//设置群组
- (void)configureAction {
// todo
    [[[EaseMob sharedInstance] chatManager] asyncIgnoreGroupPushNotification:_chatGroup.groupId
                                                                    isIgnore:_chatGroup.isPushNotificationEnabled];

    return;
    UIViewController *viewController = [[UIViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

//退出群组
- (void)exitAction
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"group.leave", @"quit the group")];
    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId completion:^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:NSLocalizedString(@"group.leaveFail", @"exit the group failure")];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
        }
    } onQueue:nil];
    
//    [[EaseMob sharedInstance].chatManager asyncLeaveGroup:_chatGroup.groupId];
}

//- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error {
//    __weak ChatGroupDetailViewController *weakSelf = self;
//    [weakSelf hideHud];
//    if (error) {
//        if (reason == eGroupLeaveReason_UserLeave) {
//            [weakSelf showHint:@"退出群组失败"];
//        } else {
//            [weakSelf showHint:@"解散群组失败"];
//        }
//    }
//}

- (void)didIgnoreGroupPushNotification:(NSArray *)ignoredGroupList error:(EMError *)error {
// todo
    NSLog(@"ignored group list:%@.", ignoredGroupList);
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger index = _selectedContact.index;
    if (buttonIndex == 0)
    {
        //delete
        _selectedContact.deleteContact(index);
    }
    else if (buttonIndex == 1)
    {
        //add to black list
        [self showHudInView:self.view hint:@"Adding to black list"];
        NSArray *occupants = [NSArray arrayWithObject:[self.dataSource objectAtIndex:_selectedContact.index]];
        __weak ChatGroupDetailViewController *weakSelf = self;
        [[EaseMob sharedInstance].chatManager asyncBlockOccupants:occupants fromGroup:self.chatGroup.groupId completion:^(EMGroup *group, EMError *error) {
            if (weakSelf)
            {
                __weak ChatGroupDetailViewController *strongSelf = weakSelf;
                [strongSelf hideHud];
                if (!error) {
                    strongSelf.chatGroup = group;
                    [strongSelf.dataSource removeObjectAtIndex:index];
                    [strongSelf refreshScrollView];
                }
                else{
                    [strongSelf showHint:error.description];
                }
            }
        } onQueue:nil];
    }
    _selectedContact = nil;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    _selectedContact = nil;
}
@end
