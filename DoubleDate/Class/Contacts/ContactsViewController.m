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

#import "ContactsViewController.h"

#import "BaseTableViewCell.h"
#import "RealtimeSearchUtil.h"
#import "ChineseToPinyin.h"
#import "EMSearchBar.h"
#import "SRRefreshView.h"
#import "EMSearchDisplayController.h"
#import "AddFriendViewController.h"
#import "ApplyViewController.h"
#import "GroupListViewController.h"
#import "ChatViewController.h"
#import "InviteFriendByDoubleIdController.h"
#import "DDUserDAO.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "Util.h"
#import "IndexViewController.h"

@interface ContactsViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, BaseTableCellDelegate, SRRefreshDelegate>
{
    NSIndexPath *_currentLongPressIndex;
}

@property (strong, nonatomic) NSMutableArray *contactsSource;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *sectionTitles;

@property (strong, nonatomic) UILabel *unapplyCountLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) GroupListViewController *groupController;

@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong, nonatomic) DDUserDAO *userDao;

@property(strong,nonatomic) UIView *bak;
@property(strong,nonatomic) UIButton *img1;
@property(strong,nonatomic) UIButton *img2;

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _contactsSource = [NSMutableArray array];
        _sectionTitles = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self searchController];
    self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.view addSubview:self.searchBar];
    
    self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height);
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    if(_userDao==nil){
        _userDao=[[DDUserDAO alloc]init];
    }
    //更新好友列表 或有列表读取 方式待修改
//    [self initFriendUser];
}
//注意则个方法不能用在Index页面
//初始化好友列表
//查询环信列表
//更新本地库
//-(void) initFriendUser{
//    if(_userDao==nil){
//        _userDao=[DDUserDAO alloc];
//    }
//    if(self.dataSource&&self.dataSource.count>0){
//        for(EMBuddy *buddy in self.dataSource){
////            if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
//                [[self userDao] getTableRowAndInsertLocal:buddy.username];
////            }
//        }
//    }
//    
//    
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadApplyView];
}

#pragma mark - getter

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (UILabel *)unapplyCountLabel
{
    if (_unapplyCountLabel == nil) {
        _unapplyCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, 5, 20, 20)];
        _unapplyCountLabel.textAlignment = NSTextAlignmentCenter;
        _unapplyCountLabel.font = [UIFont systemFontOfSize:11];
        _unapplyCountLabel.backgroundColor = [UIColor redColor];
        _unapplyCountLabel.textColor = [UIColor whiteColor];
        _unapplyCountLabel.layer.cornerRadius = _unapplyCountLabel.frame.size.height / 2;
        _unapplyCountLabel.hidden = YES;
        _unapplyCountLabel.clipsToBounds = YES;
    }
    
    return _unapplyCountLabel;
}

- (SRRefreshView *)slimeView
{
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

- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    
    return _tableView;
}


- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak ContactsViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ContactListCell";
            BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            //查询用户头像
            DDUser *user=[[self userDao] selectDDuserByUid:buddy.username];
            UIImageView *us=[[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.origin.x+5, cell.frame.origin.y+5, 40, 40)] ;
            [us sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:user.picPath]]
                  placeholderImage:[UIImage imageNamed:@"Logo_new"]];
            [cell.contentView addSubview:us];

//            cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
            cell.textLabel.text = buddy.username;
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 50;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            EMBuddy *buddy = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
            NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
            if (loginUsername && loginUsername.length > 0) {
                if ([loginUsername isEqualToString:buddy.username]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    return;
                }
            }
            
            [weakSelf.searchController.searchBar endEditing:YES];
            ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:buddy.username isGroup:NO isSubGroup:NO];
            chatVC.title = buddy.username;
            [weakSelf.navigationController pushViewController:chatVC animated:YES];
        }];
    }
    
    return _searchController;
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataSource count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 2;
//        return 1;
    }
    NSMutableArray *sou=[self.dataSource objectAtIndex:(section - 1) ];
    
    return sou.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BaseTableViewCell *cell;

	if (indexPath.section == 0 && indexPath.row == 0) {
		cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
		if (cell == nil) {
			cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
		}

		cell.imageView.image = [UIImage imageNamed:@"newFriends"];
		cell.textLabel.text = NSLocalizedString(@"title.apply", @"Application and notification");
		[cell addSubview:self.unapplyCountLabel];
	} else {
		static NSString *CellIdentifier = @"ContactListCell";
		cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		// Configure the cell...
		if (cell == nil) {
			cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.delegate = self;
		}

		cell.indexPath = indexPath;

		if (indexPath.section == 0 && indexPath.row == 1) {
			cell.imageView.image = [UIImage imageNamed:@"groupPrivateHeader"];
			cell.textLabel.text = NSLocalizedString(@"title.group", @"Group");
		} else {
			EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
            AWSDynamoDB_DDUser *userDynamoDB = [[AWSDynamoDB_DDUser alloc] init];
			[userDynamoDB getDDuserAndInsertLocal:buddy.username];
			DDUser *user = [_userDao selectDDuserByUid:buddy.username];
			UIImageView *us = [[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.origin.x + 5, cell.frame.origin.y + 5, 40, 40)];
            if([user.UID isEqualToString:[IndexViewController instanceDDuser].UID]){
                [us sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:[IndexViewController instanceDDuser].picPath]]
                      placeholderImage:[UIImage imageNamed:@"Logo_new"]];

            }else{
                [us sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user.picPath]]
                      placeholderImage:[UIImage imageNamed:@"Logo_new"]];

            }
            [cell.contentView addSubview:us];

			cell.textLabel.text = buddy.username;
		}
	}

	return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
        [self isViewLoaded];
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        if ([buddy.username isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notDeleteSelf", @"can't delete self") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        EMError *error = nil;
        [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:&error];
        if (!error) {
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:buddy.username deleteMessages:YES append2Chat:YES];
            
            [tableView beginUpdates];
            [[self.dataSource objectAtIndex:(indexPath.section - 1)] removeObjectAtIndex:indexPath.row];
            [self.contactsSource removeObject:buddy];
            [tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView  endUpdates];
        }
        else{
            [self showHint:[NSString stringWithFormat:@"删除失败：%@", error.description]];
            [tableView reloadData];
        }
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return 0;
    }
     NSMutableArray *sou=[self.dataSource objectAtIndex:(section - 1) ];
    if (section == 0 || [sou count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     NSMutableArray *sou=[self.dataSource objectAtIndex:(section - 1) ];
    if (section == 0 || [sou count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [self.sectionTitles count]; i++) {
         NSMutableArray *sou=[self.dataSource objectAtIndex:i];
        if ([sou count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];
        }
        else if (indexPath.row == 1)
        {
            if (_groupController == nil) {
                _groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
            }
            else{
                [_groupController reloadDataSource];
            }
            [self.navigationController pushViewController:_groupController animated:YES];
        }
    }
    else{
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        if (loginUsername && loginUsername.length > 0) {
            if ([loginUsername isEqualToString:buddy.username]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
                
                return;
            }
        }
        
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:buddy.username isGroup:NO isSubGroup:NO];
        chatVC.title = buddy.username;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.contactsSource searchText:(NSString *)searchText collationStringSelector:@selector(username) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex && _currentLongPressIndex) {
        EMBuddy *buddy = [[self.dataSource objectAtIndex:(_currentLongPressIndex.section - 1)] objectAtIndex:_currentLongPressIndex.row];
        [self.tableView beginUpdates];
        [[self.dataSource objectAtIndex:(_currentLongPressIndex.section - 1)] removeObjectAtIndex:_currentLongPressIndex.row];
        [self.contactsSource removeObject:buddy];
        [self.tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:_currentLongPressIndex] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView  endUpdates];
        
        [[EaseMob sharedInstance].chatManager blockBuddy:buddy.username relationship:eRelationshipBoth];
    }
    
    _currentLongPressIndex = nil;
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    __weak ContactsViewController *weakSelf = self;
    [[[EaseMob sharedInstance] chatManager] asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        [weakSelf.slimeView endRefresh];
    } onQueue:nil];
    //更新本地库
    //更新好友列表
//    [self initFriendUser];
}

#pragma mark - BaseTableCellDelegate

- (void)cellImageViewLongPressAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        // 群组
        return;
    }
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    EMBuddy *buddy = [[self.dataSource objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
    if ([buddy.username isEqualToString:loginUsername])
    {
        return;
    }
    
    _currentLongPressIndex = indexPath;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"friend.block", @"join the blacklist") otherButtonTitles:nil, nil];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - private

- (NSMutableArray *)sortDataArray:(NSArray *)dataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [self.sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (EMBuddy *buddy in dataArray) {
        //getUserName是实现中文拼音检索的核心，见NameIndex类
        NSString *firstLetter = [ChineseToPinyin pinyinFromChineseString:buddy.username];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:buddy];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EMBuddy *obj1, EMBuddy *obj2) {
            NSString *firstLetter1 = [ChineseToPinyin pinyinFromChineseString:obj1.username];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [ChineseToPinyin pinyinFromChineseString:obj2.username];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}

#pragma mark - dataSource

- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    [self.contactsSource removeAllObjects];
    
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    for (EMBuddy *buddy in buddyList) {
        if (buddy.followState != eEMBuddyFollowState_NotFollowed) {
            [self.contactsSource addObject:buddy];
        }
    }
    
    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
    if (loginUsername && loginUsername.length > 0) {
        EMBuddy *loginBuddy = [EMBuddy buddyWithUsername:loginUsername];
        [self.contactsSource addObject:loginBuddy];
    }
    
    [self.dataSource addObjectsFromArray:[self sortDataArray:self.contactsSource]];
    
    [_tableView reloadData];
}

#pragma mark - action

- (void)reloadApplyView
{
    NSInteger count = [[[ApplyViewController shareController] dataSource] count];
    
    if (count == 0) {
        self.unapplyCountLabel.hidden = YES;
    }
    else
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%i", (int)count];
        CGSize size = [tmpStr sizeWithFont:self.unapplyCountLabel.font constrainedToSize:CGSizeMake(50, 20) lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect = self.unapplyCountLabel.frame;
        rect.size.width = size.width > 20 ? size.width : 20;
        self.unapplyCountLabel.text = tmpStr;
        self.unapplyCountLabel.frame = rect;
        self.unapplyCountLabel.hidden = NO;
    }
}

- (void)reloadGroupView
{
    [self reloadApplyView];
    
    if (_groupController) {
        [_groupController reloadDataSource];
    }
}



@end
