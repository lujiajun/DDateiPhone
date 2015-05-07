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

#import "Contact4GroupAddViewController.h"

#import "EMSearchBar.h"
#import "EMRemarkImageView.h"
#import "EMSearchDisplayController.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "DDUserDAO.h"
#import "Constants.h"
#import "UIImageView+EMWebCache.h"
#import "ChatRoom4DAO.h"
#import "AWSDynamoDB_ChatRoom4.h"


@interface Contact4GroupAddViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@property (strong, nonatomic) NSIndexPath *currentSelectIndexpath;
@property (strong, nonatomic) NSMutableArray *blockSelectedUsernames;

@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIScrollView *footerScrollView;
@property (strong, nonatomic) UIButton *doneButton;
@property(strong,nonatomic) CHATROOM2 *room2;
@property(strong) DDUserDAO *userDao;
@property(strong,nonatomic) NSString *username;
@property(strong,nonatomic) NSString *toAddFriend;
@end

@implementation Contact4GroupAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _contactsSource = [NSMutableArray array];
        _selectedContacts = [NSMutableArray array];
        
        [self setObjectComparisonStringBlock:^NSString *(id object) {
            EMBuddy *buddy = (EMBuddy *)object;
            return buddy.username;
        }];
        
        [self setComparisonObjectSelector:^NSComparisonResult(id object1, id object2) {
            EMBuddy *buddy1 = (EMBuddy *)object1;
            EMBuddy *buddy2 = (EMBuddy *)object2;
            
            return [buddy1.username caseInsensitiveCompare: buddy2.username];
        }];
    }
    return self;
}

-(id) initGroupInfo:(CHATROOM2 *) room2{
    _room2=room2;
    return self;
}

- (instancetype)initWithBlockSelectedUsernames:(NSArray *)blockUsernames
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _blockSelectedUsernames = [NSMutableArray array];
        [_blockSelectedUsernames addObjectsFromArray:blockUsernames];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_userDao==nil){
        _userDao=[[DDUserDAO alloc]init];
    }
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"title.chooseContact", @"select the contact");
    self.navigationItem.rightBarButtonItem = nil;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.footerView];
    self.tableView.editing = YES;
    self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height - self.footerView.frame.size.height);
    [self searchController];
    
    if ([_blockSelectedUsernames count] > 0) {
        for (NSString *username in _blockSelectedUsernames) {
            NSInteger section = [self sectionForString:username];
            NSMutableArray *tmpArray = [_dataSource objectAtIndex:section];
            if (tmpArray && [tmpArray count] > 0) {
          
                for (int i = 0; i < [tmpArray count]; i++) {
                    EMBuddy *buddy = [tmpArray objectAtIndex:i];
                    if ([buddy.username isEqualToString:username]) {
                        [self.selectedContacts addObject:buddy];
                      
                        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                        
                        break;
                    }
                }
            }
        }
        
        if ([_selectedContacts count] > 0) {
            [self reloadFooterView];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.editingStyle = UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak Contact4GroupAddViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ContactListCell";
            BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            DDUser *user=[self.userDao selectDDuserByUid:buddy.username];
            UIImageView *us=[[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.origin.x+5, cell.frame.origin.y+5, 40, 40)] ;
            [us sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:user.picPath]]
                  placeholderImage:[UIImage imageNamed:@"Logo_new"]];
            [cell.contentView addSubview:us];
            cell.textLabel.text = buddy.username;
            
            return cell;
        }];
        
        [_searchController setCanEditRowAtIndexPath:^BOOL(UITableView *tableView, NSIndexPath *indexPath) {
            if ([weakSelf.blockSelectedUsernames count] > 0) {
                EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
                return ![weakSelf isBlockUsername:buddy.username];
            }
            
            return YES;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 50;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            if (![weakSelf.selectedContacts containsObject:buddy])
            {
                NSInteger section = [weakSelf sectionForString:buddy.username];
                if (section >= 0) {
                    NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
                    NSInteger row = [tmpArray indexOfObject:buddy];
                    [weakSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                
                [weakSelf.selectedContacts addObject:buddy];
                [weakSelf reloadFooterView];
            }
        }];
        
        [_searchController setDidDeselectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            if ([weakSelf.selectedContacts containsObject:buddy]) {
                NSInteger section = [weakSelf sectionForString:buddy.username];
                if (section >= 0) {
                    NSMutableArray *tmpArray = [weakSelf.dataSource objectAtIndex:section];
                    NSInteger row = [tmpArray indexOfObject:buddy];
                    [weakSelf.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] animated:NO];
                }
                
                [weakSelf.selectedContacts removeObject:buddy];
                [weakSelf reloadFooterView];
            }
        }];
    }
    
    return _searchController;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _footerView.backgroundColor = [UIColor colorWithRed:207 / 255.0 green:210 /255.0 blue:213 / 255.0 alpha:0.7];
        
        _footerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 30 - 70, _footerView.frame.size.height - 5)];
        _footerScrollView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:_footerScrollView];
        
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(_footerView.frame.size.width - 80, 8, 70, _footerView.frame.size.height - 16)];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:10 / 255.0 green:82 / 255.0 blue:104 / 255.0 alpha:1.0]];
        [_doneButton setTitle:NSLocalizedString(@"accept", @"Accept") forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_doneButton setTitle:NSLocalizedString(@"ok", @"OK") forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_doneButton];
    }
    
    return _footerView;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ContactListCell";
    BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    DDUser *user=[_userDao selectDDuserByUid:buddy.username];
    UIImageView *us=[[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.origin.x+5, cell.frame.origin.y+5, 40, 40)] ;
    if(user!=nil&&user.picPath!=nil){
        [us sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:user.picPath]]
              placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    }else{
        us.image=[UIImage imageNamed:@"Logo_new"];
    }
    
    [cell.contentView addSubview:us];
    cell.textLabel.text = buddy.username;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if ([_blockSelectedUsernames count] > 0) {
        EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        return ![self isBlockUsername:buddy.username];
    }
    
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (![self.selectedContacts containsObject:object]) {
        [self.tableView deselectRowAtIndexPath:self.currentSelectIndexpath animated:YES];
        [self.selectedContacts removeLastObject];
        [self.selectedContacts addObject:object];
        self.currentSelectIndexpath = indexPath;
        [self reloadFooterView];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EMBuddy *buddy = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([self.selectedContacts containsObject:buddy]) {
        [self.selectedContacts removeObject:buddy];
        self.currentSelectIndexpath = nil;
        [self reloadFooterView];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar setCancelButtonTitle:NSLocalizedString(@"ok", @"OK")];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.contactsSource searchText:searchText collationStringSelector:@selector(username) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
                
                for (EMBuddy *buddy in results) {
                    if ([self.selectedContacts containsObject:buddy])
                    {
                        NSInteger row = [results indexOfObject:buddy];
                        [self.searchController.searchResultsTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.editing = YES;
}

#pragma mark - private

- (BOOL)isBlockUsername:(NSString *)username
{
    if (username && [username length] > 0) {
        if ([_blockSelectedUsernames count] > 0) {
            for (NSString *tmpName in _blockSelectedUsernames) {
                if ([username isEqualToString:tmpName]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

- (void)reloadFooterView
{
    [self.footerScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat imageSize = self.footerScrollView.frame.size.height;
    NSInteger count = [self.selectedContacts count];
    self.footerScrollView.contentSize = CGSizeMake(imageSize * count, imageSize);
    for (int i = 0; i < count; i++) {
        EMBuddy *buddy = [self.selectedContacts objectAtIndex:i];
        EMRemarkImageView *remarkView = [[EMRemarkImageView alloc] initWithFrame:CGRectMake(i * imageSize, 0, imageSize, imageSize)];
        
        DDUser *user=[_userDao selectDDuserByUid:buddy.username];
        [remarkView sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:user.picPath]]
              placeholderImage:[UIImage imageNamed:@"Logo_new"]];
     
        remarkView.remark = buddy.username;
        [self.footerScrollView addSubview:remarkView];
    }
    
    if ([self.selectedContacts count] == 0) {
        [_doneButton setTitle:NSLocalizedString(@"ok", @"OK") forState:UIControlStateNormal];
    }
    else{
        [_doneButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"doneWithCount", @"Done(%i)"), [self.selectedContacts count]] forState:UIControlStateNormal];
    }
}

#pragma mark - public

- (void)loadDataSource
{
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    [_dataSource removeAllObjects];
    [_contactsSource removeAllObjects];
    
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    for (EMBuddy *buddy in buddyList) {
        if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
            [self.contactsSource addObject:buddy];
        }
    }
    
    [_dataSource addObjectsFromArray:[self sortRecords:self.contactsSource]];
    
    [self hideHud];
    [self.tableView reloadData];
}

- (void)doneAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(creat4Groups)
                                                 name:@"create4Groups"
                                               object:nil];
    

    
    
    
        for (EMBuddy *buddy in _selectedContacts) {
            _toAddFriend=buddy.username;
        }
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        _username = [loginInfo objectForKey:kSDKUsername];
        //新建四人聊天室
        //1判断是否已经存在
        //2 加入环信
        //3 加入AWS
        //4 加入本地
    [self showHudInView:self.view hint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"create4Groups" object:@NO];

  

  
}

-(void) creat4Groups{
    CHATROOM4 *chatroom4=[CHATROOM4 new];
    //判断是否存在同样用户的群组
    ChatRoom4DAO *dao=[[ChatRoom4DAO alloc]init];
    chatroom4=[dao isUniqueRoom:_room2.UID1 UID2:_room2.UID2 UID3:_username UID4:_toAddFriend];
    if(chatroom4!=nil&&chatroom4.GID!=nil){
        //跳入原来的房间
        ChatViewController *chatController = [[[ChatViewController alloc] initWithChatter:chatroom4.GID isGroup:YES] initRoom4:chatroom4 friend:self.toAddFriend isNewRoom:NO];
        chatController.title = self.room2.Motto;
        [self.navigationController pushViewController:chatController animated:YES];

        return;
    }
   
    EMGroupStyleSetting *groupStyleSetting = [[EMGroupStyleSetting alloc] init];
    groupStyleSetting.groupStyle = eGroupStyle_PublicOpenJoin; // 创建不同类型的群组，这里需要才传入不同的类型
    [[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:_room2.RID
                                                          description:_room2.Motto
                                                             invitees:@[_username,_toAddFriend,_room2.UID1,_room2.UID2]
                                                initialWelcomeMessage:@"邀请您加入群组"
                                                         styleSetting:groupStyleSetting
                                                           completion:^(EMGroup *group, EMError *error) {
                                                               if(!error){
                                                                   chatroom4.GID=group.groupId;
                                                                   NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
                                                                   [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
                                                                   chatroom4.CTIMER=[formatter stringFromDate:[NSDate date]];
                                                                   chatroom4.CTIMEH=@"Time";
                                                                   chatroom4.RID=self.room2.RID;
                                                                   chatroom4.UID1=self.room2.UID1;
                                                                   chatroom4.UID2=self.room2.UID2;
                                                                   chatroom4.UID3=self.username;
                                                                   chatroom4.UID4=self.toAddFriend;
                                                                   chatroom4.isLikeUID1=[NSNumber numberWithInt:0];
                                                                   chatroom4.isLikeUID2=[NSNumber numberWithInt:0];
                                                                   chatroom4.isLikeUID3=[NSNumber numberWithInt:0];
                                                                   chatroom4.isLikeUID4=[NSNumber numberWithInt:0];
                                                                   chatroom4.roomStatus=@"New";
                                                                   chatroom4.systemTimeNumber=[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]*1000];
                                                                   AWSDynamoDB_ChatRoom4 *chatroom4DB=[AWSDynamoDB_ChatRoom4 alloc];
                                                                   [chatroom4DB insertChatroom4:chatroom4];
                                                                   ChatViewController *chatController = [[[ChatViewController alloc] initWithChatter:group.groupId isGroup:YES] initRoom4:chatroom4 friend:self.toAddFriend isNewRoom:YES ];
                                                                   chatController.title = self.room2.Motto;
                                                                   [self.navigationController pushViewController:chatController animated:YES];
                                                                   
                                                                   NSLog(@"创建成功 -- %@",group);
                                                               }        
                                                           } onQueue:nil];
    
    
   
    
}

@end
