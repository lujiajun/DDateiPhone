
#include "DDupdatePicAndName.h"
#import "Constants.h"
#import "AliCloudController.h"
#import "IndexViewController.h"
#import "DDUserDAO.h"

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
    _username=[IndexViewController instanceDDuser].nickName;
    
    self.title = @"修改头像";
    //touxiang
    UIImage *img=[UIImage alloc];
    if([IndexViewController instanceDDuser] && [IndexViewController instanceDDuser].picPath){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:[IndexViewController instanceDDuser].picPath]]];
        img = [UIImage imageWithData:data];
    }else {
        img=[UIImage imageNamed:@"Logo_new.png"];
    }
    _imgHead=[[UIImageView alloc] initWithImage:img];
    _imgHead.layer.masksToBounds =YES;
    _imgHead.layer.cornerRadius =50;
    _imgHead.frame=CGRectMake(self.view.frame.size.width/2-50, 10, 100, 100);
    [_imgHead setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:_imgHead];
    
    //UITUTTON
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(10,_imgHead.frame.origin.y+_imgHead.frame.size.height+20 , self.view.frame.size.width-20, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"从本地图片中选择头像" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //
    UIButton *updatepasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(10,registerButton.frame.origin.y+registerButton.frame.size.height+20 , self.view.frame.size.width-20, 30)];
    updatepasswordButton.backgroundColor=[UIColor redColor];
    [updatepasswordButton setTitle:@"修改密码" forState:UIControlStateNormal];
    [self.view addSubview:updatepasswordButton];
//    [registerButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    //nicheng
    UILabel *nick=[[UILabel alloc]initWithFrame:CGRectMake(10, updatepasswordButton.frame.origin.y+updatepasswordButton.frame.size.height+20, 30, 30)];
    nick.text=@"昵称:";
    nick.font=[UIFont fontWithName:@"Helvetica" size:12];
    nick.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:nick];
    _nickvalue=[[UITextField alloc]initWithFrame:CGRectMake(10,updatepasswordButton.frame.origin.y+updatepasswordButton.frame.size.height+20, self.view.frame.size.width-40, 30)];
    _nickvalue.placeholder=_username;
    [_nickvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _nickvalue.textAlignment=NSTextAlignmentLeft;
    _nickvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_nickvalue];
    //UITUTTON
    UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(10,nick.frame.origin.y+nick.frame.size.height+20 , self.view.frame.size.width-20, 30)];
    save.backgroundColor=[UIColor redColor];
    [save setTitle:@"保存修改" forState:UIControlStateNormal];
    [self.view addSubview:save];
    [save addTarget:self action:@selector(updateNick) forControlEvents:UIControlEventTouchUpInside];
    //
   

    

}

//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_nickvalue.text.length == 0) {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:NSLocalizedString(@"register.nicknameandgender", @"Please input your nickname and gender")
                     customizationBlock:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles: nil];
    }
    
    
    return ret;
}


//-(void) registerUser{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(doRegister)
//                                                 name:@"doRegister"
//                                               object:nil];
//    
//    
//    [self showHudInView:self.view hint:NSLocalizedString(@"register.ongoing", @"Is to register...")];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"doRegister" object:@NO];
//    
//    
//    
//}

//注册账号
- (void)updateNick{
    if(![self isEmpty]){
        DDUser *user=[IndexViewController instanceDDuser];
        user.nickName=_nickvalue.text;
        IndexViewController *newSetting=[IndexViewController alloc];
        [newSetting setDDUser:user];
        
        //上传图片
        AliCloudController *aliCloud=[AliCloudController alloc];
        [aliCloud uploadPic:self.data name:self.picpath];
        
        DDBDynamoDB *ddbDynamoDB=[DDBDynamoDB new];
        [ddbDynamoDB updateTable:user];
        //XIUGAI BENDI
        DDUserDAO *dao =[[DDUserDAO alloc]init];
        [dao updateByUID:user];
        
        [self.navigationController popViewControllerAnimated:YES];
        

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
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        
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
        UIImageView *smallimage = [[UIImageView alloc] initWithFrame:
                                   CGRectMake(_imgHead.frame.origin.x,_imgHead.frame.origin.y,_imgHead.frame.size.width,_imgHead.frame.size.height)];
        
        smallimage.image = image;
        //加在视图中
        [self.view addSubview:smallimage];
        //上传
        
        _picpath=[_username stringByAppendingString:@"_head_pic" ];
        
        
    }
    
}

@end