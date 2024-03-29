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

#import "ApplyViewController.h"
#import "DebugViewController.h"
#import "WCAlertView.h"
#import "AliCloudController.h"
#import "Constants.h"
#import "ChatRoomDetail.h"
#import "ContactsViewController.h"
#import "Contact4GroupAddViewController.h"
#import "ContactSelectionViewController.h"
#import "IndexViewController.h"
#import "ChatRoom2DAO.h"
#import "UIImageView+EMWebCache.h"
#import "DDUserDAO.h"
#import "IndexViewController.h"
#import "AWSDynamoDB_DDUser.h"
#import "AWSDynamoDB_ChatRoom2.h"
#import "Util.h"
#import "PersonInfoController.h"
#import "CHATROOM4.h"
#import "AWSDynamoDB_ChatRoom4.h"
#import "DDDataManager.h"
#import "EMBuddy.h"
#import "ChatViewController.h"

@interface ChatRoomDetail () <EMChooseViewDelegate>
{
    EMGroup *_emgroup;
    EMBuddy *_embuddy;
    int _state;
}

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSMutableArray *datasouce;
@property (strong, nonatomic) AWSDynamoDB_DDUser *userDynamoDB;
@property (strong, nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property (strong, nonatomic) DDUser *uuser1;
@property (strong, nonatomic) DDUser *uuser2;
@property (strong, nonatomic) CHATROOM2 *chatroom2;
@property (strong, nonatomic) CHATROOM4 *chatroom4;


@end

@implementation ChatRoomDetail


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =_chatroom2.Motto;
    
    self.view.backgroundColor =[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    UIImageView *bak1=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-10, self.view.frame.size.height/2-80)];
    bak1.backgroundColor=[UIColor whiteColor];
    [bak1 setUserInteractionEnabled:YES];
    [bak1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getUser1DetailInfo)]];
    
    bak1.layer.masksToBounds =YES;
    bak1.layer.cornerRadius =5;
    [self.view addSubview:bak1];
    [self showUser1:bak1];
     UIImageView *bak2=[[UIImageView alloc]initWithFrame:CGRectMake(5, bak1.frame.origin.y+bak1.frame.size.height+5, self.view.frame.size.width-10, bak1.frame.size.height)];
    bak2.backgroundColor=[UIColor whiteColor];
    bak2.layer.masksToBounds =YES;
    bak2.layer.cornerRadius =5;
    [bak2 setUserInteractionEnabled:YES];
    [bak2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getUser2DetailInfo)]];
    [self showUser2:bak2];
    [self.view addSubview:bak2];
    
    //buton
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, bak2.frame.origin.y+bak2.frame.size.height+10, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"加入聊天室" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    
    //更新点击数
    [self updateClickNumber];
    _state = 0;
}

-(void) getUser1DetailInfo{
    PersonInfoController *personInfo=[[PersonInfoController alloc]initUser:_uuser1];
    [self.navigationController pushViewController:personInfo animated:YES];
}

-(void) getUser2DetailInfo{
    PersonInfoController *personInfo=[[PersonInfoController alloc]initUser:_uuser2];
    [self.navigationController pushViewController:personInfo animated:YES];
}


- (void)addUser {
	//判断性别
	if (_chatroom2 != nil && _uuser1 != nil && _uuser2 != nil) {
		if (_uuser1.gender != nil) {
			if (_uuser1.gender.intValue == [DDDataManager sharedManager].user.gender.intValue) {
				[WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
				                        message:NSLocalizedString(@"group.notSameSex", @"Please join in the other sex room")
				             customizationBlock:nil
				                completionBlock:nil
				              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
				              otherButtonTitles:nil];
				return;
			}
		} else {
			[WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
			                        message:@"加入房间异常，请选择其他房间"
			             customizationBlock:nil
			                completionBlock:nil
			              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
			              otherButtonTitles:nil];
			return;
		}
	}
    
    [self creat3Groups];
    
	Contact4GroupAddViewController *selectionController = [[Contact4GroupAddViewController alloc] init];
	selectionController.delegate = self;
	[self.navigationController pushViewController:selectionController animated:YES];
}

-(id) initChatRoom:(CHATROOM2 *) room  uuser1:(DDUser *) uuser1 uuser2:(DDUser *) uuser2{
    _chatroom2=room;
    //查询
    _uuser1=uuser1;
    
    _uuser2=uuser2;

    return self;
}

-(void) updateClickNumber{
     _chatroom2.ClickNum=[NSString stringWithFormat:@"%d",_chatroom2.ClickNum.intValue +  arc4random() % 100];
   
    AWSDynamoDB_ChatRoom2 *chatRoom2DynamoDB = [[AWSDynamoDB_ChatRoom2 alloc] init];
    [chatRoom2DynamoDB insertChatroom2:_chatroom2];

    [chatRoom2DynamoDB refreshListWithBlock:^(NSArray *chatRoom2s) {
        //TODO
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)showUser1:(UIImageView *) bakview{
    
    UIImageView *headview=[[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 100, 100)];
    
    [headview sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:_uuser1.picPath]]
                placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =50;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, headview.frame.origin.y+10, 120, 15)];
    nickname.text=_uuser1.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:nickname];
    //性别
    BOOL isboy=NO;
    if(_uuser1!=nil){
        if(_uuser1.gender.intValue == 0){
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
    isboyview.frame=CGRectMake(nickname.frame.origin.x+nickname.frame.size.width+2, headview.frame.origin.y, 20, 20);
    [bakview addSubview:isboyview];
    //chengshi
    UILabel *city=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, nickname.frame.origin.y+nickname.frame.size.height+8, 70, 12)];
    city.text=_uuser1.city;
    city.textAlignment=NSTextAlignmentLeft;
    city.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:city];
    //学校图片
//    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//    schoolview.frame=CGRectMake(city.frame.origin.x+city.frame.size.width+15, city.frame.origin.y, 20, 10);
//    [bakview addSubview:schoolview];
    //爱好
    UILabel *intr=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, city.frame.origin.y+city.frame.size.height+5, self.view.frame.size.width-120, 20)];
    intr.text=_uuser1.birthday;
    [intr setNumberOfLines:0];
    intr.textAlignment=NSTextAlignmentLeft;
    intr.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:intr];
    
    
    //qianming
    
    UIImage *signimg=[UIImage imageNamed:@"infoline"];
    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+20, bakview.frame.size.width-20, bakview.frame.size.height/2-10);
    
    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, signview.frame.size.width-20, 50)];
    sininfo.text=_uuser1.hobbies;
    sininfo.textAlignment=NSTextAlignmentLeft;
    [sininfo setNumberOfLines:0];
    //                    sininfo.lineBreakMode = UILineBreakModeWordWrap;
    sininfo.font=[UIFont fontWithName:@"Helvetica" size:14];
    [signview addSubview:sininfo];

    
    [bakview addSubview:signview];
    //
    

}

-(void)showUser2:(UIImageView *) bakview{
   
    UIImageView *headview=[[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 100, 100)];
    [headview sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:_uuser2.picPath]]
                placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =50;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, headview.frame.origin.y+10, 120, 15)];
    nickname.text=_uuser2.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:nickname];
    //性别
    BOOL isboy=NO;
    if(_uuser1!=nil){
        if(_uuser1.gender.intValue == 0){
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
    isboyview.frame=CGRectMake(headview.frame.origin.x+headview.frame.size.width+nickname.frame.size.width, headview.frame.origin.y, 20, 20);
    [bakview addSubview:isboyview];
    //city
    UILabel *city=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, nickname.frame.origin.y+nickname.frame.size.height+8, 70, 12)];
    city.text=_uuser2.city;
    city.textAlignment=NSTextAlignmentLeft;
    city.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:city];
//    //学校图片
//    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//    schoolview.frame=CGRectMake(city.frame.origin.x+city.frame.size.width+15, city.frame.origin.y, 20, 10);
//    [bakview addSubview:schoolview];
    //aihaoci
    UILabel *intr=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, city.frame.origin.y+city.frame.size.height+5, self.view.frame.size.width-120, 20)];
    intr.text=_uuser2.birthday;
    [intr setNumberOfLines:0];
    intr.textAlignment=NSTextAlignmentLeft;
    intr.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:intr];
    
    //qianming
    
    UIImage *signimg=[UIImage imageNamed:@"infoline"];
    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+20, bakview.frame.size.width-20, bakview.frame.size.height/2-10);
    
    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, signview.frame.size.width-20, 50)];
    sininfo.text=_uuser2.hobbies;
    sininfo.textAlignment=NSTextAlignmentLeft;
    [sininfo setNumberOfLines:0];
    //                    sininfo.lineBreakMode = UILineBreakModeWordWrap;
    sininfo.font=[UIFont fontWithName:@"Helvetica" size:14];
    [signview addSubview:sininfo];
    
    [bakview addSubview:signview];


    
}

- (void)creat3Groups {
	EMGroupStyleSetting *groupStyleSetting = [[EMGroupStyleSetting alloc] init];
	groupStyleSetting.groupStyle = eGroupStyle_PublicOpenJoin; // 创建不同类型的群组，这里需要才传入不同的类型
	[[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:self.chatroom2.RID
	                                                      description:self.chatroom2.Motto
	                                                         invitees:@[self.chatroom2.UID1, self.chatroom2.UID2]
	                                            initialWelcomeMessage:@"邀请您加入群组"
	                                                     styleSetting:groupStyleSetting
	                                                       completion: ^(EMGroup *group, EMError *error) {
	    if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                self->_emgroup = group;
                [self tryAddToGroup];
            });
		}
	} onQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark - EMChooseViewDelegate

- (void)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources {
	id obj = [selectedSources objectAtIndex:0];
	if ([obj isKindOfClass:[EMBuddy class]]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            self->_embuddy = (EMBuddy *)obj;
            [self tryAddToGroup];
        });
	}
}

- (void)tryAddToGroup {
	if (!_embuddy) {
		return;
	}
	if (!_emgroup) {
		return;
	}
	if (_state > 0) {
		return;
	}

	[self showHint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
	_state = 1;
	NSString *doublerId = _embuddy.username;
	EMError *error = nil;
	[[EaseMob sharedInstance].chatManager addOccupants:@[doublerId] toGroup:_emgroup.groupId welcomeMessage:@"邀请信息" error:&error];
	[self hideHud];

	if (!error) {
		[self showHint:NSLocalizedString(@"group.create.success", @"create group success")];

		self.chatroom4 = [CHATROOM4 new];
        self.chatroom4.GID = _emgroup.groupId;
		self.chatroom4.RID = self.chatroom2.RID;
		self.chatroom4.UID1 = self.chatroom2.UID1;
		self.chatroom4.UID2 = self.chatroom2.UID2;
		self.chatroom4.UID3 = [DDDataManager sharedManager].user.UID;
		self.chatroom4.UID4 = doublerId;

		self.chatroom4.isLikeUID1 = [NSNumber numberWithInt:0];
		self.chatroom4.isLikeUID2 = [NSNumber numberWithInt:0];
		self.chatroom4.isLikeUID3 = [NSNumber numberWithInt:0];
		self.chatroom4.isLikeUID4 = [NSNumber numberWithInt:0];

		self.chatroom4.roomStatus = @"New";
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyyMMdd_HHmmss"];
		self.chatroom4.CTIMER = [formatter stringFromDate:[NSDate date]];
		self.chatroom4.CTIMEH = @"Time";
		self.chatroom4.systemTimeNumber = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];


		AWSDynamoDB_ChatRoom4 *chatroom4DB = [[AWSDynamoDB_ChatRoom4 alloc]init];
		[chatroom4DB insertChatroom4:self.chatroom4];

		ChatViewController *chatController = [[[ChatViewController alloc] initWithChatter:_emgroup.groupId isGroup:YES isSubGroup:NO] initRoom4:self.chatroom4 friend:doublerId isNewRoom:YES];
		chatController.title = self.chatroom2.Motto;
		[self.navigationController pushViewController:chatController animated:YES];

		EMGroupStyleSetting *groupStyleSetting = [[EMGroupStyleSetting alloc] init];
		groupStyleSetting.groupStyle = eGroupStyle_PublicOpenJoin;
		[[EaseMob sharedInstance].chatManager asyncCreateGroupWithSubject:[Util str1:self->_emgroup.groupId appendStr2:@"_subID2"]
		                                                      description:@"加入四人聊天室的一对的私密群聊"
		                                                         invitees:@[doublerId]
		                                            initialWelcomeMessage:@"邀请您加入群组"
		                                                     styleSetting:groupStyleSetting
		                                                       completion: ^(EMGroup *group, EMError *error) {
		    self->_state = 2;
		    if (!error) {
		        self.chatroom4.subGID2 = group.groupId;
		        AWSDynamoDB_ChatRoom4 *chatroom4DB = [[AWSDynamoDB_ChatRoom4 alloc]init];
		        [chatroom4DB updateSubGroupTable:self.chatroom4];
			} else {
		        [self showHint:[NSString stringWithFormat:@"创建两人私密群聊失败, error: %@", error]];
			}
		} onQueue:dispatch_get_main_queue()];
        
        _embuddy = nil;
        _emgroup = nil;
        _state = 0;
	} else {
		[[EaseMob sharedInstance].chatManager asyncDestroyGroup:_emgroup.groupId completion: ^(EMGroup *group, EMGroupLeaveReason reason, EMError *error) {
		    if (error) {
		        NSLog(@"destroy three group %@ failed. error: %@", self->_emgroup.groupId, error);
			} else {
		        NSLog(@"destroy three group %@ success.", self->_emgroup.groupId);
			}
		} onQueue:nil];
        [self showHint:@"加入第四个人失败"];
        
        _embuddy = nil;
        _emgroup = nil;
        _state = 0;
	}
}

@end
