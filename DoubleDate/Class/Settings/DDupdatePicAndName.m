
#include "DDupdatePicAndName.h"
#import "Constants.h"
#import "AliCloudController.h"
#import "IndexViewController.h"
#import "DDUserDAO.h"
#import "PasswordUpdateView.h"
#import "NewSettingViewController.h"
#import "AWSDynamoDB_DDUser.h"
#import "UIImageView+EMWebCache.h"
#import "Util.h"
#import "DDDataManager.h"
@interface DDupdatePicAndName ()
@property(strong,nonatomic) UIImageView *imgHead;
@property (strong,nonatomic) NSString *picpath;
@property(strong,nonatomic)  NSData *data;
@property(strong,nonatomic)  NSString *username;
@property(strong,nonatomic) UITextField *nickvalue;
@end

@implementation DDupdatePicAndName

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _username=[DDDataManager sharedManager].user.nickName;
    
    self.title = @"修改头像";
    //touxiang
 
 
    _imgHead=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, 10, 100, 100)];

    [_imgHead sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:[DDDataManager sharedManager].user.picPath]]];
    _imgHead.layer.masksToBounds =YES;
    _imgHead.layer.cornerRadius =50;

    [_imgHead setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:_imgHead];
    
    //UITUTTON
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(10,_imgHead.frame.origin.y+_imgHead.frame.size.height+20 , self.view.frame.size.width-20, 30)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"从本地图片中选择头像" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //
    UIButton *updatepasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(10,registerButton.frame.origin.y+registerButton.frame.size.height+20 , self.view.frame.size.width-20, 30)];
    updatepasswordButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [updatepasswordButton setTitle:@"修改密码" forState:UIControlStateNormal];
    [self.view addSubview:updatepasswordButton];
    [updatepasswordButton addTarget:self action:@selector(passwordclick) forControlEvents:UIControlEventTouchUpInside];
    //nicheng
    UILabel *nick=[[UILabel alloc]initWithFrame:CGRectMake(10, updatepasswordButton.frame.origin.y+updatepasswordButton.frame.size.height+20, 30, 30)];
    nick.text=@"昵称:";
    nick.font=[UIFont fontWithName:@"Helvetica" size:12];
    nick.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:nick];
    _nickvalue=[[UITextField alloc]initWithFrame:CGRectMake(40,updatepasswordButton.frame.origin.y+updatepasswordButton.frame.size.height+20, self.view.frame.size.width-40, 30)];
    _nickvalue.text=_username;
    [_nickvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _nickvalue.textAlignment=NSTextAlignmentLeft;
    _nickvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_nickvalue];
    //UITUTTON
    UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(10,nick.frame.origin.y+nick.frame.size.height+20 , self.view.frame.size.width-20, 30)];
    save.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [save setTitle:@"保存修改" forState:UIControlStateNormal];
    [self.view addSubview:save];
    [save addTarget:self action:@selector(updateNick) forControlEvents:UIControlEventTouchUpInside];
    //
   

    

}

-(void) passwordclick{
    PasswordUpdateView *ps=[PasswordUpdateView alloc];
    [self.navigationController pushViewController:ps animated:YES];
    
}

//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_nickvalue.text.length == 0) {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message: @"Please input your nickname"
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
    }
    
    
    return ret;
}

//注册账号
- (void)updateNick{
    if(![self isEmpty]){
        DDUser *user=[DDDataManager sharedManager].user;
        user.nickName=_nickvalue.text;
       
        
        [self showHint:@"修改成功"];
        
        [self.navigationController popToRootViewControllerAnimated:NO];

        [[DDDataManager sharedManager] saveUser:user];
        
        if(_picpath!=nil){
            user.picPath=_picpath;
            //删除原图
            //OSS上传图片
            if(self.data!=nil){
                AliCloudController *aliCloud=[AliCloudController alloc];
                [aliCloud updateHeadPic:self.data name:self.picpath];
                
            }
        }

    }
    
}

-(void) btnClick:(UITapGestureRecognizer *)gestureRecognizer{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地相簿",nil];
    [actionSheet showInView:self.view];
    //    [actionSheet release];
}

#pragma mark -
#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://照相机
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            [self presentModalViewController:imagePicker animated:YES];
            //            [imagePicker release];
        }
            break;
        case 1://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            [self presentModalViewController:imagePicker animated:YES];
            //            [imagePicker release];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma UIImagePickerController Delegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        
        if (UIImagePNGRepresentation(image) == nil)
        {
            _data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            _data = UIImagePNGRepresentation(image);
            
        }
        //关闭相册界面
        [picker dismissModalViewControllerAnimated:YES];
//        UIImageView *smallimage = [[UIImageView alloc] initWithFrame:
//                                   CGRectMake(_imgHead.frame.origin.x,_imgHead.frame.origin.y,_imgHead.frame.size.width,_imgHead.frame.size.height)];
//        
//        smallimage.layer.masksToBounds =YES;
//        smallimage.layer.cornerRadius =50;
//        smallimage.image = image;
        _imgHead.image=image;
        //加在视图中
//        [self.view addSubview:smallimage];
        //上传
        
        _picpath=[[DDDataManager sharedManager].user.UID stringByAppendingString:@"_head_pic" ];
        
        
    }
    
}

@end