//
//  PushNotificationViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-7-21.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "PersonalController.h"
#include "UsernickController.h"
#import "NewSettingViewController.h"
#import "AliCloudController.h"
#import "DDBDynamoDB.h"
#import "Constants.h"
#import "NickNameController.h"



@interface PersonalController ()
{
    EMPushNotificationDisplayStyle _pushDisplayStyle;
    EMPushNotificationNoDisturbStatus _noDisturbingStatus;
    NSInteger _noDisturbingStart;
    NSInteger _noDisturbingEnd;
    NSString *_nickName;
}

@property (strong, nonatomic) UISwitch *pushDisplaySwitch;
@property (strong,nonatomic)  NSString *username;


@end

@implementation PersonalController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _noDisturbingStart = -1;
        _noDisturbingEnd = -1;
        _noDisturbingStatus = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.personal", @"Personal Info");
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [saveButton setTitle:NSLocalizedString(@"save", @"Save") forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(savePushOptions) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
     _username = [loginInfo objectForKey:kSDKUsername];
    //查询
    DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
    [ddbDynamoDB addNewUser:_username];
    
    [self refreshPushOptions];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISwitch *)pushDisplaySwitch
{
    if (_pushDisplaySwitch == nil) {
        _pushDisplaySwitch = [[UISwitch alloc] init];
        [_pushDisplaySwitch addTarget:self action:@selector(pushDisplayChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _pushDisplaySwitch;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 5;
    }
    else if (section == 1)
    {
        return 3;
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"setting.notDisturb", @"No disturbing");
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"头像";
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"80.png"];
            imageView.frame = CGRectMake(self.tableView.frame.size.width - self.pushDisplaySwitch.frame.size.width - 10, (cell.contentView.frame.size.height - self.pushDisplaySwitch.frame.size.height) / 2, self.pushDisplaySwitch.frame.size.width, self.pushDisplaySwitch.frame.size.height);
            [cell.contentView addSubview:imageView];
            
           
        }else if(indexPath.row==1){
        
            cell.textLabel.text = @"姓名";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if(indexPath.row==2){
            cell.textLabel.text = @"签名";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if(indexPath.row==3){
            cell.textLabel.text = @"学校";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if(indexPath.row==4){
            cell.textLabel.text = @"爱好";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.open", @"Open");
            cell.accessoryType = _noDisturbingStatus == ePushNotificationNoDisturbStatusDay ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"setting.nightOpen", @"only open at night (22:00 - 7:00)");
            cell.accessoryType = _noDisturbingStatus == ePushNotificationNoDisturbStatusCustom ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"setting.close", @"Close");
            cell.accessoryType = _noDisturbingStatus == ePushNotificationNoDisturbStatusClose ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 40;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL needReload = YES;
    if(indexPath.section==0){
        switch (indexPath.row) {
            case 0:{
                //[addPic addTarget:self action:@selector(btnClick) forControlEvents:(UIControlEventTouchUpInside)];// 按钮事件
                NewSettingViewController *newSetting=[NewSettingViewController alloc];
                [self btnClick];
            }break;
            case 1:
//                {UsernickController *UsernickController
            {
                NickNameController *pushController = [NickNameController alloc] ;
                [self.navigationController pushViewController:pushController animated:YES];

            }
                break;
                
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                needReload = NO;
                [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                        message:NSLocalizedString(@"setting.sureNotDisturb", @"this setting will cause all day in the don't disturb mode, will no longer receive push messages. Whether or not to continue?")
                             customizationBlock:^(WCAlertView *alertView) {
                             } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                 switch (buttonIndex) {
                                     case 0: {
                                     } break;
                                     default: {
                                         self->_noDisturbingStart = 0;
                                         self->_noDisturbingEnd = 24;
                                         self->_noDisturbingStatus = ePushNotificationNoDisturbStatusDay;
                                         [tableView reloadData];
                                     } break;
                                 }
                             } cancelButtonTitle:NSLocalizedString(@"no", @"NO") otherButtonTitles:NSLocalizedString(@"yes", @"YES"), nil];
            } break;
            case 1:
            {
                _noDisturbingStart = 22;
                _noDisturbingEnd = 7;
                _noDisturbingStatus = ePushNotificationNoDisturbStatusCustom;
            }
                break;
            case 2:
            {
                _noDisturbingStart = -1;
                _noDisturbingEnd = -1;
                _noDisturbingStatus = ePushNotificationNoDisturbStatusClose;
            }
                break;
                
            default:
                break;
        }
        
        if (needReload) {
            [tableView reloadData];
        }
    }
}


-(void) btnClick{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地相簿",nil];
    [actionSheet showInView:self.view];
    //    [actionSheet release];
}

#pragma mark -
#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex = [%d]",buttonIndex);
    switch (buttonIndex) {
        case 0://照相机
        {                 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            [self presentModalViewController:imagePicker animated:YES];
            //            [imagePicker release];
        }
            break;
        case 1://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            [self presentModalViewController:imagePicker animated:YES];
            //            [imagePicker release];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma UIImagePickerController Delegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        AliCloudController *aliCloud=[AliCloudController alloc];
       
        NSString *name= [aliCloud uploadPic:data];
        //xiugai头像
        DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
        DDUser *dduser=  [ddbDynamoDB getTableUser:_username];
        if(dduser==nil){
            dduser=[DDUser new];
            dduser.UID=_username;
            dduser.picPath=[DDPicPath stringByAppendingString:name];
            [ddbDynamoDB insertTableRow:dduser];
        }else{
            dduser.picPath=[DDPicPath stringByAppendingString:name];
            [ddbDynamoDB updateTable:dduser];
        }

    
    }
    
}

#pragma mark - action

- (void)savePushOptions
{
    BOOL isUpdate = NO;
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    if (_pushDisplayStyle != options.displayStyle) {
        options.displayStyle = _pushDisplayStyle;
        isUpdate = YES;
    }
    
    if (_nickName && _nickName.length > 0 && ![_nickName isEqualToString:options.nickname])
    {
        options.nickname = _nickName;
        isUpdate = YES;
    }
    if (options.noDisturbingStartH != _noDisturbingStart || options.noDisturbingEndH != _noDisturbingEnd){
        isUpdate = YES;
        options.noDisturbStatus = _noDisturbingStatus;
        options.noDisturbingStartH = _noDisturbingStart;
        options.noDisturbingEndH = _noDisturbingEnd;
    }
    
    if (isUpdate) {
        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushDisplayChanged:(UISwitch *)pushDisplaySwitch
{
    if (pushDisplaySwitch.isOn) {
#warning 此处设置详情显示时的昵称，比如_nickName = @"环信";
        _pushDisplayStyle = ePushNotificationDisplayStyle_messageSummary;
    }
    else{
        _pushDisplayStyle = ePushNotificationDisplayStyle_simpleBanner;
    }
}

- (void)refreshPushOptions
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    _nickName = options.nickname;
    _pushDisplayStyle = options.displayStyle;
    _noDisturbingStatus = options.noDisturbStatus;
    if (_noDisturbingStatus != ePushNotificationNoDisturbStatusClose) {
        _noDisturbingStart = options.noDisturbingStartH;
        _noDisturbingEnd = options.noDisturbingEndH;
    }
    
    BOOL isDisplayOn = _pushDisplayStyle == ePushNotificationDisplayStyle_simpleBanner ? NO : YES;
    [self.pushDisplaySwitch setOn:isDisplayOn animated:YES];
}

@end
