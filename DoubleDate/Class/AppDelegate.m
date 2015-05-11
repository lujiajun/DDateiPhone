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

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"

#import "AppDelegate+EaseMob.h"
#import "AppDelegate+UMeng.h"

#import "AWSCore/AWSCore.h"
#import "AliCloudController.h"
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import <SMS_SDK/SMS_SDK.h>
@interface AppDelegate ()

@property (nonatomic, readonly) NSMutableArray *tableRows;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _connectionState = eEMConnectionConnected;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    //注册mob 短信服务注册
    
    [SMS_SDK registerApp:@"75058c79bdb6" withSecret:@"82b79b974cc87fc82a831e26909e2073"];
    
    //mob share功能注册
    [ShareSDK registerApp:@"7591dedfa998"];
    //添加微信应用 注册网址 http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wxa89a834f7feabaed"
                           wechatCls:[WXApi class]];
    //微信登陆的时候需要初始化
    [ShareSDK connectWeChatWithAppId:@"wxa89a834f7feabaed"
                           appSecret:@"b7fb9ce3d0660154d7e97d88b9e8e3dd"
                           wechatCls:[WXApi class]];
    //链接短信
    [ShareSDK connectSMS];
    //连接邮件
    [ShareSDK connectMail];
    
    //auto login
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
//   [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(232, 85, 70, 1)];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(232, 79, 60, 1)];
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:RGBACOLOR(245, 245, 245, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@ "HelveticaNeue-CondensedBlack" size:18.0], NSFontAttributeName, nil]];
    }
  
    
    // 环信UIdemo中有用到友盟统计crash，您的项目中不需要添加，可忽略此处。
    [self setupUMeng];
    
    // 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    //init aws
        AWSStaticCredentialsProvider *credentialsProvider =[[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"AKIAJ7I6JER4GHTKYIVQ" secretKey:@"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"];
    
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1
                                                                             credentialsProvider:credentialsProvider];
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;

    
    //init alicloud
    AliCloudController *alicloud=[AliCloudController alloc];
    [alicloud initSdk];
    
    [self loginStateChange:nil];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
}
//分享
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

#pragma mark - private
//登陆状态改变
-(void)loginStateChange:(NSNotification *)notification
{
    UINavigationController *nav = nil;
    
    BOOL isAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
    BOOL loginSuccess = [notification.object boolValue];
    
    if (isAutoLogin || loginSuccess) {//登陆成功加载主窗口控制器
        //加载申请通知的数据
        [[ApplyViewController shareController] loadDataSourceFromLocalDB];
        if (_mainController == nil) {
            _mainController = [[MainViewController alloc] init];
            [_mainController networkChanged:_connectionState];
            nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
        }else{
            nav  = _mainController.navigationController;
        }
        
    }else{//登陆失败加载登陆页面控制器
        _mainController = nil;
        LoginViewController *loginController = [[LoginViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:loginController];
        loginController.title = NSLocalizedString(@"AppName", @"DDate");
        //loginController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"login"]];
        
    }
    
    //设置7.0以下的导航栏
    if ([UIDevice currentDevice].systemVersion.floatValue < 7.0){
        nav.navigationBar.barStyle = UIBarStyleDefault;
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"titleBar"]
                                forBarMetrics:UIBarMetricsDefault];
        
        [nav.navigationBar.layer setMasksToBounds:YES];
    }
    
    self.window.rootViewController = nav;
    
//    [nav setNavigationBarHidden:YES];
//    [nav setNavigationBarHidden:NO];
}

@end
