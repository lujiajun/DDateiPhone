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

#import "LoginViewController.h"
#import "EMError.h"
#import "OSSArgs.h"
#import "DDRegisterController.h"
#import "DDLoginController.h"

@interface DDLoginController ()<IChatManagerDelegate,UITextFieldDelegate>

@property (strong, nonatomic)  UITextField *usernameTextField;
@property (strong, nonatomic)  UITextField *passwordTextField;
@property (strong, nonatomic)  UIButton *registerButton;
@property (strong, nonatomic)  UIButton *loginButton;
@property (strong, nonatomic)  UISwitch *useIpSwitch;



@end

@implementation DDLoginController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize registerButton = _registerButton;
@synthesize loginButton = _loginButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupForDismissKeyboard];
    _usernameTextField.delegate = self;
    
    [_useIpSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];
    
    
    //背景
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"registerbak.png"];
    //    imageView.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    imageView.userInteractionEnabled=YES;
    [self.view addSubview:imageView];
    
    
    self.title = @"登录";
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, 30)];
    [_usernameTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _usernameTextField.placeholder = @"请输入用户名"; //默认显示的字
    
    [imageView addSubview:_usernameTextField];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, 30)];
    [_passwordTextField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _passwordTextField.placeholder = @"请输入不少于6位密码"; //默认显示的字
    _passwordTextField.secureTextEntry = YES;
    [self.view addSubview:_passwordTextField];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"登录" forState:UIControlStateNormal];
    [imageView addSubview:registerButton];
    [registerButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];

 
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//点击登陆后的操作
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    [self showHudInView:self.view hint:NSLocalizedString(@"login.ongoing", @"Is Login...")];
    //异步登陆账号
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username
                                                        password:password
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         [self hideHud];
         if (loginInfo && !error) {
             //获取群组列表
             [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];

             //设置是否自动登录
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             //获取好友列表
             [[EaseMob sharedInstance].chatManager buddyList];
             
             //将旧版的coredata数据导入新的数据库
             EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
             if (!error) {
                 error = [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
             }
             
             //发送自动登陆状态通知
             [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
             
         }
         else
         {
             switch (error.errorCode)
             {
                 case EMErrorServerNotReachable:
                     TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                     break;
                 case EMErrorServerAuthenticationFailure:
                     TTAlertNoTitle(error.description);
                     break;
                 case EMErrorServerTimeout:
                     TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                     break;
                 default:
                     TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Logon failure"));
                     break;
             }
         }
     } onQueue:nil];
}

//弹出提示的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        //获取文本输入框
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        if(nameTextField.text.length > 0)
        {
            //设置推送设置
            [[EaseMob sharedInstance].chatManager setApnsNickname:nameTextField.text];
        }
    }
    //登陆
    [self loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
}

//登陆账号
- (void)doLogin {
    if (![self isEmpty]) {
        [self.view endEditing:YES];
        //支持是否为中文
        if ([self.usernameTextField.text isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
//#if !TARGET_IPHONE_SIMULATOR
        //弹出提示
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"login.inputApnsNickname", @"Please enter nickname for apns") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
//        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//        UITextField *nameTextField = [alert textFieldAtIndex:0];
//        nameTextField.text = self.usernameTextField.text;
//        [alert show];
//#elif TARGET_IPHONE_SIMULATOR
        [self loginWithUsername:_usernameTextField.text password:_passwordTextField.text];
//#endif
    }
}


//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
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


#pragma  mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _usernameTextField) {
        _passwordTextField.text = @"";
    }
    
    return YES;
}

@end
