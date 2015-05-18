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


@interface DDRegisterController () <UITextFieldDelegate>
{
   
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField  *code;


@end
static DDUser   *dduser;
@implementation DDRegisterController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"注册";
    //隐藏导航栏上得文字
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
    
                                                         forBarMetrics:UIBarMetricsDefault];

    //背景
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"registerbak.png"];
   //    imageView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    imageView.userInteractionEnabled=YES;
    [self.view addSubview:imageView];
   
   
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 40)];
    [_usernameTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _usernameTextField.placeholder = @"请输入11位手机号"; //默认显示的字
    _usernameTextField.userInteractionEnabled=YES;

    [imageView addSubview:_usernameTextField];
    
  
     _code = [[UITextField alloc] initWithFrame:CGRectMake(10, _usernameTextField.frame.origin.y+_usernameTextField.frame.size.height+10, 250, 40)];
    [_code setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _code.keyboardType = UIKeyboardTypeNumberPad;
    _code.placeholder = @"请输入验证码"; //默认显示的字
    [imageView addSubview:_code];
    _code.delegate = self;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_code.frame.origin.x+_code.frame.size.width+5, _code.frame.origin.y, 100, _code.frame.size.height)];
    button.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [button setTitle:@"获取验证码" forState:UIControlStateNormal];

    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    button.layer.cornerRadius = 5;
//    button.layer.masksToBounds = YES;
    [imageView addSubview:button];
    [button addTarget:self action:@selector(getCode) forControlEvents:UIControlEventTouchUpInside];

    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, _code.frame.origin.y+_code
                                                                       .frame.size.height+10, self.view.frame.size.width-20, 40)];
    _passwordTextField.returnKeyType = UIReturnKeyGo;
    _passwordTextField.secureTextEntry = YES;
    [_passwordTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _passwordTextField.placeholder = @"请输入不少于6位密码"; //默认显示的字
    
    [imageView addSubview:_passwordTextField];
    _passwordTextField.delegate = self;
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(10,  _passwordTextField.frame.origin.y+_passwordTextField
                                                                          .frame.size.height+20, self.view.frame.size.width-20, 45)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"下一步" forState:UIControlStateNormal];
    [imageView addSubview:registerButton];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
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
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                          message:NSLocalizedString(@"错误的电话号码", nil)
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    NSString* str=[NSString stringWithFormat:@"%@:%@ %@",NSLocalizedString(@"我们将要发送验证码到", nil),@"+86",_usernameTextField.text];
    
    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"电话确认", nil)
                                                  message:str delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                        otherButtonTitles:NSLocalizedString(@"确认", nil), nil];
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
    if(!DD_DEBUG){
        if(self.isEmpty){
            return;
        }
    }
    if(DD_DEBUG){
        DDSchoolRegisterController *personsign=[[DDSchoolRegisterController alloc] initWithNibName:self.usernameTextField.text password:self.passwordTextField.text];
        [self.navigationController pushViewController:personsign animated:YES];
        
    }else{
            if(_code.text.length!=4)
            {
                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"notice", nil)
                                                              message:NSLocalizedString(@"verifycodeformaterror", nil)
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                [SMS_SDK commitVerifyCode:_code.text result:^(enum SMS_ResponseState state) {
                    if (1==state)
                    {
                        NSLog(@"验证成功");
                        DDSchoolRegisterController *personsign=[[DDSchoolRegisterController alloc] initWithNibName:self.usernameTextField.text password:self.passwordTextField.text];
                        [self.navigationController pushViewController:personsign animated:YES];
                    }
                    else if(0==state)
                    {
                        NSLog(@"验证失败");
                        NSString* str=[NSString stringWithFormat:NSLocalizedString(@"verifycodeerrormsg", nil)];
                        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"verifycodeerrortitle", nil)
                                                                      message:str
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"sure", nil)
                                                            otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }];
            }
    
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
    
    if (_usernameTextField.text.length == 0 || _passwordTextField.text.length == 0 ||_code.text.length==0) {
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if ([self isEmpty]) {
        return NO;
    }

    [self doRegister];
    return YES;
}
@end
