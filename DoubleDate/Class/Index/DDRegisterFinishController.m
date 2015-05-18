//
//  PushNotificationViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-7-21.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//


#import "DDSchoolRegisterController.h"
#import "DDRegisterFinishController.h"
#import "AppDelegate+EaseMob.h"
#import "AppDelegate+UMeng.h"
#import "EMError.h"
#import "DDLoginController.h"
#import "AliCloudController.h"
#import "Constants.h"
#import "DDUserDAO.h"
#import "AWSDynamoDB_DDUser.h"
#import "Util.h"



@interface DDRegisterFinishController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;

@property (strong, nonatomic) NSString *grade;
@property (strong, nonatomic) NSNumber *gender;
@property (strong, nonatomic) NSString *school;
@property (strong, nonatomic) NSString *city;
//@property (strong, nonatomic) NSString *university;
@property (strong,nonatomic)  UITextField *nicknamevalue;
//@property (strong,nonatomic)  UITextField *gendervalue;
@property (strong,nonatomic) UITextField *gradevalue;
@property (strong,nonatomic) UITextField *birdatevalue;
@property (strong,nonatomic) UILabel *nickname;
@property (strong,nonatomic) NSString *picpath;
@property(strong,nonatomic)  NSData *data;
//@property(strong,nonatomic) UIButton *boy;
//@property(strong,nonatomic) UIButton *girl;
@property(strong, nonatomic) UISegmentedControl *genderControl;
@property(strong,nonatomic) UIImageView *imageView ;
@property(strong, nonatomic) UIScrollView *scrollView;


@end
static DDUser   *dduser;
// NSNumber *sex;

@implementation DDRegisterFinishController

- (id)init:(NSString *)username password:(NSString *)password city:(NSString *)city{
    _username=username;
    _password=password;
    _city=city;
    //    _university=university;
    return self;
}

- (id)init:(NSString *)nickname gender:(NSString *)gender grade:(NSString *)grade university:(NSString *)university city:(NSString *)city{
    _nickname.text=nickname;
    //    _gendervalue.text=gender;
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"注册";
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    scrollView.contentSize =CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * 2);
    scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    //头像
    _imageView = [[UIImageView alloc] init];
    _imageView.backgroundColor=[UIColor grayColor];
    _imageView.frame =CGRectMake(self.view.frame.size.width/2-75, 20, 150, 150);
    _imageView.image=[UIImage imageNamed:@"camera.png"];
    [scrollView addSubview:_imageView];
    [_imageView setUserInteractionEnabled:YES];
    _imageView.layer.masksToBounds =YES;
    _imageView.layer.cornerRadius =75;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick:)]];
    
    //nickname
    _nickname=[[UILabel alloc]initWithFrame:CGRectMake(10, _imageView.frame.origin.y+_imageView.frame.size.height+10, 60, 40)];
    _nickname.text=@"昵称:";
    _nickname.font=[UIFont fontWithName:@"Helvetica" size:14];
    _nickname.textAlignment=NSTextAlignmentLeft;
    [scrollView addSubview:_nickname];
    
    _nicknamevalue=[[UITextField alloc]initWithFrame:CGRectMake(_nickname.frame.size.width+4, _nickname.frame.origin.y, self.view.frame.size.width-70, 40)];
    _nicknamevalue.placeholder=@"填写昵称";
    _nicknamevalue.textAlignment=NSTextAlignmentLeft;
    [_nicknamevalue setBorderStyle:UITextBorderStyleRoundedRect];
    [scrollView addSubview:_nicknamevalue];
    _nicknamevalue.delegate = self;
    
    //性别
    UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(10,_nickname.frame.origin.y+ 45 , 50, 30)];
    gender.text=@"性别:";
    gender.font=[UIFont fontWithName:@"Helvetica" size:14];
    gender.textAlignment=NSTextAlignmentLeft;
    [scrollView addSubview:gender];
    
    NSArray* genderItems = @[@"男", @"女"];
    _genderControl = [[UISegmentedControl alloc] initWithItems:genderItems];
    _genderControl.frame = CGRectMake(gender.frame.origin.x+gender.frame.size.width+5, gender.frame.origin.y+5, 80, 25);
    _genderControl.selectedSegmentIndex = 0;
    [scrollView addSubview:_genderControl];
  
    //城市
    UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(10, _genderControl.frame.origin.y+_genderControl.frame.size.height+5, 50, 40)];
    
    city.text=@"城市:";
    city.font=[UIFont fontWithName:@"Helvetica" size:14];
    city.textAlignment=NSTextAlignmentLeft;
    [scrollView addSubview:city];
    
    UILabel *cityValue=[[UILabel alloc]initWithFrame:CGRectMake(city.frame.origin.x+city.frame.size.width+3, city.frame.origin.y, self.view.frame.size.width-60, 40)];
    cityValue.text=_city;
    cityValue.textAlignment=NSTextAlignmentLeft;
    [scrollView  addSubview:cityValue];
    
    //出生日期
    UILabel *birdate=[[UILabel alloc]initWithFrame:CGRectMake(10,city.frame.origin.y+40, 70, 40)];
    birdate.text=@"出生日期:";
    birdate.textAlignment=NSTextAlignmentLeft;
    birdate.font=[UIFont fontWithName:@"Helvetica" size:14];
    [scrollView addSubview:birdate];
    _birdatevalue=[[UITextField alloc]initWithFrame:CGRectMake(70, city.frame.origin.y+33, self.view.frame.size.width-80, 40)];
    _birdatevalue.placeholder=@"birthday";
    _birdatevalue.textAlignment=NSTextAlignmentLeft;
    [_birdatevalue setBorderStyle:UITextBorderStyleRoundedRect];
    [scrollView addSubview:_birdatevalue];
    _birdatevalue.delegate = self;
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(20,_birdatevalue.frame.origin.y+_birdatevalue.frame.size.height+20, self.view.frame.size.width-40, 45)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [scrollView addSubview:registerButton];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [registerButton addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat heightDelta = kbSize.height - 150;
    if (heightDelta > 0) {
        [self.scrollView setContentOffset:CGPointMake(0, heightDelta) animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void) registerUser{
    
    if(self.picpath==nil){
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"register.uploadHeadError", @"Please upload your head picture")
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
        return;
    }
    if ([self isEmpty]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doRegisterAWSHX)
                                                 name:@"doRegisterAWSHX"
                                               object:nil];
    
    
    [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRegisterAWSHX" object:@NO];
}

-(void) newDoRegister{
    if (![self isEmpty]) {
        //隐藏键盘
        [self.view endEditing:YES];
        //支持是否为中文
        if ([_username isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }//判断是否是中文，但不支持中英文混编
        //url post token注册
        if([Util registerUser:_username password:_password]){
            AliCloudController *aliCloud=[AliCloudController alloc];
            [aliCloud uploadPic:self.data name:self.picpath];
            
            AWSDynamoDB_DDUser *ddbDynamoDB=[AWSDynamoDB_DDUser new];
            DDUser  *user=[DDUser new];
            user.nickName=self.nicknamevalue.text;
            user.UID=self.username;
            user.gender=@(_genderControl.selectedSegmentIndex);
            //        user.grade=_gradevalue.text;
            user.password=self.password;
            user.city=self.city;
            user.birthday=self.birdatevalue.text;
            //        user.university=_university;
            //                NSNumber *isName=NSNUmber num;
            user.isDoublerID=[NSNumber numberWithInt:1];
            user.isPic=[NSNumber numberWithInt:1];
            user.picPath=self.picpath;
            [ddbDynamoDB insertDDUser:user];
            
            DDLoginController *personsign=[DDLoginController alloc];
            [self.navigationController pushViewController:personsign animated:YES];
            
            TTAlertNoTitle(NSLocalizedString(@"register.success", @"Registered successfully, please log in"));
            
        }else{
            TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
            
        }
        
        
    }
    
}

//注册账号
- (void)doRegisterAWSHX{
    //注册
    
    //隐藏键盘
    [self.view endEditing:YES];
    //判断是否是中文，但不支持中英文混编
    
    
    //异步注册账号
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_username
                                                         password:_password
                                                   withCompletion:
     ^(NSString *username, NSString *password, EMError *error) {
         
         if (!error) {
             //上传图片
             AliCloudController *aliCloud=[AliCloudController alloc];
             [aliCloud uploadPic:self.data name:self.picpath];
             
             AWSDynamoDB_DDUser *ddbDynamoDB=[AWSDynamoDB_DDUser new];
             DDUser  *user=[DDUser new];
             user.nickName=self.nicknamevalue.text;
             user.UID=self.username;
             user.gender=@(self.genderControl.selectedSegmentIndex);
             //        user.grade=_gradevalue.text;
             user.password=self.password;
             user.city=self.city;
             user.birthday=self.birdatevalue.text;
             //        user.university=_university;
             //                NSNumber *isName=NSNUmber num;
             user.isDoublerID=[NSNumber numberWithInt:1];
             user.isPic=[NSNumber numberWithInt:1];
             
             if(self.picpath==nil){
                 user.picPath=@"Logo_new";
             }else{
                 user.picPath=self.picpath;
             }
             [ddbDynamoDB insertDDUser:user];
             
             
             [self.navigationController popToRootViewControllerAnimated:NO];
             
             TTAlertNoTitle(NSLocalizedString(@"register.success", @"Registered successfully, please log in"));
             
         }else{
             switch (error.errorCode) {
                 case EMErrorServerNotReachable:
                     TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                     break;
                 case EMErrorServerDuplicatedAccount:
                     TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
                     break;
                 case EMErrorServerTimeout:
                     TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                     break;
                 default:
                     TTAlertNoTitle(NSLocalizedString(@"register.fail", @"Registration failed"));
                     break;
             }
             [self.navigationController popToRootViewControllerAnimated:NO];
             
         }
     } onQueue:nil];
    
    
    
}
//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_nicknamevalue.text.length == 0  ||_birdatevalue.text.length==0) {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"register.nicknameandgender", @"Please input your nickname and gender")
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
    }
    
    
    return ret;
}

-(void) btnClick:(UITapGestureRecognizer *)gestureRecognizer{
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
    switch (buttonIndex) {
        case 0://照相机
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
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
        UIImage* image = [info objectForKey: UIImagePickerControllerEditedImage];
        
        if (UIImagePNGRepresentation(image) == nil)
        {
            _data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            _data = UIImagePNGRepresentation(image);
            
        }
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:^{}];
        UIImageView *smallimage = [[UIImageView alloc] initWithFrame:
                                   CGRectMake(self.view.frame.size.width/2-75, 20, 150, 150)];
        [_imageView removeFromSuperview];
        smallimage.layer.masksToBounds =YES;
        smallimage.layer.cornerRadius =75;
        smallimage.image = image;
        //加在视图中
        [self.view addSubview:smallimage];
        //上传
        
        _picpath=[_username stringByAppendingString:@"_head_pic" ];
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return  (textField.text.length) > 0;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == _birdatevalue) {
        [self.scrollView scrollRectToVisible:textField.frame animated:YES];
    }
}
@end
