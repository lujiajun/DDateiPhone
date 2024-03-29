//
//  MainChatListViewController.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/28.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "MainChatListViewController.h"
#import "SRRefreshView.h"
#import "EMSearchBar.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "ChatListViewController.h"
#import "ChatRoom4ListCell.h"
#import "UIImageView+WebCache.h"
#import "DDUserDAO.h"
#import "Constants.h"
#import "ChatRoom4DAO.h"
#import "Util.h"
#import "AWSDynamoDB_ChatRoom4.h"
#import "SVProgressHUD.h"


@interface MainChatListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, SRRefreshDelegate, UISearchBarDelegate>
{
    UILabel *_unreadLabel;
    BOOL _loading;
}
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) DDUserDAO *ddUserDao;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableHeaderView;

@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UIView *networkStateView;
@property (strong, nonatomic) AWSDynamoDB_ChatRoom4 *chatRoom4DynamoDB;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation MainChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
        _ddUserDao = [[DDUserDAO alloc] init];
        _chatRoom4DynamoDB = [[AWSDynamoDB_ChatRoom4 alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removeEmptyConversationsFromDB];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self networkStateView];
    
    [self searchController];
    //初始化聊天室信息到本地数据库
    [self refreshDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerNotifications];
    if (_loading) {
        [SVProgressHUD show];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)removeEmptyConversationsFromDB {
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

#pragma mark - getter

- (SRRefreshView *)slimeView {
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height)];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _tableView;
}

- (UIView *)tableHeaderView {
	if (_tableHeaderView == nil) {
		_tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.bounds), 50)];
		UIImageView *head = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
		head.image = [UIImage imageNamed:@"Hi"];
		[_tableHeaderView addSubview:head];
		UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(60, 12, 200, 30)];
		name.text = @"两人窃窃私语";
		[_tableHeaderView addSubview:name];

		_unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 20, 20)];
		_unreadLabel.backgroundColor = [UIColor redColor];
		_unreadLabel.textColor = [UIColor whiteColor];

		_unreadLabel.textAlignment = NSTextAlignmentCenter;
		_unreadLabel.font = [UIFont systemFontOfSize:11];
		_unreadLabel.layer.cornerRadius = 10;
		_unreadLabel.clipsToBounds = YES;
		[_tableHeaderView addSubview:_unreadLabel];
		[_unreadLabel setHidden:YES];
	}

	return _tableHeaderView;
}

- (EMSearchDisplayController *)searchController {
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak MainChatListViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion: ^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"chatRoom4ListCell";
            ChatRoom4ListCell *cell = (ChatRoom4ListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[ChatRoom4ListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            cell.timeLabel.text = [weakSelf lastMessageTimeByConversation:conversation];
            cell.unreadCount = conversation.unreadMessagesCount;
            if (indexPath.row % 2 == 1) {
                cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
            } else {
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion: ^CGFloat (UITableView *tableView, NSIndexPath *indexPath) {
            return [ChatRoom4ListCell tableView:tableView heightForRowAtIndexPath:indexPath];
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion: ^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            EMConversation *conversation = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:conversation.chatter isGroup:conversation.isGroup isSubGroup:NO];
            chatVC.title = conversation.chatter;
            [weakSelf.navigationController pushViewController:chatVC animated:YES];
        }];
    }
    
    return _searchController;
}

- (UIView *)networkStateView {
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - private

// 得到最后消息时间
- (NSString *)lastMessageTimeByConversation:(EMConversation *)conversation {
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到最后消息文字或者类型
- (NSString *)subTitleMessageByConversation:(EMConversation *)conversation {
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id <IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image: {
                ret = NSLocalizedString(@"message.image1", @"[image]");
            } break;
                
            case eMessageBodyType_Text: {
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
                
            case eMessageBodyType_Voice: {
                ret = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
                
            case eMessageBodyType_Location: {
                ret = NSLocalizedString(@"message.location1", @"[location]");
            } break;
                
            case eMessageBodyType_Video: {
                ret = NSLocalizedString(@"message.vidio1", @"[vidio]");
            } break;
                
            default: {
            } break;
        }
    }
    
    return ret;
}

#pragma mark - TableViewDelegate & TableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.contentView addSubview: [self tableHeaderView]];
        return cell;
    }
    
    static NSString *identify = @"chatRoom4ListCell";
    ChatRoom4ListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ChatRoom4ListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    CHATROOM4 *chatRoom4 = [self.dataSource objectAtIndex:indexPath.row];
    
    EMConversation *conversion= [[EaseMob sharedInstance].chatManager conversationForChatter:chatRoom4.GID isGroup:YES];
    //用户1
    DDUser *user1 = [self.ddUserDao selectDDuserByUid:chatRoom4.UID1];
    [cell.user1Avatar sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user1.picPath]]
                        placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    cell.user1Name.text = user1.nickName;
    
    //用户2
    DDUser *user2 = [self.ddUserDao selectDDuserByUid:chatRoom4.UID2];
    [cell.user2Avatar sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user2.picPath]]
                        placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    cell.user2Name.text = user2.nickName;
    
    //用户3
    DDUser *user3 = [self.ddUserDao selectDDuserByUid:chatRoom4.UID3];
    [cell.user3Avatar sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user3.picPath]]
                        placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    cell.user3Name.text = user3.nickName;
    
    //用户4
    DDUser *user4 = [self.ddUserDao selectDDuserByUid:chatRoom4.UID4];
    [cell.user4Avatar sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user4.picPath]]
                        placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    cell.user4Name.text = user4.nickName;
    //时间
    NSUInteger  unread=conversion.unreadMessagesCount;
    if(unread>0){
        if (unread < 9) {
            cell.unreadMessage.font = [UIFont systemFontOfSize:13];
        } else if (unread > 9 && unread < 99) {
            cell.unreadMessage.font = [UIFont systemFontOfSize:12];
        } else {
            cell.unreadMessage.font = [UIFont systemFontOfSize:10];
        }
        cell.unreadMessage.text=[NSString stringWithFormat:@"%ld", (long)unread];
        
        [cell addSubview:cell.unreadMessage];
        
    }
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [inputFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSDate* inputDate = [inputFormatter dateFromString:chatRoom4.CTIMER];
    //        NSLog(@"date = %@", inputDate);
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setLocale:[NSLocale currentLocale]];
    [outputFormatter setDateFormat:@"yyyy年MM月dd日 HH时mm分ss秒"];
    
    cell.timeLabel.text = [outputFormatter stringFromDate:inputDate];
    
    if (indexPath.row % 2 == 1) {
        cell.contentView.backgroundColor = RGBACOLOR(246, 246, 246, 1);
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50;
    }
    return [ChatRoom4ListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ChatListViewController *root2ListVC = [[ChatListViewController alloc] init];
        [self.navigationController pushViewController:root2ListVC animated:YES];
    } else if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        CHATROOM4 *chatRoom4 = [self.dataSource objectAtIndex:indexPath.row];
        //        - (EMGroup *)fetchGroupInfo:(NSString *)groupId error:(EMError **)pError;
        ChatViewController *chatController = [[[ChatViewController alloc] initWithChatter:chatRoom4.GID isGroup:YES isSubGroup:NO] initRoom4:chatRoom4 friend:nil isNewRoom:NO];
        //		chatController.title = chatRoom;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 22;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    }
    
    return @"我的群组";
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(chatter) resultBlock: ^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.searchController.resultsSource removeAllObjects];
                [self.searchController.resultsSource addObjectsFromArray:results];
                [self.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView {
    [self refreshDataSource];
    [_slimeView endRefresh];
}

#pragma mark - IChatMangerDelegate

- (void)didUnreadMessagesCountChanged {
    if (! _unreadLabel) return;
    NSArray* conversations = [[EaseMob sharedInstance].chatManager conversations];
    __block int unreadCnt = 0;
    [conversations enumerateObjectsUsingBlock: ^(EMConversation* c, NSUInteger idx, BOOL *stop) {
        if ([c isGroup]) {
            return;
        }
        unreadCnt += c.unreadMessagesCount;
    }];
    dispatch_async(dispatch_get_main_queue(), ^(){
        self->_unreadLabel.text = [NSString stringWithFormat:@"%d", unreadCnt];
        self->_unreadLabel.hidden = (unreadCnt == 0);
    });
}

#pragma mark - registerNotifications
- (void)registerNotifications {
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self
                                        delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)unregisterNotifications {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc {
    [self unregisterNotifications];
}

#pragma mark - public

- (void)refreshDataSource {
	_loading = YES;
	if ([self isBeingPresented]) {
		[SVProgressHUD show];
	}

	[[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion: ^(NSArray *groups, EMError *error) {
	    if (!error) {
	        NSMutableArray *rooms = [[NSMutableArray alloc] init];
	        for (EMGroup *group in groups) {
	            CHATROOM4 *room = [self.chatRoom4DynamoDB syncGetChatroom4AndInsertLocal:group.groupId];
	            if (room.GID) {
	                [rooms addObject:room];
				}
			}
	        NSArray *sortedArray = [rooms sortedArrayUsingComparator:
	                                ^(CHATROOM4 *obj1, CHATROOM4 *obj2) {
	            return [obj2.systemTimeNumber compare:obj1.systemTimeNumber];
			}];

	        dispatch_async(dispatch_get_main_queue(), ^() {
				self->_loading = NO;
				[SVProgressHUD dismiss];
				[self.dataSource removeAllObjects];
				for (CHATROOM4 *room in sortedArray) {
				    if ([room hasTimeout]) {
				        continue;
					}
				    [self.dataSource addObject:room];
				}
				[self->_tableView reloadData];
			});
		}
	} onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}


- (void)isConnect:(BOOL)isConnect {
    if (!isConnect) {
        _tableView.tableHeaderView = _networkStateView;
    } else {
        _tableView.tableHeaderView = nil;
    }
}

- (void)networkChanged:(EMConnectionState)connectionState {
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    } else {
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages {
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages {
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
    [self refreshDataSource];
}

@end
