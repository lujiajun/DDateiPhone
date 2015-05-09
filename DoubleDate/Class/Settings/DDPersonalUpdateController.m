//
//  PushNotificationViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-7-21.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//


#import "DDPersonalUpdateController.h"
#import "IndexViewController.h"
#import "AliCloudController.h"
#import "DDUserDAO.h"
#import "AWSDynamoDB_DDUser.h"
#import "NewSettingViewController.h"



@interface DDPersonalUpdateController ()
{
    
}


@property (strong,nonatomic)  NSString *username;
@property (strong,nonatomic)  NSString *password;

@property (strong, nonatomic) NSString *grade;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *school;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *university;
@property (strong,nonatomic)  UITextField *nicknamevalue;
@property (strong,nonatomic)  UITextField *gendervalue;
@property (strong,nonatomic) UITextField *gradevalue;
@property (strong,nonatomic) UITextField *birdatevalue;
@property (strong,nonatomic) UITextField *universityvalue;
@property (strong,nonatomic) UITextField *cityvalue;
@property (strong,nonatomic) UITextField *hobbiesvalue;
@property (strong,nonatomic) UITextField *signvalue;
@property (strong,nonatomic) UILabel *nickname;
@property (strong,nonatomic) NSString *picpath;



@end

@implementation DDPersonalUpdateController

- (id)init:(NSString *)username password:(NSString *)password city:(NSString *)city university:(NSString *)university{
    _username=username;
    _password=password;
    _city=city;
    _university=university;
    return self;
}

- (id)init:(NSString *)nickname gender:(NSString *)gender grade:(NSString *)grade university:(NSString *)university city:(NSString *)city{
    _nickname.text=nickname;
    _gendervalue.text=gender;
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"注册信息修改";

    //学校
    UILabel *university=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+10, self.view.frame.origin.y+20, 60, 30)];
    university.text=@"学校:";
    university.textAlignment=NSTextAlignmentLeft;
    university.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:university];
    _universityvalue=[[UITextField alloc]initWithFrame:CGRectMake(university.frame.origin.x+50, self.view.frame.origin.y+20, 180, 30)];
    [_universityvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _universityvalue.text=[IndexViewController instanceDDuser].university;
    _universityvalue.textAlignment=NSTextAlignmentLeft;
    _universityvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_universityvalue];
    
    //城市
    UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(10, university.frame.origin.y+40, 60, 30)];
    city.text=@"城市:";
    city.font=[UIFont fontWithName:@"Helvetica" size:12];
    city.textAlignment=NSTextAlignmentLeft;
    [self.view addSubview:city];
    _cityvalue=[[UITextField alloc]initWithFrame:CGRectMake(city.frame.origin.x+50, university.frame.origin.y+40, 180, 30)];
    _cityvalue.text=[IndexViewController instanceDDuser].city;
    [_cityvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _cityvalue.textAlignment=NSTextAlignmentLeft;
    _cityvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_cityvalue];
    
    //年级
//    UILabel *grade=[[UILabel alloc]initWithFrame:CGRectMake(10, city.frame.origin.y+40, 60, 30)];
//    grade.text=@"年级:";
//    grade.textAlignment=NSTextAlignmentLeft;
//    grade.font=[UIFont fontWithName:@"Helvetica" size:12];
//    [self.view addSubview:grade];
//    _gradevalue=[[UITextField alloc]initWithFrame:CGRectMake(grade.frame.origin.x+50, city.frame.origin.y+40, 180, 30)];
//    [_gradevalue setBorderStyle:UITextBorderStyleRoundedRect];
//    _gradevalue.placeholder=[IndexViewController instanceDDuser].grade;
//    _gradevalue.textAlignment=NSTextAlignmentLeft;
//    _gradevalue.font=[UIFont fontWithName:@"Helvetica" size:12];
//    [self.view addSubview:_gradevalue];
    
    //性别
    UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(10, city.frame.origin.y+40, 60, 30)];
    gender.text=@"性别:";
    gender.textAlignment=NSTextAlignmentLeft;
    gender.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:gender];
    _gendervalue=[[UITextField alloc]initWithFrame:CGRectMake(city.frame.origin.x+50, city.frame.origin.y+40, 180, 30)];
    _gendervalue.text=[IndexViewController instanceDDuser].gender;
    [_gendervalue setBorderStyle:UITextBorderStyleRoundedRect];
    _gendervalue.textAlignment=NSTextAlignmentLeft;
    _gendervalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_gendervalue];
    
    
    //出生日期
    UITextField *birdate=[[UITextField alloc]initWithFrame:CGRectMake(10, gender.frame.origin.y+40, 60, 30)];
    birdate.text=@"出生日期:";
    birdate.textAlignment=NSTextAlignmentLeft;
    birdate.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:birdate];
    _birdatevalue=[[UITextField alloc]initWithFrame:CGRectMake(gender.frame.origin.x+50, gender.frame.origin.y+40, 180, 30)];
    _birdatevalue.text=[IndexViewController instanceDDuser].birthday;
    _birdatevalue.textAlignment=NSTextAlignmentLeft;
    [_birdatevalue setBorderStyle:UITextBorderStyleRoundedRect];
    _birdatevalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_birdatevalue];
    
    //爱好
    UITextField *hobbies=[[UITextField alloc]initWithFrame:CGRectMake(10, birdate.frame.origin.y+40, 60, 30)];
    hobbies.text=@"爱好:";
    hobbies.textAlignment=NSTextAlignmentLeft;
    hobbies.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:hobbies];
    _hobbiesvalue=[[UITextField alloc]initWithFrame:CGRectMake(birdate.frame.origin.x+50, birdate.frame.origin.y+40, 180, 30)];
    _hobbiesvalue.text=[IndexViewController instanceDDuser].hobbies;
    _hobbiesvalue.textAlignment=NSTextAlignmentLeft;
    [_hobbiesvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _hobbiesvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_hobbiesvalue];
    
    //签名
    UITextField *sign=[[UITextField alloc]initWithFrame:CGRectMake(10, hobbies.frame.origin.y+40, 60, 30)];
    sign.text=@"个性签名:";
    sign.textAlignment=NSTextAlignmentLeft;
    sign.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:sign];
    _signvalue=[[UITextField alloc]initWithFrame:CGRectMake(hobbies.frame.origin.x+50, hobbies.frame.origin.y+40, 180, 30)];
    _signvalue.text=[IndexViewController instanceDDuser].sign;
    _signvalue.textAlignment=NSTextAlignmentLeft;
    [_signvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _signvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [self.view addSubview:_signvalue];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, sign.frame.origin.y+40, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(updateDDUser) forControlEvents:UIControlEventTouchUpInside];

    
    
}

//xiugai账号
- (void)updateDDUser {
	AWSDynamoDB_DDUser *userDynamoDB = [[AWSDynamoDB_DDUser alloc] init];
	DDUser *user = [IndexViewController instanceDDuser];
	user.university = _universityvalue.text == nil ? user.university : _universityvalue.text;
	user.gender = _gendervalue.text == nil ? user.gender : _gendervalue.text;
	user.city = _cityvalue.text == nil ? user.city : _cityvalue.text;
	user.hobbies = _hobbiesvalue.text == nil ? user.hobbies : _hobbiesvalue.text;
	user.sign = _signvalue.text == nil ? user.sign : _signvalue.text;
	user.birthday = _birdatevalue.text == nil ? user.birthday : _birdatevalue.text;

	[userDynamoDB updateDDUser:user];
	//XIUGAI BENDI
	
	[IndexViewController setDDUser:user];
    NewSettingViewController *settings=[NewSettingViewController alloc];
    [settings.tableView reloadData];
    [self.navigationController pushViewController:settings animated:YES];
}
//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_nicknamevalue.text.length == 0 || _gendervalue.text.length == 0) {
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
//    NSLog(@"buttonIndex = [%d]",buttonIndex);
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
        
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
            
        }
        //关闭相册界面
        [picker disablesAutomaticKeyboardDismissal];
        UIImageView *smallimage = [[UIImageView alloc] initWithFrame:
                                   CGRectMake(_nickname.frame.size.width+ _nicknamevalue.frame.size.width+10,10,50,50)];
        
        smallimage.image = image;
        //加在视图中
        [self.view addSubview:smallimage];
        //上传
        AliCloudController *aliCloud=[AliCloudController alloc];
        
        NSString *name= [aliCloud uploadPic:data];
        _picpath=name;
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
