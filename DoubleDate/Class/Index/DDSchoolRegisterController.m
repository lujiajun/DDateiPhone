//
//  PushNotificationViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-7-21.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import "Commbox.h"
#import "DDSchoolRegisterController.h"
#import "DDRegisterFinishController.h"
#import "DDUser.h"

@interface DDSchoolRegisterController () <UITextFieldDelegate>
{
    
}

@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;
@property  (strong,nonatomic) UITextField  *cityvalue;


@end
static DDUser   *dduser;

@implementation DDSchoolRegisterController

- (id)initWithNibName:(NSString *)username password:(NSString *)password{
    _username=username;
    _password=password;
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"注册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor=[UIColor lightGrayColor];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 250);
    [self.view addSubview:imageView];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [imageView addGestureRecognizer:tapGesture];
    
    UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(5, imageView.frame.size.height+5, 80, 20)];
    city.text=@"所在城市:";
    city.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:city];
   
    _cityvalue = [[UITextField alloc] initWithFrame:CGRectMake(city.frame.origin.x+city.frame.size.width, city.frame.origin.y, 260, 30)];
    [_cityvalue setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
    _cityvalue.userInteractionEnabled=YES;
    _cityvalue.placeholder = @"请输入所在城市"; //默认显示的字
    [self.view addSubview:_cityvalue];
    _cityvalue.returnKeyType = UIReturnKeyGo;
    _cityvalue.delegate = self;
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+city.frame.size.height*2+40, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
}

//注册账号
- (void)next{
    if(!self.isEmpty){
        DDRegisterFinishController *personsign=[[DDRegisterFinishController alloc] init:_username password:_password city:_cityvalue.text];
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
    if (_cityvalue.text.length == 0) {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"register.school", @"Please choose your city and university")
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
    }
    
    return ret;
}

#pragma mark - Touch events
- (void) onTap: (id) sender {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    if ([self isEmpty]) {
        return NO;
    }
    
    [self next];
    return YES;
}

@end
