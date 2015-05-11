#import "InviteFriendByDoubleIdController.h"
#import "IndexViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "Util.h"
#import <SMS_SDK/SMS_SDK.h>
#import <ShareSDK/ShareSDK.h>

@implementation InviteFriendByDoubleIdController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"邀请好友";
    UITextField *info=[[UITextField alloc]initWithFrame:CGRectMake(5, 20, self.view.frame.size.width-10, 15)];
    info.font=[UIFont fontWithName:@"Helvetica" size:12];
    info.text=@"快快邀请好友下载Double Date!";
    
    [self.view addSubview:info];
    
    UITextField *info1=[[UITextField alloc]initWithFrame:CGRectMake(5, info.frame.origin.y+info.frame.size.height+20, self.view.frame.size.width-10, 15)];
    info1.text=@"分享Double号,加好友";
     info1.textColor=[UIColor redColor];
    [self.view addSubview:info1];
    
    UITextField *info2=[[UITextField alloc]initWithFrame:CGRectMake(10, info1.frame.origin.y+info1.frame.size.height+20, self.view.frame.size.width-20, 60)];

    info2.text=    [Util str1:@"你当前的double号是:" appendStr2:IndexViewController.instanceDDuser.UID];
    info2.textAlignment=NSTextAlignmentCenter;
    info2.backgroundColor= RGBACOLOR(232, 85, 70, 1);
    [self.view addSubview:info2];
    
    UITextField *info3=[[UITextField alloc]initWithFrame:CGRectMake(5, info2.frame.origin.y+info1.frame.size.height+60, self.view.frame.size.width-20, 15)];
    info3.text=@"点击图标,邀请好友:";
    info3.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:info3];
    
    
    UIButton *weixin=[[UIButton alloc]initWithFrame:CGRectMake(40, info3.frame.origin.y+25, 40, 40)];
    [weixin setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
    [weixin addTarget:self action:@selector(sendWX) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:weixin];
    
    UIImageView *duanxin=[[UIImageView alloc]initWithFrame:CGRectMake(weixin.frame.origin.x+weixin.frame.size.width+10, info3.frame.origin.y+25, 40, 40)];
    duanxin.image=[UIImage imageNamed:@"weibo"];
    [self.view addSubview:duanxin];
    
    UIImageView *weibo=[[UIImageView alloc]initWithFrame:CGRectMake(duanxin.frame.origin.x+duanxin.frame.size.width+10, info3.frame.origin.y+25, 40, 40)];
    weibo.image=[UIImage imageNamed:@"email"];
    [self.view addSubview:weibo];
    
    UIButton *mail=[[UIButton alloc]initWithFrame:CGRectMake(weibo.frame.origin.x+weibo.frame.size.width+10, info3.frame.origin.y+25, 40, 40)];
    [mail setBackgroundImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
//    [mail addTarget:_contactsVC action:@selector(addFriendAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mail];
    
    
}

-(void) sendWX{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"png"];
    
    //构造分享内容
    id<ISSContainer> publishContent = [ShareSDK content:@"welcome to double date"
                                       defaultContent:@"测试from double date"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.mob.com"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];

    [self.navigationController popToRootViewControllerAnimated:NO];


}



@end