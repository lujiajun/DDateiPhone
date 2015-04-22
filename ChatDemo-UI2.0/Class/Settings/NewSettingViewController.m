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

@interface NewSettingViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;

@end

@implementation NewSettingViewController

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;

#define kIMGCOUNT 5

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
    self.title = NSLocalizedString(@"title.setting", @"Setting");
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
    
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
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //            DDBDynamoDBManager *dynamoManager=[DDBDynamoDBManager alloc];
            
//            [self addUser];
            
            //            cell.textLabel.text = NSLocalizedString(@"setting.autoLogin", @"automatic login");
            cell.accessoryType = UITableViewCellAccessoryNone;
            //            self.autoLoginSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.autoLoginSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.autoLoginSwitch.frame.size.height) / 2, self.autoLoginSwitch.frame.size.width, self.autoLoginSwitch.frame.size.height);
            //            [cell.contentView addSubview:self.autoLoginSwitch];
            
            
            //            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://beijingdoubled.oss-cn-beijing.aliyuncs.com/9FA2EF31-A30B-4DA0-B3E0-33DF28DC4E96"]];
            //            UIImage *result = [UIImage imageWithData:data];
            UIImage *img=[UIImage imageNamed:@"80.png"];
            //            UIImageView *imgHead=[[UIImageView alloc] initWithImage:result];
            UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
            
            imgHead.frame=CGRectMake(50, 10, 200, 150);
            [imgHead setContentMode:UIViewContentModeScaleToFill];
            
            
            [cell.contentView addSubview:imgHead] ;
            
            
        }
        else if (indexPath.row == 1)
        {
            // 1.创建UIScrollView
            UIScrollView *scrollView = [[UIScrollView alloc] init];
            [scrollView setBackgroundColor:[UIColor whiteColor]];
            scrollView.frame = CGRectMake(70, 165, 400, 60); // frame中的size指UIScrollView的可视范围
            scrollView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:scrollView];
            
            // 2.创建UIImageView（图片）
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"80.png"];
            CGFloat imgW = imageView.image.size.width; // 图片的宽度
            CGFloat imgH = imageView.image.size.height; // 图片的高度
            imageView.frame = CGRectMake(0, 0, imgW, imgH);
            [scrollView addSubview:imageView];
            
            UIImageView *imageViewTwo = [[UIImageView alloc] init];
            imageViewTwo.image = [UIImage imageNamed:@"80.png"];
            CGFloat imgTwoW = imageViewTwo.image.size.width; // 图片的宽度
            CGFloat imgTwoH = imageViewTwo.image.size.height; // 图片的高度
            imageViewTwo.frame = CGRectMake(imgW+5, 0, imgTwoW, imgTwoH);
            [scrollView addSubview:imageViewTwo];
            
            UIButton *addPic=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            addPic.frame=CGRectMake(imgW+imgTwoW+10, 0, 40, 20);
            [addPic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [addPic setTitle:@"添加" forState:UIControlStateNormal];
            [addPic setBackgroundColor:[UIColor redColor]];
            [scrollView addSubview:addPic];
            [addPic addTarget:self action:@selector(btnClick) forControlEvents:(UIControlEventTouchUpInside)];// 按钮事件
            
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
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 20)];
            mylable.text=@"个性签名：请不要爱上我";
            mylable.textAlignment=NSTextAlignmentLeft;
            [cell.contentView addSubview:mylable];
            UILabel *school=[[UILabel alloc]initWithFrame:CGRectMake(60, 20, 200, 20)];
            school.text=@"学校：浙江大学";
            [cell.contentView addSubview:school];
            UILabel *intr=[[UILabel alloc]initWithFrame:CGRectMake(60, 40, 200, 20)];
            intr.text=@"游泳，跑步";
            [cell.contentView addSubview:intr];
            //            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
            //            cell.textLabel.text=@"CESHI";
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if (indexPath.row == 3)
            
        {
            UIImage *image = [UIImage imageNamed:@"80.png"];
            cell.imageView.image=image;
            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        
    }
    
    return cell;
}

-(void) addUser{
    DDUser *user=[DDUser new];
    
    user.UID=@"liufei1";
    user.nickName=@"dafei";
    user.gender=@"男";
    user.grade=@"大二";
//    user.isDoublerID=YES;
//    user.isPic=YES;
    user.password=@"ere";
    user.university=@"北京大学";
    user.picPath=@"xxx";
    user.waitingID=@"uu";
    [self insertTableRow:user];
}

- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0){
        return 163;
    }else if(indexPath.row==1){
        return 70;
    }else if(indexPath.row==2){
        return 70;
    }
    return 50;
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
        aliCloud.initSdk;
        NSString *name= [aliCloud uploadPic:data];
        
        
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        //        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //
        //        //文件管理器
        //        NSFileManager *fileManager = [NSFileManager defaultManager];
        //
        //        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        //        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        //        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        //
        //        //得到选择后沙盒中图片的完整路径
        //        NSString    *filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        //
        //        //关闭相册界面
        //        [picker dismissModalViewControllerAnimated:YES];
        //
        //        //创建一个选择后图片的小图标放在下方
        //        //类似微薄选择图后的效果
        //        UIImageView *smallimage = [[UIImageView alloc] initWithFrame:
        //                                    CGRectMake(50, 120, 40, 40)];
        //
        //        smallimage.image = image;
        //        //加在视图中
        //        [self.view addSubview:smallimage];
        
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
    if (indexPath.row == 1) {
        PushNotificationViewController *pushController = [[PushNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:pushController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        BlackListViewController *blackController = [[BlackListViewController alloc] initWithNibName:nil bundle:nil];
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
