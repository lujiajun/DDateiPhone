#import "PasswordUpdateView.h"
#import "IndexViewController.h"
#import "Util.h"
#import "AWSDynamoDB_DDUser.h"
#import "SettingsViewController.h"
@interface PasswordUpdateView()

@property(strong,nonatomic)  UITextField *oldText;
@property(strong,nonatomic)  UITextField *passText;
@property(strong,nonatomic)  UITextField *confirmText;


@end

@implementation PasswordUpdateView


- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel *old=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
    old.text=@"原密码";
    old.font=[UIFont fontWithName:@"Helvetica" size:12];
    
    _oldText=[[UITextField alloc]initWithFrame:CGRectMake(old.frame.origin.x+old.frame.size.width, old.frame.origin.y, self.view.frame.size.width-old.frame.size.width-10, old.frame.size.height)];
    [_oldText setBorderStyle:UITextBorderStyleRoundedRect];
    _oldText.textAlignment=NSTextAlignmentLeft;
    _oldText.placeholder=@"原密码";
    _oldText.font=[UIFont fontWithName:@"Helvetica" size:12];
    
    [self.view addSubview:old];
    [self.view addSubview:_oldText];
    
    UILabel *new=[[UILabel alloc] initWithFrame:CGRectMake(10, old.frame.origin.y+old.frame.size.height+5, old.frame.size.width, old.frame.size.height)];
    new.text=@"新密码";
    new.font=[UIFont fontWithName:@"Helvetica" size:12];
    
    _passText=[[UITextField alloc]initWithFrame:CGRectMake(new.frame.origin.x+new.frame.size.width, new.frame.origin.y, self.view.frame.size.width-new.frame.size.width-10, new.frame.size.height)];
    [_passText setBorderStyle:UITextBorderStyleRoundedRect];
    _passText.textAlignment=NSTextAlignmentLeft;
    _passText.placeholder=@"新密码";
    _passText.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:new];
    [self.view addSubview:_passText];
    
    
    UILabel *newConfirm=[[UILabel alloc] initWithFrame:CGRectMake(10, new.frame.origin.y+new.frame.size.height+5, new.frame.size.width, old.frame.size.height)];
    newConfirm.text=@"新密码确认";
    newConfirm.font=[UIFont fontWithName:@"Helvetica" size:12];
    
    _confirmText=[[UITextField alloc]initWithFrame:CGRectMake(newConfirm.frame.origin.x+newConfirm.frame.size.width, newConfirm.frame.origin.y, self.view.frame.size.width-newConfirm.frame.size.width-10, newConfirm.frame.size.height)];
    [_confirmText setBorderStyle:UITextBorderStyleRoundedRect];
    _confirmText.textAlignment=NSTextAlignmentLeft;
    _confirmText.placeholder=@"新密码确认";
    _confirmText.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:newConfirm];
    [self.view addSubview:_confirmText];
    
    UIButton *update = [[UIButton alloc] initWithFrame:CGRectMake(0, newConfirm.frame.origin.y+newConfirm.frame.size.height+5, self.view.frame.size.width, 30)];
    update.backgroundColor=[UIColor redColor];
    [update setTitle:@"登录" forState:UIControlStateNormal];
    [self.view addSubview:update];
    [update addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    

}

//登陆账号
- (void)doLogin {
    if (![self isEmpty]) {
        [self.view endEditing:YES];
        //支持是否为中文
        if ([_passText.text isChinese]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"login.nameNotSupportZh", @"Name does not support Chinese")
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
        //修改环信
        DDUser *user=[IndexViewController instanceDDuser];
        if([Util updatePassword:_confirmText.text username:user.UID oldpassword:user.password]){
            //修改数据库
            
            user.password=_confirmText.text;
            AWSDynamoDB_DDUser  *awsdao=[[AWSDynamoDB_DDUser alloc]init];
            [awsdao updateDDUser:user];
            [IndexViewController setDDUser:user];
            //退出登录
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"prompt", @"prompt")
                                  message:@"请重新登录"
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            SettingsViewController *setting =[SettingsViewController alloc];
            [setting logoutAction];
            
        }{
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"prompt", @"prompt")
                                  message:@"工程师和老板娘跑啦，暂时不提供修改密码服务哦，请联系工作人员"
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
  
        }
        //#endif
    }
}


//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if(_oldText.text.length==0 || _passText.text.length==0 || _confirmText.text.length==0)
    {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:@"请输入原有密码和新密码"
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
        return  ret;
    }
    //老密码验证
//    NSLog([IndexViewController instanceDDuser].password);
    if(![_oldText.text isEqualToString:[IndexViewController instanceDDuser].password]){
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:@"原密码输入错误哦，请检查后重新输入啦"
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];

        return ret;

    }
    //新密码验证一致
    if(![_passText.text isEqualToString:_confirmText.text]){
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:@"新密码两次输入都不一致哦，太马虎啦，请重新输入"
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
        

    }
    
    return ret;
}


@end