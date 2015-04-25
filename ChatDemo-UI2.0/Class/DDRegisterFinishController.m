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



@interface DDRegisterFinishController ()
{
    
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;

@property (strong, nonatomic) NSString *grade;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *school;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *university;
@property (strong,nonatomic)  UITextField *nicknamevalue;
@property (strong,nonatomic)  UITextField *gendervalue;
@property (strong,nonatomic) UITextField *gradevalue;
@property (strong,nonatomic) UITextField *birdatevalue;



@end
static DDUser   *dduser;

@implementation DDRegisterFinishController

- (id)init:(NSString *)username password:(NSString *)password city:(NSString *)city university:(NSString *)university{
    _username=username;
    _password=password;
    _city=city;
    _university=university;
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"注册";
    //nickname
    UILabel *nickname=[[UILabel alloc]initWithFrame:CGRectMake(10, 30, 60, 30)];
    nickname.text=@"昵称:";
    nickname.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:nickname];
    
     _nicknamevalue=[[UITextField alloc]initWithFrame:CGRectMake(nickname.frame.size.width+4, 30, 180, 30)];
    _nicknamevalue.placeholder=@"nicknamevalue";
    _nicknamevalue.textAlignment=NSTextAlignmentLeft;
    [_nicknamevalue setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:_nicknamevalue];
    //性别
    UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(10, nickname.frame.size.height*2+10, 60, 30)];
    gender.text=@"性别:";
    gender.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:gender];
    _gendervalue=[[UITextField alloc]initWithFrame:CGRectMake(gender.frame.size.width+4, nickname.frame.size.height*2+10, 120, 30)];
    _gendervalue.placeholder=@"性别";
    [_gendervalue setBorderStyle:UITextBorderStyleRoundedRect];
    _gendervalue.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:_gendervalue];

    //学校
    UILabel *university=[[UILabel alloc]initWithFrame:CGRectMake(10, nickname.frame.size.height*3+10, 60, 30)];
    university.text=@"学校:";
    university.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:university];
    UILabel *universityvalue=[[UILabel alloc]initWithFrame:CGRectMake(gender.frame.size.width+4, nickname.frame.size.height*3+10, 180, 30)];
    universityvalue.text=_university;
    universityvalue.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:universityvalue];
    
    //城市
    UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(10, nickname.frame.size.height*4+10, 60, 30)];
    city.text=@"城市:";
    city.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:city];
    UILabel *cityvalue=[[UILabel alloc]initWithFrame:CGRectMake(gender.frame.size.width+4, nickname.frame.size.height*4+10, 180, 30)];
    cityvalue.text=_city;
    cityvalue.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:cityvalue];

    //年级
    UILabel *grade=[[UILabel alloc]initWithFrame:CGRectMake(10, nickname.frame.size.height*5+10, 60, 30)];
    grade.text=@"年级:";
    grade.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:grade];
     _gradevalue=[[UITextField alloc]initWithFrame:CGRectMake(gender.frame.size.width+4, nickname.frame.size.height*5+10, 180, 30)];
    [_gradevalue setBorderStyle:UITextBorderStyleRoundedRect];
    _gradevalue.placeholder=@"gradevalue";
    _gradevalue.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:_gradevalue];
    
    //出生日期
    UITextField *birdate=[[UITextField alloc]initWithFrame:CGRectMake(10, nickname.frame.size.height*6+10, 60, 30)];
    birdate.text=@"出生日期:";
    birdate.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:birdate];
     _birdatevalue=[[UITextField alloc]initWithFrame:CGRectMake(gender.frame.size.width+4, nickname.frame.size.height*6+10, 180, 30)];
    _birdatevalue.placeholder=@"gradevalue";
    _birdatevalue.textAlignment=NSTextAlignmentLeft;
    [_birdatevalue setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:_birdatevalue];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, nickname.frame.size.height*7+30, 300, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    
    ////    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    //    [saveButton setTitle:NSLocalizedString(@"save", @"Save") forState:UIControlStateNormal];
    //    [saveButton addTarget:self action:@selector(savePushOptions) forControlEvents:UIControlEventTouchUpInside];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    //
    //    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //    [self refreshPushOptions];
    //    [self.tableView reloadData];
    
    
}

//注册账号
- (void)doRegister{
    //注册
    
            if (![self isEmpty]) {
                //隐藏键盘
                [self.view endEditing:YES];
                //判断是否是中文，但不支持中英文混编
          
                [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
                //异步注册账号
                [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_username
                                                                     password:_password
                                                               withCompletion:
                 ^(NSString *username, NSString *password, EMError *error) {
                     [self hideHud];
    
                     if (!error) {
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
                     }
                 } onQueue:nil];
                DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
                DDUser  *user=[DDUser new];
                user.nickName=_nicknamevalue.text;
                user.UID=_username;
                user.gender=_gendervalue.text;
                user.grade=_gradevalue.text;
                user.password=_password;
                user.university=_university;
                [ddbDynamoDB insertTableRow:user];
                
                DDLoginController *personsign=[DDLoginController alloc];
                [self.navigationController pushViewController:personsign animated:YES];
                
           
            }
    
}
//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_nicknamevalue.text.length == 0 || _gendervalue.text.length == 0) {
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
