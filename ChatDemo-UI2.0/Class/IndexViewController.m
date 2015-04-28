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
#import "EGOImageView.h"
#import <sqlite3.h>
#import "LocalDbService.h"


@interface IndexViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;
@property(strong,nonatomic) DDBDynamoDB *ddbDynamoDB;
@property(strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;

@property(strong,nonatomic) NSString *database_path;
@property(strong,nonatomic) NSArray *path;
@property(nonatomic) LocalDbService *localDbService;


@end
static DDUser   *uuser;



@implementation IndexViewController


@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;

#define kIMGCOUNT 5
+(DDUser *) instanceDDuser{
    return uuser;
}
-(void) setDDUser:(DDUser *) user{
    uuser=user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"个人主页";
    self.view.backgroundColor = [UIColor redColor];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
    _localDbService=[LocalDbService alloc];
    [_localDbService openDB];
    
    //chaxun
    _localDbService.refreshList;
    [self initdduser];
    
    
    
}

-(void)initdduser{
    if(uuser==nil){
        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        
        //同步方法
        _dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        BFTask *bftask= [_dynamoDBObjectMapper load:[DDUser class] hashKey:username rangeKey:nil];
        bftask.waitUntilFinished;
        uuser= bftask.result;
        
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (UISwitch *)beInvitedSwitch
{
    //    if (_beInvitedSwitch == nil) {
    //        _beInvitedSwitch = [[UISwitch alloc] init];
    //        [_beInvitedSwitch addTarget:self action:@selector(beInvitedChanged:) forControlEvents:UIControlEventValueChanged];
    //        BOOL autoAccept = [[EaseMob sharedInstance].chatManager autoAcceptGroupInvitation];
    //        [_beInvitedSwitch setOn:!autoAccept animated:YES];
    //    }
    
    return _beInvitedSwitch;
}

- (UILabel *)beInvitedLabel
{
    if (_beInvitedLabel == nil) {
        _beInvitedLabel = [[UILabel alloc] init];
        _beInvitedLabel.backgroundColor = [UIColor clearColor];
        _beInvitedLabel.font = [UIFont systemFontOfSize:12.0];
        _beInvitedLabel.textColor = [UIColor grayColor];
    }
    
    return _beInvitedLabel;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return LocalDbService.getChatRoom.count;
}

//每行缩进
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0) {
        return 10;
    }
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        for (NSUInteger i = 0; i < LocalDbService.getChatRoom.count; i++) {
            if (indexPath.row == i) {
                CHATROOM2 *root=[[LocalDbService.getChatRoom objectAtIndex:i] copy];
            
                
                EGOImageView *bakview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(root!=nil && root.PicturePath !=nil){
                    bakview.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:root.PicturePath]];
                }
                bakview.frame = CGRectMake(5, 5, cell.frame.size.width-10, 150);
                bakview.layer.masksToBounds =YES;
                bakview.layer.cornerRadius =25;
                [cell.contentView addSubview:bakview];

                //渐变
                UIImage *background=[UIImage imageNamed:@"jianbian"];
                UIImageView *bakgroundview=[[UIImageView alloc] initWithImage:background];
                bakgroundview.frame=CGRectMake(5, 5, cell.frame.size.width-10, 150);
                bakgroundview.layer.masksToBounds =YES;
                bakgroundview.layer.cornerRadius =25;
                [cell.contentView addSubview:bakgroundview];
                //查询用户
                
                DDUser *uuser1= [_localDbService selectDDuserByUid:root.UID1];
                //显示用户1
                EGOImageView *user1 = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(uuser1!=nil && uuser1.picPath !=nil){
                    user1.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:uuser1.picPath]];
                }
                user1.frame=CGRectMake(10, bakview.frame.origin.y+5, 50, 50);
                user1.layer.masksToBounds =YES;
                user1.layer.cornerRadius =25;
                [bakview addSubview:user1];
                //显示用户2
          
                DDUser *uuser2= [_localDbService selectDDuserByUid:root.UID2];;
                //显示用户1
               
                EGOImageView *user2 = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
                if(uuser2!=nil && uuser2.picPath !=nil){
                    user2.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:uuser2.picPath]];
                }
                user2.frame=CGRectMake(bakview.frame.size.width-60, bakview.frame.origin.y+5, 50, 50);
                user2.layer.masksToBounds =YES;
                user2.layer.cornerRadius =25;
                [bakview addSubview:user2];
                
                //性别
                BOOL *isboy=NO;
                if(user1!=nil){
                    if(uuser1.gender==@"Male" || uuser1.gender==@"男"){
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
                isboyview.frame=CGRectMake(bakview.frame.size.width-40, bakview.frame.origin.y+80, 20, 20);
                [bakview addSubview:isboyview];
                //点击数
                UIImage *clicknumber2=[UIImage imageNamed:@"clicknum2"];
                
                UIImageView *clicknumber2view=[[UIImageView alloc] initWithImage:clicknumber2];
                clicknumber2view.frame=CGRectMake(bakview.frame.size.width-60, bakview.frame.origin.y+110, 56, 25);
                [bakview addSubview:clicknumber2view];
                
                UIImage *clicknumber1=[UIImage imageNamed:@"clicknum1"];
                UIImageView *clicknumber1view=[[UIImageView alloc] initWithImage:clicknumber1];
                clicknumber1view.frame=CGRectMake(5, 5, 12, 12);
                [clicknumber2view addSubview:clicknumber1view];
                
                UILabel *click=[[UILabel alloc]initWithFrame:CGRectMake(19, 2, 30, 20)];
                click.text=root.ClickNum;
                click.textAlignment=NSTextAlignmentCenter;
                click.font=[UIFont fontWithName:@"Helvetica" size:11];
                click.textColor=[UIColor whiteColor];
                [clicknumber2view addSubview:click];
                
                //添加宣言
                UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(0, bakview.frame.origin.y+110, 100, 30)];
                mylable.text=root.Motto;
                mylable.textAlignment=NSTextAlignmentCenter;
                mylable.font=[UIFont fontWithName:@"Helvetica" size:14];
                mylable.textColor=[UIColor whiteColor];
                [bakview addSubview:mylable];
                
            }
        }
        
        
    }
    
    return cell;
}



- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 160;
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        for (NSUInteger i = 0; i < LocalDbService.getChatRoom.count; i++) {
            if (indexPath.row == i) {
                CHATROOM2 *room=[[LocalDbService.getChatRoom objectAtIndex:i] copy];
                
                ChatRoomDetail *chatroom=[[ChatRoomDetail alloc]initChatRoom:[_localDbService selectDDuserByUid:room.UID1] uuser2:[_localDbService selectDDuserByUid:room.UID2] motto:room.Motto];
                [self.navigationController pushViewController:chatroom animated:YES];
            }
        }
    }

}

#pragma mark - getter

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        }
    
    return _footerView;
}

#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch
{
    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:autoSwitch.isOn];
}

- (void)useIpChanged:(UISwitch *)ipSwitch
{
    [[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
}

- (void)beInvitedChanged:(UISwitch *)beInvitedSwitch
{
    //    if (beInvitedSwitch.isOn) {
    //        self.beInvitedLabel.text = @"允许选择";
    //    }
    //    else{
    //        self.beInvitedLabel.text = @"自动加入";
    //    }
    //
    //    [[EaseMob sharedInstance].chatManager setAutoAcceptGroupInvitation:!(beInvitedSwitch.isOn)];
}


- (void)refreshConfig
{
    [self.autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled] animated:YES];
    [self.ipSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];
    
    [self.tableView reloadData];
}

- (void)logoutAction
{
    __weak NewSettingViewController *weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [weakSelf hideHud];
        if (error && error.errorCode != EMErrorServerNotLogin) {
            [weakSelf showHint:error.description];
        }
        else{
            [[ApplyViewController shareController] clear];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    } onQueue:nil];
}

@end
