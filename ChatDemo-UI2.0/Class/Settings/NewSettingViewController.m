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
#import "DDHeadPicUpdate.h"
#import "PersonalController.h"
@interface NewSettingViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;

@end
static DDUser   *uuser;
@implementation NewSettingViewController

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;

#define kIMGCOUNT 5

+(DDUser *) instanceDDuser{
    return uuser;
}
-(void) setDDUser:(DDUser *) user{
    uuser=user;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =@"个人主页";
    self.view.backgroundColor = [UIColor redColor];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
    //chaxun
    [self initdduser];
    


}

-(void)initdduser{
    if(uuser==nil){
        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *username = [loginInfo objectForKey:kSDKUsername];
        //查询
        DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
        //同步方法
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        BFTask *bftask= [dynamoDBObjectMapper load:[DDUser class] hashKey:username rangeKey:nil];
        bftask.waitUntilFinished;
        uuser= bftask.result;
        
    } 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (UISwitch *)autoLoginSwitch
{
    if (_autoLoginSwitch == nil) {
        _autoLoginSwitch = [[UISwitch alloc] init];
        [_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _autoLoginSwitch;
}

- (UISwitch *)ipSwitch
{
    if (_ipSwitch == nil) {
        _ipSwitch = [[UISwitch alloc] init];
        [_ipSwitch addTarget:self action:@selector(useIpChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _ipSwitch;
}

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
    return 5;
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
    [self initdduser];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            //background
            UIImage *bak=[UIImage imageNamed:@"settingback"];
            UIImageView *bakview=[[UIImageView alloc] initWithImage:bak];
            bakview.frame=CGRectMake(0, 0, cell.frame.size.width, 160);
            [cell.contentView addSubview:bakview];
 
            //touxiang
            UIImage *img=[UIImage alloc];
            if(uuser && uuser.picPath){
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:uuser.picPath]]];
                img = [UIImage imageWithData:data];
            }else {
                img=[UIImage imageNamed:@"Logo_new.png"];
            }
            UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
            imgHead.layer.masksToBounds =YES;
            imgHead.layer.cornerRadius =50;
            imgHead.frame=CGRectMake(self.tableView.frame.size.width/2-50, 10, 100, 100);
            [imgHead setContentMode:UIViewContentModeScaleToFill];

            [bakview addSubview:imgHead] ;
            //添加nickname
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2-35, 112, 70, 20)];
            mylable.text=uuser.nickName;
            mylable.textAlignment=NSTextAlignmentCenter;
            [bakview addSubview:mylable];
            //添加性别图标
            NSString *sex;
            if(uuser.gender ==@"男" || uuser.gender ==@"Male"){
                sex=@"sexbox";
            }else{
                sex=@"sexgirl";
            }
            UIImage *seximg=[UIImage imageNamed:sex];
            UIImageView *sexview=[[UIImageView alloc] initWithImage:seximg];
            sexview.frame=CGRectMake(self.tableView.frame.size.width/2+35, 112, 10, 10);
            [bakview addSubview:sexview];
            //添加double 号
            UILabel *doubledate=[[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2-35, 134, 70, 20)];
            doubledate.text=[@"Double号:" stringByAppendingString:uuser.UID];
            doubledate.textAlignment=NSTextAlignmentLeft;
            doubledate.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:doubledate];

        }
        else if (indexPath.row == 1)
        {
            // 1.创建UIScrollView
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            [scrollView setBackgroundColor:[UIColor whiteColor]];
            scrollView.frame = CGRectMake(70, 162, 400, 90); // frame中的size指UIScrollView的可视范围
            scrollView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:scrollView];
            
            // 2.创建UIImageView（图片）
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"80.png"];
            CGFloat imgW = imageView.image.size.width; // 图片的宽度
            CGFloat imgH = imageView.image.size.height; // 图片的高度
            imageView.frame = CGRectMake(0, 0, imgW, imgW);
            [scrollView addSubview:imageView];
            
            UIImageView *imageViewTwo = [[UIImageView alloc] init];
            imageViewTwo.image = [UIImage imageNamed:@"80.png"];
            CGFloat imgTwoW = imageViewTwo.image.size.width; // 图片的宽度
            CGFloat imgTwoH = imageViewTwo.image.size.height; // 图片的高度
            imageViewTwo.frame = CGRectMake(imgW+5, 0, imgW, imgW);
            [scrollView addSubview:imageViewTwo];
            
            UIImageView *imageViewadd = [[UIImageView alloc] init];
            imageViewTwo.image = [UIImage imageNamed:@"addpic.png"];
            imageViewTwo.frame = CGRectMake(imgW+5, 0, imgW, imgW);
            
            [imageViewadd setUserInteractionEnabled:YES];
            [imageViewadd addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPicClick:)]];
            [scrollView addSubview:imageViewadd];
            // 3.设置scrollView的属性
            
            // 设置UIScrollView的滚动范围（内容大小）
            scrollView.contentSize = imageView.image.size;
            
            // 隐藏水平滚动条
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            
            [cell.contentView addSubview:self.scrollView];
            //设置页数控制器总页数，即按钮数
            //            self.pageControl.numberOfPages=kIMGCOUNT;
            //            cell.textLabel.text = NSLocalizedString(@"title.apnsSetting", @"Apns Settings");
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 2)
        {
            //background
            UIImage *bak=[UIImage imageNamed:@"files"];
            UIImageView *bakview=[[UIImageView alloc] initWithImage:bak];
            bakview.frame=CGRectMake(0, 0, cell.frame.size.width, 160);
            [cell.contentView addSubview:bakview];
            
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(30, 5, 100, 20)];
            mylable.text=[@"学校：   " stringByAppendingString:uuser.university];
            mylable.textAlignment=NSTextAlignmentLeft;
            mylable.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:mylable];
            //isdoubled
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"confirm.png"];
            imageView.frame = CGRectMake(140, 5, 20, 15);
            [bakview addSubview:imageView];
            
            //bianji
            UIImageView *bianjiView = [[UIImageView alloc] init];
            bianjiView.image = [UIImage imageNamed:@"bianji"];
            bianjiView.frame = CGRectMake(cell.frame.size.width-30, 5, 15, 15);
            [bakview addSubview:bianjiView];
            
            UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(30, bianjiView.frame.origin.y+20, 200, 20)];
            city.text=@"城市：   北京" ;
            city.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:city];
            
            UILabel *school=[[UILabel alloc]initWithFrame:CGRectMake(30, city.frame.origin.y+20, 200, 20)];
            school.text=[@"年级：   " stringByAppendingString:uuser.grade];
            school.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:school];
            
            UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(30, school.frame.origin.y+20, 200, 20)];
            gender.text=[@"性别：   " stringByAppendingString:uuser.gender];
            gender.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:gender];
            
            UILabel *intre=[[UILabel alloc]initWithFrame:CGRectMake(30, gender.frame.origin.y+20, 200, 20)];
            intre.text=[@"爱好：   " stringByAppendingString:@"testrttttttttttttttttttttttttt"];
            intre.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:intre];
            
            UILabel *sign=[[UILabel alloc]initWithFrame:CGRectMake(30, intre.frame.origin.y+20, 200, 20)];
            sign.text=[@"签名：   " stringByAppendingString:@"testrttttttttttttttttttttttttt"];
            sign.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:sign];
            //            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
            //            cell.textLabel.text=@"CESHI";
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if (indexPath.row == 3)
        {
            UIImage *img=[UIImage imageNamed:@"setting"];
            UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
            imgHead.frame=CGRectMake(20, 15, 15, 15);
            [cell.contentView addSubview:imgHead];
            UILabel *sets=[[UILabel alloc] initWithFrame:CGRectMake(60, 5, 100, 50)];
            sets.text= NSLocalizedString(@"title.setting", @"Setting");
            [cell.contentView addSubview:sets];
            
//            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if(indexPath.row==4){
            UIImage *img=[UIImage imageNamed:@"help"];
            UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
            imgHead.frame=CGRectMake(20, 15, 15, 15);
            [cell.contentView addSubview:imgHead];
            UILabel *sets=[[UILabel alloc] initWithFrame:CGRectMake(60, 5, 100, 50)];
            sets.text= @"帮助";
            [cell.contentView addSubview:sets];
            
            //            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

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
    if(indexPath.row==0){
        return 160;
    }else if(indexPath.row==1){
        return 100;
    }else if(indexPath.row==2){
        return 160;
    }
    return 40;
}


-(void) addPicClick:(UITapGestureRecognizer *)gestureRecognizer{
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
        aliCloud.initSdk;
        NSString *name= [aliCloud uploadPic:data];
    
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        PersonalController *pushController = [PersonalController alloc] ;
        [self.navigationController pushViewController:pushController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        DDPersonalUpdateController *blackController = [[DDPersonalUpdateController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:blackController animated:YES];
    }
    else if (indexPath.row == 3)
    {
        SettingsViewController *debugController = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:debugController animated:YES];
    }
}

#pragma mark - getter

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        //分割线
        //        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 10, 0.5)];
        //        line.backgroundColor = [UIColor lightGrayColor];
        //        [_footerView addSubview:line];
        
        //        UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 20, _footerView.frame.size.width - 80, 40)];
        //        [logoutButton setBackgroundColor:[UIColor colorWithRed:191 / 255.0 green:48 / 255.0 blue:49 / 255.0 alpha:1.0]];
        //        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        //        NSString *username = [loginInfo objectForKey:kSDKUsername];
        //        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"setting.loginUser", @"log out(%@)"), username];
        //        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        //        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        //        [_footerView addSubview:logoutButton];
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
