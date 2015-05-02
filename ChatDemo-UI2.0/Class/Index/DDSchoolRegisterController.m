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



@interface DDSchoolRegisterController ()
{
    
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;


@property  (strong,nonatomic) Commbox     *commbox;
@property  (strong,nonatomic) Commbox     *universitycommbox;


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
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"80.png"];
    CGFloat imgW = imageView.image.size.width; // 图片的宽度
    CGFloat imgH = imageView.image.size.height; // 图片的高度
    imageView.frame = CGRectMake(50, 0, 200, 250);
    [self.view addSubview:imageView];
    
    UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(5, imageView.frame.size.height+5, 50, 20)];
    city.text=@"所在城市";
    city.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:city];
//    NSMutableDictionary *mulDic = [NSMutableDictionary dictionary];
//    [mulDic setObject:[NSArray arrayWithObjects:@"15000000", @"/MHz"    , nil] forKey:@"蜂窝公众通信（全国网）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"15000000", @"/MHz"    , nil] forKey:@"蜂窝公众通信（非全国网）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"50000",    @"每频点"   , nil] forKey:@"集群无线调度系统（全国范围使用）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"10000",    @"每频点"   , nil] forKey:@"集群无线调度系统（省、自治区、直辖市范围使用）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"2000",     @"每频点"   , nil] forKey:@"集群无线调度系统（地、市范围使用）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"2000000",  @"每频点"   , nil] forKey:@"无线寻呼系统（全国范围使用）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"2000000",  @"每频点"   , nil] forKey:@"无线寻呼系统（省、自治区、直辖市范围使用"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"40000",    @"每频点"   , nil] forKey:@"无线寻呼系统（地、市范围使用）"];
//    [mulDic setObject:[NSArray arrayWithObjects:@"150",      @"每基站"   , nil] forKey:@"无绳电话系统"];
    
    
    NSArray   *arrayData =[[NSArray alloc]initWithObjects:@"电话",@"email",@"手机",@"aaa",@"bbb",@"ccc",nil];
    
    _commbox = [[Commbox alloc] initWithFrame:CGRectMake(70, imageView.frame.size.height+5, 140, 100)];
    _commbox.textField.placeholder = @"点击请选择";
    
//    NSMutableArray* arr = [[NSMutableArray alloc] init];
//    //*****************************************************************************************************************
//    NSEnumerator *e = [mulDic keyEnumerator];
//    for (NSString *key in e) {
//        //NSLog(@"Key is %@, value is %@", key, [mulDic objectForKey:key]);
//        [arr addObject:key];
//        
//    }

    
    _commbox.tableArray = arrayData;
    
    
    [self.view addSubview:_commbox];
    
    UILabel *university=[[UILabel alloc]initWithFrame:CGRectMake(5, imageView.frame.size.height+city.frame.size.height+20, 50, 20)];
    university.text=@"学校";
    university.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:university];

    //学校
    NSArray   *universityDate =[[NSArray alloc]initWithObjects:@"清华大学",@"北京大学",@"浙江大学",nil];
    _universitycommbox = [[Commbox alloc] initWithFrame:CGRectMake(70, imageView.frame.size.height+city.frame.size.height+20, 140, 100)];
    _universitycommbox.textField.placeholder = @"请选择学校";
    _universitycommbox.tableArray = universityDate;
    
    [self.view addSubview:_universitycommbox];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+city.frame.size.height*2+40, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"下一步" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];


}

//注册账号
- (void)next{
    if(!self.isEmpty){
        DDRegisterFinishController *personsign=[[DDRegisterFinishController alloc] init:_username password:_password city:_commbox.textField.text university:_universitycommbox.textField.text];
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
    if (_commbox.textField.text.length == 0 || _universitycommbox.textField.text.length == 0) {
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



@end
