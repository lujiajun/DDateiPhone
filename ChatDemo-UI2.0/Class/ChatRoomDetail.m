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

#import "ApplyViewController.h"
#import "DebugViewController.h"
#import "WCAlertView.h"
#import "AliCloudController.h"
#import "DDBDynamoDB.h"
#import "Constants.h"

#import "ChatRoomDetail.h"
#import "DDBDynamoDB.h"
#import "LocalDbService.h"
#import "EGOImageView.h"
#import "ContactsViewController.h"

@interface ChatRoomDetail ()

@property (strong, nonatomic) UIView *footerView;

@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;
@property(strong,nonatomic) NSMutableArray *datasouce;
@property(strong,nonatomic) DDBDynamoDB *ddbDynamoDB;
@property(strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property(strong,nonatomic) DDUser *uuser1;
@property(strong,nonatomic) DDUser *uuser2;
@property(strong,nonatomic) NSString *motto;
@property(nonatomic) LocalDbService *localDbService;

@end

@implementation ChatRoomDetail


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =_motto;
    self.view.backgroundColor = [UIColor redColor];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UIImageView *bak1=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-10, self.view.frame.size.height/2-80)];
    bak1.backgroundColor=[UIColor whiteColor];
    bak1.layer.masksToBounds =YES;
    bak1.layer.cornerRadius =5;
    [self.view addSubview:bak1];
    [self showUser1:bak1];
     UIImageView *bak2=[[UIImageView alloc]initWithFrame:CGRectMake(5, bak1.frame.origin.y+bak1.frame.size.height+5, self.view.frame.size.width-10, bak1.frame.size.height)];
    bak2.backgroundColor=[UIColor whiteColor];
    bak2.layer.masksToBounds =YES;
    bak2.layer.cornerRadius =5;
    [self showUser2:bak2];
    [self.view addSubview:bak2];
    //buton
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, bak2.frame.origin.y+bak2.frame.size.height+10, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=[UIColor redColor];
    [registerButton setTitle:@"加入聊天室" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void) addUser{
    ContactsViewController *personsign=[[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:personsign animated:YES];

}

-(id) initChatRoom:(DDUser *) uuser1 uuser2:(DDUser *) uuser2 motto:(NSString *) motto{
    _motto=motto;
    //查询
    _uuser1=uuser1;
    
    _uuser2=uuser2;

    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)showUser1:(UIImageView *) bakview{

    EGOImageView *headview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
    if(_uuser1!=nil && _uuser1.picPath !=nil){
        headview.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:_uuser1.picPath]];
    }
    headview.frame=CGRectMake(50, 10, 80, 80);
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =40;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, headview.frame.origin.y+10, 50, 12)];
    nickname.text=_uuser1.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:nickname];
    //性别
    BOOL *isboy=NO;
    if(_uuser1!=nil){
        if(_uuser1.gender==@"Male" || _uuser1.gender==@"男"){
            isboy=YES;
        }
    }
    UIImage *isboyimg;
    if(isboy){
        isboyimg=[UIImage imageNamed:@"sexboy"];
    }else{
        isboyimg=[UIImage imageNamed:@"sexgirl"];
    }
    UIImageView *isboyview=[[UIImageView alloc] initWithImage:isboyimg];
    isboyview.frame=CGRectMake(headview.frame.origin.x+headview.frame.size.width+nickname.frame.size.width+15, headview.frame.origin.y+8, 10, 10);
    [bakview addSubview:isboyview];
    //学校
    UILabel *university=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, nickname.frame.origin.y+nickname.frame.size.height+2, 50, 12)];
    university.text=_uuser1.university;
    university.textAlignment=NSTextAlignmentLeft;
    university.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:university];
    //学校图片
    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
    schoolview.frame=CGRectMake(university.frame.origin.x+university.frame.size.width+15, university.frame.origin.y, 20, 10);
    [bakview addSubview:schoolview];
    //年级
    UILabel *gender=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, university.frame.origin.y+university.frame.size.height+2, 50, 12)];
    gender.text=_uuser1.grade;
    gender.textAlignment=NSTextAlignmentLeft;
    gender.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:gender];
    
    
    //qianming
    
    UIImage *signimg=[UIImage imageNamed:@"infoline"];
    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+20, bakview.frame.size.width-20, 50);
    [bakview addSubview:signview];
    //
    //                UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(5, 50, cell.frame.size.width-20, 50)];
    //                sininfo.text=@"testXXXXXXXXXXXXXXX";
    //                sininfo.textAlignment=NSTextAlignmentLeft;
    //                sininfo.lineBreakMode = UILineBreakModeWordWrap;
    //                sininfo.font=[UIFont fontWithName:@"Helvetica" size:12];
    //                [signview addSubview:sininfo];
    

}

-(void)showUser2:(UIImageView *) bakview{
   
    
    UIImage *user1;
    if(_uuser2!=nil&&_uuser2.picPath!=nil){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:_uuser2.picPath]]];
        user1 = [UIImage imageWithData:data];
    }else{
        user1=[UIImage imageNamed:@"Logo_new"];
    }
    
    UIImageView *headview=[[UIImageView alloc] initWithImage:user1];
    headview.frame=CGRectMake(50, 10, 80, 80);
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =40;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, headview.frame.origin.y+10, 50, 12)];
    nickname.text=_uuser2.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:nickname];
    //性别
    BOOL *isboy=NO;
    if(_uuser1!=nil){
        if(_uuser1.gender==@"Male" || _uuser1.gender==@"男"){
            isboy=YES;
        }
    }
    UIImage *isboyimg;
    if(isboy){
        isboyimg=[UIImage imageNamed:@"sexboy"];
    }else{
        isboyimg=[UIImage imageNamed:@"sexgirl"];
    }
    UIImageView *isboyview=[[UIImageView alloc] initWithImage:isboyimg];
    isboyview.frame=CGRectMake(headview.frame.origin.x+headview.frame.size.width+nickname.frame.size.width+15, headview.frame.origin.y+8, 10, 10);
    [bakview addSubview:isboyview];
    //学校
    UILabel *university=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, nickname.frame.origin.y+nickname.frame.size.height+2, 50, 10)];
    university.text=_uuser2.university;
    university.textAlignment=NSTextAlignmentLeft;
    university.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:university];
    //学校图片
    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
    schoolview.frame=CGRectMake(university.frame.origin.x+university.frame.size.width+15, university.frame.origin.y, 20, 10);
    [bakview addSubview:schoolview];
    //年级
    UILabel *gender=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, university.frame.origin.y+university.frame.size.height+2, 50, 12)];
    gender.text=_uuser2.grade;
    gender.textAlignment=NSTextAlignmentLeft;
    gender.font=[UIFont fontWithName:@"Helvetica" size:12];
    [bakview addSubview:gender];
    
    //qianming
    
    UIImage *signimg=[UIImage imageNamed:@"infoline"];
    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+20, bakview.frame.size.width-20, 50);
    [bakview addSubview:signview];
    
    //                    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(signview.frame.origin.x+5, 100, cell.frame.size.width-20, 50)];
    //                    sininfo.text=@"testXXXXXXXXXXXXXXX";
    //                    sininfo.textAlignment=NSTextAlignmentLeft;
    //                    sininfo.font=[UIFont fontWithName:@"Helvetica" size:12];
    //                    [signview addSubview:sininfo];

    
}

//
//#pragma mark - Table view datasource
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 3;
//}
//
////每行缩进
//-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row ==0) {
//        return 10;
//    }
//    return 0;
//}
//
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    if (indexPath.section == 0) {
//            if (indexPath.row == 0) {
//
//                EGOImageView *headview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
//                if(_uuser1!=nil && _uuser1.picPath !=nil){
//                    headview.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:_uuser1.picPath]];
//                }
//                headview.frame=CGRectMake(50, 10, 80, 80);
//                headview.layer.masksToBounds =YES;
//                headview.layer.cornerRadius =40;
//                [cell.contentView addSubview:headview];
//                
//                //姓名
//                UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, headview.frame.origin.y+10, 50, 12)];
//                nickname.text=_uuser1.nickName;
//                nickname.textAlignment=NSTextAlignmentLeft;
//                nickname.font=[UIFont fontWithName:@"Helvetica" size:12];
//                [cell.contentView addSubview:nickname];
//                //性别
//                BOOL *isboy=NO;
//                if(_uuser1!=nil){
//                    if(_uuser1.gender==@"Male" || _uuser1.gender==@"男"){
//                        isboy=YES;
//                    }
//                    }
//                    UIImage *isboyimg;
//                    if(isboy){
//                        isboyimg=[UIImage imageNamed:@"sexboy"];
//                    }else{
//                        isboyimg=[UIImage imageNamed:@"sexgirl"];
//                    }
//                UIImageView *isboyview=[[UIImageView alloc] initWithImage:isboyimg];
//                isboyview.frame=CGRectMake(headview.frame.origin.x+headview.frame.size.width+nickname.frame.size.width+15, headview.frame.origin.y+8, 10, 10);
//                [cell.contentView addSubview:isboyview];
//                //学校
//                UILabel *university=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, nickname.frame.origin.y+nickname.frame.size.height+2, 50, 12)];
//                university.text=_uuser1.university;
//                university.textAlignment=NSTextAlignmentLeft;
//                university.font=[UIFont fontWithName:@"Helvetica" size:12];
//                [cell.contentView addSubview:university];
//                //学校图片
//                UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//                UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//                schoolview.frame=CGRectMake(university.frame.origin.x+university.frame.size.width+15, university.frame.origin.y, 20, 10);
//                [cell.contentView addSubview:schoolview];
//                //年级
//                UILabel *gender=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, university.frame.origin.y+university.frame.size.height+2, 50, 12)];
//                gender.text=_uuser1.grade;
//                gender.textAlignment=NSTextAlignmentLeft;
//                gender.font=[UIFont fontWithName:@"Helvetica" size:12];
//                [cell.contentView addSubview:gender];
//                
//                
//                //qianming
//                
//                UIImage *signimg=[UIImage imageNamed:@"infoline"];
//                UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
//                signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+5, cell.frame.size.width-10, 50);
//                [cell.contentView addSubview:signview];
////               
////                UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(5, 50, cell.frame.size.width-20, 50)];
////                sininfo.text=@"testXXXXXXXXXXXXXXX";
////                sininfo.textAlignment=NSTextAlignmentLeft;
////                sininfo.lineBreakMode = UILineBreakModeWordWrap;
////                sininfo.font=[UIFont fontWithName:@"Helvetica" size:12];
////                [signview addSubview:sininfo];
//           
//            } else if(indexPath.row==1){
//                    
//                    UIImage *user1;
//                    if(_uuser2!=nil&&_uuser2.picPath!=nil){
//                        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:_uuser2.picPath]]];
//                        user1 = [UIImage imageWithData:data];
//                    }else{
//                        user1=[UIImage imageNamed:@"Logo_new"];
//                    }
//                    
//                    UIImageView *headview=[[UIImageView alloc] initWithImage:user1];
//                    headview.frame=CGRectMake(50, 10, 80, 80);
//                    headview.layer.masksToBounds =YES;
//                    headview.layer.cornerRadius =40;
//                    [cell.contentView addSubview:headview];
//                    
//                    //姓名
//                    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, headview.frame.origin.y+10, 50, 12)];
//                    nickname.text=_uuser2.nickName;
//                    nickname.textAlignment=NSTextAlignmentLeft;
//                    nickname.font=[UIFont fontWithName:@"Helvetica" size:12];
//                    [cell.contentView addSubview:nickname];
//                    //性别
//                    BOOL *isboy=NO;
//                    if(_uuser1!=nil){
//                        if(_uuser1.gender==@"Male" || _uuser1.gender==@"男"){
//                            isboy=YES;
//                        }
//                    }
//                    UIImage *isboyimg;
//                    if(isboy){
//                        isboyimg=[UIImage imageNamed:@"sexboy"];
//                    }else{
//                        isboyimg=[UIImage imageNamed:@"sexgirl"];
//                    }
//                    UIImageView *isboyview=[[UIImageView alloc] initWithImage:isboyimg];
//                    isboyview.frame=CGRectMake(headview.frame.origin.x+headview.frame.size.width+nickname.frame.size.width+15, headview.frame.origin.y+8, 10, 10);
//                    [cell.contentView addSubview:isboyview];
//                    //学校
//                    UILabel *university=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, nickname.frame.origin.y+nickname.frame.size.height+2, 50, 10)];
//                    university.text=_uuser2.university;
//                    university.textAlignment=NSTextAlignmentLeft;
//                    university.font=[UIFont fontWithName:@"Helvetica" size:12];
//                    [cell.contentView addSubview:university];
//                    //学校图片
//                    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//                    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//                    schoolview.frame=CGRectMake(university.frame.origin.x+university.frame.size.width+15, university.frame.origin.y, 20, 10);
//                    [cell.contentView addSubview:schoolview];
//                //年级
//                UILabel *gender=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+10, university.frame.origin.y+university.frame.size.height+2, 50, 12)];
//                gender.text=_uuser2.grade;
//                gender.textAlignment=NSTextAlignmentLeft;
//                gender.font=[UIFont fontWithName:@"Helvetica" size:12];
//                [cell.contentView addSubview:gender];
//                
//                //qianming
//                    
//                    UIImage *signimg=[UIImage imageNamed:@"infoline"];
//                    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
//                    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+5, cell.frame.size.width-10, 50);
//                    [cell.contentView addSubview:signview];
//                    
////                    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(signview.frame.origin.x+5, 100, cell.frame.size.width-20, 50)];
////                    sininfo.text=@"testXXXXXXXXXXXXXXX";
////                    sininfo.textAlignment=NSTextAlignmentLeft;
////                    sininfo.font=[UIFont fontWithName:@"Helvetica" size:12];
////                    [signview addSubview:sininfo];
//
//            
//            }
//        
//        
//    }
//    
//    return cell;
//}
//
//
//- (void)insertTableRow:(DDUser *)tableRow {
//    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
//    [dynamoDBObjectMapper save: tableRow];
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    return 160;
//}
//
//
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissModalViewControllerAnimated:YES];
//}
//
//
//#pragma mark - Table view delegate
//
//
//
//
//#pragma mark - getter
//
//- (UIView *)footerView
//{
//    if (_footerView == nil) {
//        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
//        _footerView.backgroundColor = [UIColor clearColor];
//        
//    }
//    
//    return _footerView;
//}
//
//#pragma mark - action
//
//- (void)autoLoginChanged:(UISwitch *)autoSwitch
//{
//    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:autoSwitch.isOn];
//}
//
//- (void)useIpChanged:(UISwitch *)ipSwitch
//{
//    [[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
//}
//
//- (void)beInvitedChanged:(UISwitch *)beInvitedSwitch
//{
//    //    if (beInvitedSwitch.isOn) {
//    //        self.beInvitedLabel.text = @"允许选择";
//    //    }
//    //    else{
//    //        self.beInvitedLabel.text = @"自动加入";
//    //    }
//    //
//    //    [[EaseMob sharedInstance].chatManager setAutoAcceptGroupInvitation:!(beInvitedSwitch.isOn)];
//}
//


@end
