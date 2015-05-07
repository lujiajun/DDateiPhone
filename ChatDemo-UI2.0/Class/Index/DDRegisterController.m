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
#import "Constants.h"
#import "DDRegisterController.h"
#import "PersonalController.h"
#import "DDSchoolRegisterController.h"
#import "DDUser.h"



@interface DDRegisterController ()
{
   
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;


@end
static DDUser   *dduser;

@implementation DDRegisterController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"注册";
    //背景
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"registerbak.png"];
   //    imageView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    imageView.userInteractionEnabled=YES;
    [self.view addSubview:imageView];
   
   
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, 250, 30)];
    [_usernameTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _usernameTextField.placeholder = @"请输入11位手机号"; //默认显示的字
    _usernameTextField.userInteractionEnabled=YES;

    [imageView addSubview:_usernameTextField];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(260, 10, 44, 30)];
    [button setImage:[UIImage imageNamed:@"getCode.png"] forState:UIControlStateNormal];
    [imageView addSubview:button];
//    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];

    UITextField  *code = [[UITextField alloc] initWithFrame:CGRectMake(0, 45, 250, 30)];
    [code setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    code.placeholder = @"请输入验证码"; //默认显示的字
    [imageView addSubview:code];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 250, 30)];
    [_passwordTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _passwordTextField.placeholder = @"请输入不少于6位密码"; //默认显示的字
    
    [imageView addSubview:_passwordTextField];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"下一步" forState:UIControlStateNormal];
    [imageView addSubview:registerButton];
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
//    
//        if (![self isEmpty]) {
//            //隐藏键盘
//            [self.view endEditing:YES];
//            //判断是否是中文，但不支持中英文混编
//            if ([_usernameTextField.text isChinese]) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
//                                      message:nil
//                                      delegate:nil
//                                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                      otherButtonTitles:nil];
//    
//                [alert show];
//    
//                return;
//            }
//            [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
//            //异步注册账号
//            [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_usernameTextField.text
//                                                                 password:_passwordTextField.text
//                                                           withCompletion:
//             ^(NSString *username, NSString *password, EMError *error) {
//                 [self hideHud];
//    
//                 if (!error) {
//                     TTAlertNoTitle(NSLocalizedString(@"register.success", @"Registered successfully, please log in"));
//                    
//                 }else{
//                     switch (error.errorCode) {
//                         case EMErrorServerNotReachable:
//                             TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
//                             break;
//                         case EMErrorServerDuplicatedAccount:
//                             TTAlertNoTitle(NSLocalizedString(@"register.repeat", @"You registered user already exists!"));
//                             break;
//                         case EMErrorServerTimeout:
//                             TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
//                             break;
//                         default:
//                             TTAlertNoTitle(NSLocalizedString(@"register.fail", @"Registration failed"));
//                             break;
//                     }
//                 }
//             } onQueue:nil];
//        }
    if(!self.isEmpty){
        DDSchoolRegisterController *personsign=[[DDSchoolRegisterController alloc] initWithNibName:_usernameTextField.text password:_passwordTextField.text];
        [self.navigationController pushViewController:personsign animated:YES];
    }
   
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_usernameTextField.text.length == 0 || _passwordTextField.text.length == 0) {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and password")
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
    }
    
    return ret;
}


@end
