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
#import "DDDataManager.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

#define  PIC_WIDTH 80
#define  PIC_HEIGHT 80

@interface DDPersonalUpdateController () <UIImagePickerControllerDelegate>
{
    NSLocale *_datelocale;
    UIDatePicker *_datePicker;
}


@property (strong,nonatomic)  UITextField *nicknamevalue;

@property (strong,nonatomic) UITextField *birdatevalue;
@property (strong,nonatomic) UITextField *universityvalue;
@property (strong,nonatomic) UITextField *cityvalue;
@property (strong,nonatomic) UITextField *hobbiesvalue;
@property (strong,nonatomic) UITextField *signvalue;
@property (strong,nonatomic) UILabel *nickname;
@property (strong,nonatomic) NSString *picpath;
@property (strong, nonatomic) UISegmentedControl *genderControl;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *bodyView;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *plusImageView;
@property (strong, nonatomic) NSMutableArray *photoArray;
@end

@implementation DDPersonalUpdateController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.title = @"修改个人资料";
    self.view.backgroundColor = [UIColor whiteColor];
    DDUser* user = [DDDataManager sharedManager].user;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    
    _headerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(_scrollView.frame), 100)];
    _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame) + 10, CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_scrollView.frame))];
    [_scrollView addSubview:_headerView];
    [_scrollView addSubview:_bodyView];

    //学校
    UILabel *university=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 30)];
    university.text=@"学校:";
    university.textAlignment=NSTextAlignmentLeft;
    university.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:university];
    
    _universityvalue=[[UITextField alloc]initWithFrame:CGRectMake(university.frame.origin.x+50, 10, 180, 30)];
    [_universityvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _universityvalue.text= user.university;
    _universityvalue.textAlignment=NSTextAlignmentLeft;
    _universityvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:_universityvalue];
    
    //城市
    UILabel *city=[[UILabel alloc]initWithFrame:CGRectMake(10, university.frame.origin.y+40, 60, 30)];
    city.text=@"城市:";
    city.font=[UIFont fontWithName:@"Helvetica" size:12];
    city.textAlignment=NSTextAlignmentLeft;
    [_bodyView addSubview:city];
    _cityvalue=[[UITextField alloc]initWithFrame:CGRectMake(city.frame.origin.x+50, university.frame.origin.y+40, 180, 30)];
    _cityvalue.text=user.city;
    [_cityvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _cityvalue.textAlignment=NSTextAlignmentLeft;
    _cityvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:_cityvalue];
    
    //性别
    UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(10, city.frame.origin.y+40, 60, 30)];
    gender.text=@"性别:";
    gender.textAlignment=NSTextAlignmentLeft;
    gender.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:gender];
    
    NSArray* genderItems = @[@"男", @"女"];
    _genderControl = [[UISegmentedControl alloc] initWithItems:genderItems];
    _genderControl.frame = CGRectMake(gender.frame.origin.x+50, gender.frame.origin.y, 80, 25);
    _genderControl.selectedSegmentIndex = [user.gender integerValue];
    [_genderControl setEnabled: NO];
    [_bodyView addSubview:_genderControl];
    
    //出生日期
    UITextField *birdate=[[UITextField alloc]initWithFrame:CGRectMake(10, gender.frame.origin.y+40, 60, 30)];
    birdate.text=@"出生日期:";
    birdate.textAlignment=NSTextAlignmentLeft;
    birdate.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:birdate];
    _birdatevalue=[[UITextField alloc]initWithFrame:CGRectMake(gender.frame.origin.x+50, gender.frame.origin.y+40, 180, 30)];
    _birdatevalue.text=user.birthday;
    _birdatevalue.textAlignment=NSTextAlignmentLeft;
    [_birdatevalue setBorderStyle:UITextBorderStyleRoundedRect];
    _birdatevalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:_birdatevalue];
    
    _datePicker = [[UIDatePicker alloc] init];
    // 時區的問題請再找其他協助 不是本篇重點
    _datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    _datePicker.locale = _datelocale;
    _datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    
    // 以下這行是重點 (螢光筆畫兩行) 將 UITextField 的 inputView 設定成 UIDatePicker
    // 則原本會跳出鍵盤的地方 就改成選日期了
    _birdatevalue.inputView = _datePicker;
    
    // 建立 UIToolbar
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    // 選取日期完成鈕 並給他一個 selector
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
                                                                          action:@selector(cancelDatePicker:)];
    // 把按鈕加進 UIToolbar
    toolBar.items = [NSArray arrayWithObject:right];
    // 以下這行也是重點 (螢光筆畫兩行)
    // 原本應該是鍵盤上方附帶內容的區塊 改成一個 UIToolbar 並加上完成鈕
    _birdatevalue.inputAccessoryView = toolBar;
    
    //爱好
    UITextField *hobbies=[[UITextField alloc]initWithFrame:CGRectMake(10, birdate.frame.origin.y+40, 60, 30)];
    hobbies.text=@"爱好:";
    hobbies.textAlignment=NSTextAlignmentLeft;
    hobbies.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:hobbies];
    _hobbiesvalue=[[UITextField alloc]initWithFrame:CGRectMake(birdate.frame.origin.x+50, birdate.frame.origin.y+40, 180, 30)];
    _hobbiesvalue.text=user.hobbies;
    _hobbiesvalue.textAlignment=NSTextAlignmentLeft;
    [_hobbiesvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _hobbiesvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:_hobbiesvalue];
    
    //签名
    UITextField *sign=[[UITextField alloc]initWithFrame:CGRectMake(10, hobbies.frame.origin.y+40, 60, 30)];
    sign.text=@"个性签名:";
    sign.textAlignment=NSTextAlignmentLeft;
    sign.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:sign];
    _signvalue=[[UITextField alloc]initWithFrame:CGRectMake(hobbies.frame.origin.x+50, hobbies.frame.origin.y+40, 180, 30)];
    _signvalue.text=user.sign;
    _signvalue.textAlignment=NSTextAlignmentLeft;
    [_signvalue setBorderStyle:UITextBorderStyleRoundedRect];
    _signvalue.font=[UIFont fontWithName:@"Helvetica" size:12];
    [_bodyView addSubview:_signvalue];
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, sign.frame.origin.y+40, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"修改" forState:UIControlStateNormal];
    [_bodyView addSubview:registerButton];
    [registerButton addTarget:self action:@selector(updateDDUser) forControlEvents:UIControlEventTouchUpInside];
    
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString: @","];
    NSString *photo = [user.photos stringByTrimmingCharactersInSet:cs];
    self.photoArray = [[photo componentsSeparatedByString:@","] mutableCopy];
    
    UIImage *image = [UIImage imageNamed:@"addpic"];
    _plusImageView = [[UIImageView alloc] initWithImage:image];
    _plusImageView.userInteractionEnabled = YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCoverView];
}

- (void) refreshCoverView {
    // reload images
    DDUser* user = [DDDataManager sharedManager].user;
    [[_headerView subviews] enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger p, BOOL* stop) {
        [obj removeFromSuperview];
    }];
    int i = 0;
    for (id element in self.photoArray) {
        if (element != nil && ![element isEqual:@""]) {
            //图片显示
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(PIC_WIDTH * i, 0, PIC_WIDTH, PIC_HEIGHT)];
            
            NSString* url = DD_PHOTO_URL(user.UID, element);
            [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"Logo_new"]];
            
            //获取图片的框架，得到长、宽
            //赋值
            imageView.tag = i;
            //ScrollView添加子视图
            [_headerView addSubview:imageView];
            i++;
        }
    }
    //_headerView.frame = cell.contentView.bounds;
    _headerView.frame = CGRectMake(0, 10, CGRectGetWidth(_scrollView.frame), 100);
    
    _plusImageView.frame = CGRectMake(PIC_WIDTH * i, _scrollView.frame.origin.y, PIC_WIDTH, PIC_HEIGHT);
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick:)];
    [_plusImageView addGestureRecognizer:singleTap];//点击图片事件
    [_headerView addSubview:_plusImageView];
    
    _bodyView.frame = CGRectMake(0, CGRectGetMaxY(_headerView.frame) + 10, CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_scrollView.frame));
}

//xiugai账号
- (void)updateDDUser {
    DDUser* user = [DDDataManager sharedManager].user;
    if (_universityvalue.text.length) {
        user.university = _universityvalue.text;
    }
    user.gender = @(self.genderControl.selectedSegmentIndex);
    if (_cityvalue.text.length) {
        user.city = _cityvalue.text;
    }
    if (_hobbiesvalue.text.length) {
        user.hobbies = _hobbiesvalue.text;
    }
    if (_signvalue.text.length) {
        user.sign = _signvalue.text;
    }
    if (_birdatevalue.text.length) {
        user.birthday = _birdatevalue.text;
    }
    user.photos = [self.photoArray componentsJoinedByString:@","];
    [[DDDataManager sharedManager] saveUser:user];
    
//    NewSettingViewController *settings=[NewSettingViewController alloc];
//    [settings.tableView reloadData];
//    [self.navigationController pushViewController:settings animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_NAME" object:nil];
}
//判断账号和密码是否为空
- (BOOL)isEmpty{
    BOOL ret = NO;
    if (_nicknamevalue.text.length == 0 || _cityvalue.text.length==0 ||_hobbiesvalue.text.length==0 ||_signvalue.text.length==0||_birdatevalue.text.length==0) {
        ret = YES;
        [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                message:@"请完善您的个人信息，我们才能更快捷给您分配优质好友哦"
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


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转成NSData
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1.0);
        } else {
            data = UIImagePNGRepresentation(image);
        }
        //关闭相册
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        //先显示，在上传
        //获得addPicArry中得最大值
        NSString *picname = [self getNewPicName];
        if (picname.length) {
            DDUser* user = [DDDataManager sharedManager].user;
            [SVProgressHUD show];
            [[DDDataManager sharedManager].aliCloud asynUploadPic:data key: DD_PHOTO_KEY(user.UID, picname) callback:^(BOOL sucess, NSError* e) {
                if (sucess) {
                    [self.photoArray addObject:picname];
                    [self refreshCoverView];
                    [SVProgressHUD dismiss];
                    return ;
                }
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat: @"上传到阿里云失败: %@", e]];
            }];
        }
    }
}

//最大值加1
- (NSString *)getNewPicName {
    NSComparator cmptr = ^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSArray *array = [self.photoArray sortedArrayUsingComparator:cmptr];
    return [NSString stringWithFormat:@"%d", [array.lastObject intValue] + 1];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) cancelDatePicker: (id) sender {
    if ([self.view endEditing:NO]) {
        // 以下幾行是測試用 可以依照自己的需求增減屬性
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM/dd" options:0 locale:_datelocale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:_datelocale];
        // 將選取後的日期 填入 UITextField
        _birdatevalue.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:_datePicker.date]];
    }
}

@end
