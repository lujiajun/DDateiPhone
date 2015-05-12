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

#import "PersonInfoController.h"


#import "ApplyViewController.h"
#import "PushNotificationViewController.h"
#import "BlackListViewController.h"
#import "DebugViewController.h"
#import "WCAlertView.h"
#import "AliCloudController.h"
#import "Constants.h"
#import "DDRegisterFinishController.h"
#import "DDPersonalUpdateController.h"
#import "DDHeadPicUpdate.h"
#import "IndexViewController.h"
#import "HelpViewController.h"
#import "DDUserDAO.h"
#import "UIImageView+EMWebCache.h"
#import "Constants.h"
#import "DDupdatePicAndName.h"
#import "Util.h"
#import "IndexViewController.h"

@interface PersonInfoController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;
@property(nonatomic)  NSUInteger *picnumber;
@property(strong,nonatomic) NSMutableArray *addedPicArray;
@property(strong,nonatomic) AliCloudController *aliCloud;
@property(strong,nonatomic) NSString *loginname;
@property(strong,nonatomic) UIImageView *plusImageView;
@property(strong,nonatomic) DDUser *user;

@end

@implementation PersonInfoController

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;


#define  PIC_WIDTH 120
#define  PIC_HEIGHT 120




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(id) initUser:(DDUser *)user{
    _user=user;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    self.tableView.tableFooterView = self.footerView;
    
    if(_aliCloud==nil){
        _aliCloud=[AliCloudController alloc];
        [_aliCloud initSdk];
        
    }
   
    if(_plusImageView==nil){
        //添加按钮
        UIImage *image = [UIImage imageNamed:@"addpic"];
        //图片显示
        _plusImageView = [[UIImageView alloc] initWithImage:image];
        _plusImageView.userInteractionEnabled=YES;
        
    }
    //出事scroview
    [self refreshScrollView];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (UISwitch *)autoLoginSwitch
{
    if (_autoLoginSwitch == nil) {
        _autoLoginSwitch = [[UISwitch alloc] init];
        [_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _autoLoginSwitch;
}

- (UISwitch *)beInvitedSwitch
{
    
    return _beInvitedSwitch;
}

- (UILabel *)beInvitedLabel
{
    if (_beInvitedLabel == nil) {
        _beInvitedLabel = [[UILabel alloc] init];
        _beInvitedLabel.backgroundColor = [UIColor clearColor];
        _beInvitedLabel.font = [UIFont systemFontOfSize:12.0];
        _beInvitedLabel.textColor = [UIColor grayColor];
    }
    
    return _beInvitedLabel;
}

-(void) refreshScrollView{
    
    if(_scrollView==nil){
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 400, 130)];
    }
    
    //循环执行，有多少张图片，执行几次
    _scrollView.scrollEnabled=YES;
    if(_addedPicArray.count>1){
        
        CGSize contentSize=CGSizeMake(PIC_WIDTH*(_addedPicArray.count+1), 130);
        //shezhi滚动范围
        _scrollView.contentSize=contentSize;
        
    }else{
        
        CGSize contentSize=CGSizeMake(PIC_WIDTH*(_addedPicArray.count+2), 130);
        //shezhi滚动范围
        _scrollView.contentSize=contentSize;
    }
    [_scrollView setUserInteractionEnabled:YES];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
            
        case 3:
            
            return  2;
            
            break;
            
            
        default:
            
            return 1;
            
            break;
            
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    switch (indexPath.section) {
            
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            //background
            UIImage *bak=[UIImage imageNamed:@"settingback"];
            UIImageView *bakview=[[UIImageView alloc] initWithImage:bak];
            bakview.frame=CGRectMake(0, 0, cell.frame.size.width, 160);
            [cell.contentView addSubview:bakview];
            
            
            UIImageView *imgHead=[[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width/2-50, 10, 100, 100)];
            [imgHead sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:_user.picPath]] placeholderImage:[UIImage imageNamed:@"80" ]];
            imgHead.layer.cornerRadius =50;
            imgHead.layer.masksToBounds = YES;
            [imgHead setContentMode:UIViewContentModeScaleToFill];
            
            [bakview addSubview:imgHead] ;
            //添加nickname
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2-35, 112, 80, 20)];
            mylable.text=_user.nickName;
            mylable.textAlignment=NSTextAlignmentCenter;
            mylable.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:mylable];
            //添加性别图标
            NSString *sex;
            if([_user.gender isEqualToString: @"男" ]|| [_user.gender isEqualToString: @"Male"]){
                sex=@"sexbox";
            }else{
                sex=@"sexgirl";
            }
            UIImage *seximg=[UIImage imageNamed:sex];
            UIImageView *sexview=[[UIImageView alloc] initWithImage:seximg];
            sexview.frame=CGRectMake(mylable.frame.origin.x+mylable.frame.size.width, mylable.frame.origin.y, 10, 10);
            [bakview addSubview:sexview];
            //添加double 号
            UILabel *doubledate=[[UILabel alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width/2-35, 134, 150, 20)];
            
            doubledate.text=[Util str1:@"Double号:" appendStr2:_user.UID];
            //            NSLog(_user.UID);
            doubledate.textAlignment=NSTextAlignmentLeft;
            doubledate.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:doubledate];
        }
            break;
            
            
        case 1:
        {
            // 1.创建UIScrollView
            
            if(_addedPicArray.count==0){
                UILabel * info=[[UILabel alloc]initWithFrame:CGRectMake(cell.frame.size.width/2-50, cell.frame.size.height/2, 100, 30)];
                info.text=@"用户暂时没有上传照片哟";
                [cell.contentView addSubview:info];
              
            }else{
                int i=0;
                for (id element in _addedPicArray) {
                    if(element!=nil&&![element isEqual:@""]){
                        
                        //图片显示
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.origin.x+PIC_WIDTH*i,cell.frame.origin.y, PIC_WIDTH, PIC_HEIGHT)];
                        
                        [imageView sd_setImageWithURL:[NSURL URLWithString: [[DDPicPath stringByAppendingString:[_loginname stringByAppendingString:@"_photo_"]] stringByAppendingString:element]]placeholderImage:[UIImage imageNamed:@"Logo_new"]];
                        
                        //获取图片的框架，得到长、宽
                        //赋值
                        imageView.tag = i;
                        //ScrollView添加子视图
                        [_scrollView addSubview:imageView];
                        i++;
                        
                    }
                    
                }
                    
                
                
            }
            
            
            [cell.contentView addSubview:_scrollView];
            
            break;
        }
        case 2:{
            //background
            UIImage *bak=[UIImage imageNamed:@"files"];
            UIImageView *bakview=[[UIImageView alloc] initWithImage:bak];
            bakview.frame=CGRectMake(0, cell.frame.origin.y+5, cell.frame.size.width, 140);
            [cell.contentView addSubview:bakview];
            
            UILabel *mylable=[[UILabel alloc]initWithFrame:CGRectMake(30, bakview.frame.origin.y+5, 100, 20)];
            
            mylable.text=[Util str1:@"城市：   " appendStr2:_user.city==nil?@"请编辑城市信息":_user.city];
            mylable.textAlignment=NSTextAlignmentLeft;
            mylable.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:mylable];
            //isdoubled
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:@"confirm.png"];
            imageView.frame = CGRectMake(140, mylable.frame.origin.y, 20, 15);
            [bakview addSubview:imageView];
            
            //BIANJI
            UIImageView *bianjiView = [[UIImageView alloc] init];
            bianjiView.image = [UIImage imageNamed:@"bianji.png"];
            bianjiView.frame = CGRectMake(cell.frame.size.width-30, mylable.frame.origin.y, 15, 15);
            [bakview addSubview:bianjiView];
            
            UILabel *university=[[UILabel alloc]initWithFrame:CGRectMake(30, mylable.frame.origin.y+20, 200, 20)];
            university.text=[Util str1:@"学校：   " appendStr2:_user.university==nil?@"请编辑学校信息":_user.university];
            university.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:university];
            
            //            UILabel *school=[[UILabel alloc]initWithFrame:CGRectMake(30, city.frame.origin.y+20, 200, 20)];
            //            if(_user!=nil&&_user.city!=nil){
            //                school.text=[@"年级：   " stringByAppendingString:_user.grade];
            //            }
            //
            //            school.font=[UIFont fontWithName:@"Helvetica" size:12];
            //            [bakview addSubview:school];
            
            UILabel *gender=[[UILabel alloc]initWithFrame:CGRectMake(30, university.frame.origin.y+20, 200, 20)];
            gender.text=[Util str1:@"性别：   " appendStr2:_user.gender==nil?@"请编辑性别信息":_user.gender];
            
            gender.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:gender];
            
            
            UILabel *birth=[[UILabel alloc]initWithFrame:CGRectMake(30, gender.frame.origin.y+20, 200, 20)];
            
            birth.text=[Util str1:@"BIRTH：   " appendStr2:_user.birthday==nil?@"请编辑出生日期信息":_user.birthday];
            
            birth.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:birth];
            
            UILabel *intre=[[UILabel alloc]initWithFrame:CGRectMake(30, birth.frame.origin.y+20, 200, 20)];
            intre.text=[Util str1:@"爱好：   " appendStr2:_user.hobbies==nil?@"请编辑爱好信息":_user.hobbies];
            intre.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:intre];
            
            UILabel *sign=[[UILabel alloc]initWithFrame:CGRectMake(30, intre.frame.origin.y+20, 200, 20)];
            sign.text=[Util str1:@"签名：   " appendStr2:_user.sign==nil?@"请编辑签名信息":_user.sign];
            sign.font=[UIFont fontWithName:@"Helvetica" size:12];
            [bakview addSubview:sign];
            //            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
            //            cell.textLabel.text=@"CESHI";
            //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        }
         
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0)
        return 0;
    else
        return 5.0f;
}

- (void)insertTableRow:(DDUser *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [dynamoDBObjectMapper save: tableRow];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1){
        return 130;
    }
    return 160;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

@end
