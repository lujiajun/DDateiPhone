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
#import "Constants.h"
#import "DDRegisterFinishController.h"
#import "DDPersonalUpdateController.h"
#import "DDHeadPicUpdate.h"
#import "PersonalController.h"
#import "IndexViewController.h"
#import "HelpViewController.h"
#import "DDUserDAO.h"
#import "UIImageView+EMWebCache.h"
#import "Constants.h"
#import "DDupdatePicAndName.h"
#import "Util.h"
#import "IndexViewController.h"
@interface NewSettingViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;
@property(nonatomic)  NSUInteger *picnumber;
@property(strong,nonatomic) NSMutableArray *addedPicArray;
@property(strong,nonatomic) AliCloudController *aliCloud;
@property(strong,nonatomic) NSString *loginname;
@property(strong,nonatomic) UIImageView *plusImageView;
@property(strong,nonatomic) DDUser *user;

@end

@implementation NewSettingViewController

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;


#define  PIC_WIDTH 120
#define  PIC_HEIGHT 120




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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    self.tableView.tableFooterView = self.footerView;
    
    if(_aliCloud==nil){
        _aliCloud=[AliCloudController alloc];
        [_aliCloud initSdk];

    }
    if(_loginname==nil){
        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        _loginname = [loginInfo objectForKey:kSDKUsername];
    }
    if(_addedPicArray==nil){
        _addedPicArray =[[NSMutableArray alloc]init];
        _user= [IndexViewController instanceDDuser];
        if(_user==nil){
            IndexViewController *index=[IndexViewController alloc];
            [index initdduser];
            _user=[IndexViewController instanceDDuser];
        }
        if(_user.photos!=nil){
            _addedPicArray= [[NSMutableArray alloc] initWithArray:[_user.photos componentsSeparatedByString:@","]];
            
        }

    }
    if(_plusImageView==nil){
        //添加按钮
        UIImage *image = [UIImage imageNamed:@"addpic"];
        //图片显示
        _plusImageView = [[UIImageView alloc] initWithImage:image];
        _plusImageView.userInteractionEnabled=YES;

    }
    //出事scroview
    [self refreshScrollView];

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

- (UISwitch *)beInvitedSwitch
{

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

-(void) refreshScrollView{
   
    if(_scrollView==nil){
         _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 400, 130)];
    }
    
    //循环执行，有多少张图片，执行几次
    _scrollView.scrollEnabled=YES;
    if(_addedPicArray.count>1){
    
    CGSize contentSize=CGSizeMake(PIC_WIDTH*(_addedPicArray.count+1), 130);
    //shezhi滚动范围
    _scrollView.contentSize=contentSize;

    }else{
    
        CGSize contentSize=CGSizeMake(PIC_WIDTH*(_addedPicArray.count+2), 130);
        //shezhi滚动范围
        _scrollView.contentSize=contentSize;
    }
    [_scrollView setUserInteractionEnabled:YES];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
            
        case 3:
            
            return  2;
            
            break;
            
            
        default:
            
            return 1;
            
            break;  
            
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(_user==nil){
        IndexViewController *index=[IndexViewController alloc];
        [index initdduser];
        _user=[IndexViewController instanceDDuser];
    }
    
    switch (indexPath.section) {
            
            case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            //background
            UIImage *bak=[UIImage imageNamed:@"settingback"];
            UIImageView *bakview=[[UIImageView alloc] initWithImage:bak];
            bakview.frame=CGRectMake(0, 0, cell.frame.size.width, 160);
            [cell.contentView addSubview:bakview];
            
        
            UIImageView *imgHead=[[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2-50, 10, 100, 100)];
            [imgHead sd_setImageWithURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:[IndexViewController instanceDDuser].picPath]]];
            imgHead.layer.cornerRadius =50;
            imgHead.layer.masksToBounds = YES;
            [imgHead setContentMode:UIViewContentModeScaleToFill];
            
            [bakview addSubview:imgHead] ;
            //添加nickname
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2-35, 112, 80, 20)];
            mylable.text=[IndexViewController instanceDDuser].nickName;
            mylable.textAlignment=NSTextAlignmentCenter;
            mylable.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:mylable];
            //添加性别图标
            NSString *sex;
            if([[IndexViewController instanceDDuser].gender isEqualToString: @"男" ]|| [[IndexViewController instanceDDuser].gender isEqualToString: @"Male"]){
                sex=@"sexbox";
            }else{
                sex=@"sexgirl";
            }
            UIImage *seximg=[UIImage imageNamed:sex];
            UIImageView *sexview=[[UIImageView alloc] initWithImage:seximg];
            sexview.frame=CGRectMake(mylable.frame.origin.x+mylable.frame.size.width, mylable.frame.origin.y, 10, 10);
            [bakview addSubview:sexview];
            //添加double 号
            UILabel *doubledate=[[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2-35, 134, 150, 20)];
            doubledate.text=[@"Double号:" stringByAppendingString:[IndexViewController instanceDDuser].UID];
//            NSLog([IndexViewController instanceDDuser].UID);
            doubledate.textAlignment=NSTextAlignmentLeft;
            doubledate.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:doubledate];
    }
            break;

            
        case 1:
        {
            // 1.创建UIScrollView
            
            if(_addedPicArray.count==0){
                
                //赋值
                _plusImageView.frame = CGRectMake(0,_scrollView.frame.origin.y, PIC_WIDTH, PIC_HEIGHT);
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick)];
                [_plusImageView addGestureRecognizer:singleTap];//点击图片事件

                [_scrollView addSubview:_plusImageView];
            }else{
                int i=0;
                for (id element in _addedPicArray) {
                    if(element!=nil&&![element isEqual:@""]){
                        
                        //图片显示
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.origin.x+PIC_WIDTH*i,cell.frame.origin.y, PIC_WIDTH, PIC_HEIGHT)];
                        
                        [imageView sd_setImageWithURL:[NSURL URLWithString:[[DDPicPath stringByAppendingString:[_loginname stringByAppendingString:@"_"]] stringByAppendingString:element]]placeholderImage:[UIImage imageNamed:@"Logo_new"]];
                        
                        //获取图片的框架，得到长、宽
                        //赋值
                        imageView.tag = i;
                        
                        //ScrollView添加子视图
                        [_scrollView addSubview:imageView];
                        i++;

                    }
                    
                }
                if(_addedPicArray.count>1){
                    _plusImageView.frame = CGRectMake(PIC_WIDTH*(_addedPicArray.count-1),_scrollView.frame.origin.y, PIC_WIDTH, PIC_HEIGHT);
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick)];
                    [_plusImageView addGestureRecognizer:singleTap];//点击图片事件
                    
                    [_scrollView addSubview:_plusImageView];
                }
                

            }
            
            
            [cell.contentView addSubview:_scrollView];

            break;
        }
        case 2:{
            //background
            UIImage *bak=[UIImage imageNamed:@"files"];
            UIImageView *bakview=[[UIImageView alloc] initWithImage:bak];
            bakview.frame=CGRectMake(0, cell.frame.origin.y+5, cell.frame.size.width, 140);
            [cell.contentView addSubview:bakview];
            
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(30, bakview.frame.origin.y+5, 100, 20)];
            
            mylable.text=[Util str1:@"城市：   " appendStr2:[IndexViewController instanceDDuser].city==nil?@"请编辑城市信息":[IndexViewController instanceDDuser].city];
            mylable.textAlignment=NSTextAlignmentLeft;
            mylable.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:mylable];
            //isdoubled
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"confirm.png"];
            imageView.frame = CGRectMake(140, mylable.frame.origin.y, 20, 15);
            [bakview addSubview:imageView];
            
            //BIANJI
            UIImageView *bianjiView = [[UIImageView alloc] init];
            bianjiView.image = [UIImage imageNamed:@"bianji.png"];
            bianjiView.frame = CGRectMake(cell.frame.size.width-30, mylable.frame.origin.y, 15, 15);
            [bakview addSubview:bianjiView];
            
            UILabel *university=[[UILabel alloc]initWithFrame:CGRectMake(30, mylable.frame.origin.y+20, 200, 20)];
            university.text=[Util str1:@"学校：   " appendStr2:[IndexViewController instanceDDuser].university==nil?@"请编辑学校信息":[IndexViewController instanceDDuser].university];
            university.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:university];
            
//            UILabel *school=[[UILabel alloc]initWithFrame:CGRectMake(30, city.frame.origin.y+20, 200, 20)];
//            if(_user!=nil&&_user.city!=nil){
//                school.text=[@"年级：   " stringByAppendingString:[IndexViewController instanceDDuser].grade];
//            }
//            
//            school.font=[UIFont fontWithName:@"Helvetica" size:12];
//            [bakview addSubview:school];
            
            UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(30, university.frame.origin.y+20, 200, 20)];
            gender.text=[Util str1:@"性别：   " appendStr2:[IndexViewController instanceDDuser].gender==nil?@"请编辑性别信息":[IndexViewController instanceDDuser].gender];

            gender.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:gender];
            
            
            UILabel *birth=[[UILabel alloc]initWithFrame:CGRectMake(30, gender.frame.origin.y+20, 200, 20)];
    
            birth.text=[Util str1:@"BIRTH：   " appendStr2:[IndexViewController instanceDDuser].birthday==nil?@"请编辑出生日期信息":[IndexViewController instanceDDuser].birthday];

            birth.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:birth];
            
            UILabel *intre=[[UILabel alloc]initWithFrame:CGRectMake(30, birth.frame.origin.y+20, 200, 20)];
            intre.text=[Util str1:@"爱好：   " appendStr2:[IndexViewController instanceDDuser].hobbies==nil?@"请编辑爱好信息":[IndexViewController instanceDDuser].hobbies];
            intre.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:intre];
            
            UILabel *sign=[[UILabel alloc]initWithFrame:CGRectMake(30, intre.frame.origin.y+20, 200, 20)];
            sign.text=[Util str1:@"签名：   " appendStr2:[IndexViewController instanceDDuser].sign==nil?@"请编辑签名信息":[IndexViewController instanceDDuser].sign];
                        sign.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:sign];
            //            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
            //            cell.textLabel.text=@"CESHI";
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        }
        case 3:
        {
            if (indexPath.row == 0)
            {
                UIImage *img=[UIImage imageNamed:@"setting"];
                UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
                imgHead.frame=CGRectMake(20, cell.frame.origin.y+15, 15, 15);
                [cell.contentView addSubview:imgHead];
                UILabel *sets=[[UILabel alloc] initWithFrame:CGRectMake(imgHead.frame.origin.x+imgHead.frame.size.width+5, cell.frame.origin.y+15, 100, 20)];
                sets.text= NSLocalizedString(@"title.setting", @"Setting");
                sets.font=[UIFont fontWithName:@"Helvetica" size:12];
                [cell.contentView addSubview:sets];
                
                //            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else if(indexPath.row==1){
                UIImage *img=[UIImage imageNamed:@"help"];
                UIImageView *imgHead=[[UIImageView alloc] initWithImage:img];
                imgHead.frame=CGRectMake(20, cell.frame.origin.y+15, 15, 15);
                [cell.contentView addSubview:imgHead];
                UILabel *sets=[[UILabel alloc] initWithFrame:CGRectMake(imgHead.frame.origin.x+imgHead.frame.size.width+5, cell.frame.origin.y+15, 100, 20)];
                sets.text= @"帮助";
                sets.font=[UIFont fontWithName:@"Helvetica" size:12];
                [cell.contentView addSubview:sets];
                
                //            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
 
        }
      
    }

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
        return 0;
    else
        return 5.0f;
}

- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==3){   
        return 50;
    }else if(indexPath.section==1){
        return 130;
    }
    return 160;
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
        //关闭相册
         [picker dismissModalViewControllerAnimated:YES];
        //添加图片
        UIImageView *aImageView=[[UIImageView alloc]initWithImage:image];
        [aImageView setFrame:CGRectMake(_plusImageView.frame.origin.x, _plusImageView.frame.origin.y, PIC_WIDTH, PIC_HEIGHT)];
        [_scrollView addSubview:aImageView];
        //放置图片到指定位置
        
        CABasicAnimation *positionAnim=[CABasicAnimation animationWithKeyPath:@"position"];
        [positionAnim setFromValue:[NSValue valueWithCGPoint:CGPointMake(_plusImageView.center.x, _plusImageView.center.y)]];
        [positionAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(_plusImageView.center.x+PIC_WIDTH, _plusImageView.center.y)]];
        [positionAnim setDelegate:self];
        [positionAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [positionAnim setDuration:0.25f];
        [_plusImageView.layer addAnimation:positionAnim forKey:nil];
        [_plusImageView setCenter:CGPointMake(_plusImageView.center.x+PIC_WIDTH, _plusImageView.center.y)];
        
        //先显示，在上传
        //获得addPicArry中得最大值
        NSString *picname=[self getNewPicName];
        
        [_addedPicArray addObject:picname];
        [self refreshScrollView];
        [[self tableView] reloadData];
    
        [_aliCloud asynUploadPic:data name:picname username:[IndexViewController instanceDDuser].UID];
    
    }
    
}
//最大值加1
-(NSString *) getNewPicName{
    if(_addedPicArray==nil ||_addedPicArray.count==0){
//        [_addedPicArray addObject:1];
        return @"1";
    }else{
        NSComparator cmptr = ^(id obj1, id obj2){
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;  
        };
        NSArray *array = [_addedPicArray sortedArrayUsingComparator:cmptr];
        return   [NSString stringWithFormat: @"%d",  [array.lastObject integerValue]+1];
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
    switch (indexPath.section) {
        case 0:{
            DDupdatePicAndName *pushController = [DDupdatePicAndName alloc] ;
            [self.navigationController pushViewController:pushController animated:YES];

            break;
        }
        case 2:{
            DDPersonalUpdateController *blackController = [DDPersonalUpdateController alloc];
            [self.navigationController pushViewController:blackController animated:YES];
            break;
        }
        case 3:{
            if(indexPath.row==0){
                
                SettingsViewController *debugController = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
                [self.navigationController pushViewController:debugController animated:YES];

            }else{
                HelpViewController *help=[HelpViewController alloc];
                [self.navigationController pushViewController:help animated:YES];
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
