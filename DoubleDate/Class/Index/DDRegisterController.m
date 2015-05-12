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

#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/CountryAndAreaCode.h>
#import "AWSDynamoDB_DDUser.h"


@interface DDRegisterController ()
{
   
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField  *code;


@end
static DDUser   *dduser;
static BOOL isDebug=YES;
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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(260, 10, 50, 30)];
    [button setImage:[UIImage imageNamed:@"getCode.png"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    [imageView addSubview:button];
    [button addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];

     _code = [[UITextField alloc] initWithFrame:CGRectMake(0, 45, 250, 30)];
    [_code setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _code.placeholder = @"请输入验证码"; //默认显示的字
    [imageView addSubview:_code];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, 250, 30)];
    [_passwordTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _passwordTextField.placeholder = @"请输入不少于6位密码"; //默认显示的字
    
    [imageView addSubview:_passwordTextField];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"下一步" forState:UIControlStateNormal];
    [imageView addSubview:registerButton];
    [registerButton addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    
   
}

-(void)getCode
{
    int compareResult = 0;
    //验证ID是否存在
    AWSDynamoDB_DDUser *dynamo=[[AWSDynamoDB_DDUser alloc]init];
    DDUser *user=    [dynamo getUserByUid:_usernameTextField.text];
    if(user!=nil&&user.UID!=nil){
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"register.repeat", @"You registered user already exists!")
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
        return;
    }
    
    if (!compareResult)
    {
        if (_usernameTextField.text.length!=11)
        {
            //手机号码不正确
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                          message:NSLocalizedString(@"errorphonenumber", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    NSString* str=[NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"willsendthecodeto", nil),@"+86",_usernameTextField.text];
    
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"surephonenumber", nil)
                                                  message:str delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"sure", nil), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1==buttonIndex)
    {
        [SMS_SDK getVerificationCodeBySMSWithPhone:_usernameTextField.text
                                              zone:@"86"
                                            result:^(SMS_SDKError *error)
         {
            
             if (!error)
             {
                 NSLog(@"发送成功");
                 [self showHint:@"发送成功"];
                 
             }
             else
             {
                 UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"codesenderrtitle", nil)
                                                               message:[NSString stringWithFormat:@"状态码：%zi ,错误描述：%@",error.errorCode,error.errorDescription]
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                     otherButtonTitles:nil, nil];
                 [alert show];
             }
             
         }];
    }
}

-(void)doRegister
{
    //验证号码
    //验证成功后 获取通讯录 上传通讯录
//    [self.view endEditing:YES];
    if(self.isEmpty){
        return;
    }
    DDSchoolRegisterController *personsign=[[DDSchoolRegisterController alloc] initWithNibName:self.usernameTextField.text password:self.passwordTextField.text];
                    [self.navigationController pushViewController:personsign animated:YES];
    
//    if(_code.text.length!=4)
//    {
//        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
//                                                      message:NSLocalizedString(@"verifycodeformaterror", nil)
//                                                     delegate:self
//                                            cancelButtonTitle:@"确定"
//                                            otherButtonTitles:nil, nil];
//        [alert show];
//    }
//    else
//    {
//        [SMS_SDK commitVerifyCode:_code.text result:^(enum SMS_ResponseState state) {
//            if (1==state)
//            {
//                NSLog(@"验证成功");
//                DDSchoolRegisterController *personsign=[[DDSchoolRegisterController alloc] initWithNibName:self.usernameTextField.text password:self.passwordTextField.text];
//                [self.navigationController pushViewController:personsign animated:YES];
//            }
//            else if(0==state)
//            {
//                NSLog(@"验证失败");
//                NSString* str=[NSString stringWithFormat:NSLocalizedString(@"verifycodeerrormsg", nil)];
//                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycodeerrortitle", nil)
//                                                              message:str
//                                                             delegate:self
//                                                    cancelButtonTitle:NSLocalizedString(@"sure", nil)
//                                                    otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }];
//    }
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
