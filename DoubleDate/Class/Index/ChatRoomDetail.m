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
#import "Constants.h"
#import "ChatRoomDetail.h"
#import "ContactsViewController.h"
#import "Contact4GroupAddViewController.h"
#import "ContactSelectionViewController.h"
#import "IndexViewController.h"
#import "ChatRoom2DAO.h"
#import "UIImageView+EMWebCache.h"
#import "DDUserDAO.h"
#import "IndexViewController.h"
#import "AWSDynamoDB_DDUser.h"
#import "AWSDynamoDB_ChatRoom2.h"
#import "Util.h"
#import "PersonInfoController.h"

@interface ChatRoomDetail ()

@property (strong, nonatomic) UIView *footerView;

@property(strong,nonatomic) UIScrollView *scrollView;
@property(strong,nonatomic) UIImagePickerController  *imagePicker;
@property(strong,nonatomic) NSMutableArray *datasouce;
@property(strong,nonatomic) AWSDynamoDB_DDUser *userDynamoDB;
@property(strong,nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property(strong,nonatomic) DDUser *uuser1;
@property(strong,nonatomic) DDUser *uuser2;
@property(strong,nonatomic) CHATROOM2 *chatroom2;


@end

@implementation ChatRoomDetail


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =_chatroom2.Motto;
    
    self.view.backgroundColor =[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    UIImageView *bak1=[[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.view.frame.size.width-10, self.view.frame.size.height/2-80)];
    bak1.backgroundColor=[UIColor whiteColor];
    [bak1 setUserInteractionEnabled:YES];
    [bak1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getUser1DetailInfo)]];
    
    bak1.layer.masksToBounds =YES;
    bak1.layer.cornerRadius =5;
    [self.view addSubview:bak1];
    [self showUser1:bak1];
     UIImageView *bak2=[[UIImageView alloc]initWithFrame:CGRectMake(5, bak1.frame.origin.y+bak1.frame.size.height+5, self.view.frame.size.width-10, bak1.frame.size.height)];
    bak2.backgroundColor=[UIColor whiteColor];
    bak2.layer.masksToBounds =YES;
    bak2.layer.cornerRadius =5;
    [bak2 setUserInteractionEnabled:YES];
    [bak2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getUser2DetailInfo)]];
    [self showUser2:bak2];
    [self.view addSubview:bak2];
    
    //buton
    
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, bak2.frame.origin.y+bak2.frame.size.height+10, self.view.frame.size.width, 30)];
    registerButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [registerButton setTitle:@"加入聊天室" forState:UIControlStateNormal];
    [self.view addSubview:registerButton];
    [registerButton addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    
    //更新点击数
    [self updateClickNumber];
  
}

-(void) getUser1DetailInfo{
    PersonInfoController *personInfo=[[PersonInfoController alloc]initUser:_uuser1];
    [self.navigationController pushViewController:personInfo animated:YES];
}

-(void) getUser2DetailInfo{
    PersonInfoController *personInfo=[[PersonInfoController alloc]initUser:_uuser2];
    [self.navigationController pushViewController:personInfo animated:YES];
}


-(void) addUser{
    //判断性别
    if(_chatroom2!=nil&&_uuser1!=nil&&_uuser2!=nil){
        if(_uuser1.gender!=nil){
            if(_uuser1.gender.intValue == [IndexViewController instanceDDuser].gender.intValue){
                [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                        message:NSLocalizedString(@"group.notSameSex", @"Please join in the other sex room")
                             customizationBlock:nil
                                completionBlock:nil
                              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                              otherButtonTitles: nil];
                return;
//                [self.navigationController popViewControllerAnimated:NO];
            }
        }else{
            [WCAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                    message:@"加入房间异常，请选择其他房间"
                         customizationBlock:nil
                            completionBlock:nil
                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                          otherButtonTitles: nil];
//            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        
    }
    Contact4GroupAddViewController *selectionController = [[[Contact4GroupAddViewController alloc] init] initGroupInfo:_chatroom2];
    [self.navigationController pushViewController:selectionController animated:YES];
}

-(id) initChatRoom:(CHATROOM2 *) room  uuser1:(DDUser *) uuser1 uuser2:(DDUser *) uuser2{
    _chatroom2=room;
    //查询
    _uuser1=uuser1;
    
    _uuser2=uuser2;

    return self;
}

-(void) updateClickNumber{
     _chatroom2.ClickNum=[NSString stringWithFormat:@"%d",_chatroom2.ClickNum.intValue +  arc4random() % 100];
   
    AWSDynamoDB_ChatRoom2 *chatRoom2DynamoDB = [[AWSDynamoDB_ChatRoom2 alloc] init];
    [chatRoom2DynamoDB insertChatroom2:_chatroom2];

    [chatRoom2DynamoDB refreshListWithBlock:^(NSArray *chatRoom2s) {
        //TODO
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)showUser1:(UIImageView *) bakview{
    
    UIImageView *headview=[[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 100, 100)];
    
    [headview sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:_uuser1.picPath]]
                placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =50;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, headview.frame.origin.y+10, 100, 12)];
    nickname.text=_uuser1.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:nickname];
    //性别
    BOOL isboy=NO;
    if(_uuser1!=nil){
        if(_uuser1.gender.intValue == 0){
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
    isboyview.frame=CGRectMake(nickname.frame.origin.x+nickname.frame.size.width+2, headview.frame.origin.y+8, 10, 10);
    [bakview addSubview:isboyview];
    //chengshi
    UILabel *city=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, nickname.frame.origin.y+nickname.frame.size.height+5, 70, 12)];
    city.text=_uuser1.city;
    city.textAlignment=NSTextAlignmentLeft;
    city.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:city];
    //学校图片
//    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//    schoolview.frame=CGRectMake(city.frame.origin.x+city.frame.size.width+15, city.frame.origin.y, 20, 10);
//    [bakview addSubview:schoolview];
    //爱好
    UILabel *intr=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, city.frame.origin.y+city.frame.size.height+5, 50, 12)];
    intr.text=_uuser1.hobbies;
    intr.textAlignment=NSTextAlignmentLeft;
    intr.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:intr];
    
    
    //qianming
    
    UIImage *signimg=[UIImage imageNamed:@"infoline"];
    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+20, bakview.frame.size.width-20, bakview.frame.size.height/2-10);
    
    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, signview.frame.size.width-20, 50)];
    sininfo.text=@"testXXXXXXXXXXXXXXXXdfjsklajxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    sininfo.textAlignment=NSTextAlignmentLeft;
    [sininfo setNumberOfLines:0];
    //                    sininfo.lineBreakMode = UILineBreakModeWordWrap;
    sininfo.font=[UIFont fontWithName:@"Helvetica" size:14];
    [signview addSubview:sininfo];

    
    [bakview addSubview:signview];
    //
    

}

-(void)showUser2:(UIImageView *) bakview{
   
    UIImageView *headview=[[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 100, 100)];
    [headview sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:_uuser2.picPath]]
                placeholderImage:[UIImage imageNamed:@"Logo_new"]];
    headview.layer.masksToBounds =YES;
    headview.layer.cornerRadius =50;
    [bakview addSubview:headview];
    
    //姓名
    UILabel *nickname=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, headview.frame.origin.y+10, 100, 12)];
    nickname.text=_uuser2.nickName;
    nickname.textAlignment=NSTextAlignmentLeft;
    nickname.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:nickname];
    //性别
    BOOL isboy=NO;
    if(_uuser1!=nil){
        if(_uuser1.gender.intValue == 0){
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
    isboyview.frame=CGRectMake(headview.frame.origin.x+headview.frame.size.width+nickname.frame.size.width, headview.frame.origin.y+8, 10, 10);
    [bakview addSubview:isboyview];
    //city
    UILabel *city=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, nickname.frame.origin.y+nickname.frame.size.height+5, 70, 12)];
    city.text=_uuser2.city;
    city.textAlignment=NSTextAlignmentLeft;
    city.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:city];
//    //学校图片
//    UIImage *schoolimg=[UIImage imageNamed:@"confirm"];
//    UIImageView *schoolview=[[UIImageView alloc] initWithImage:schoolimg];
//    schoolview.frame=CGRectMake(city.frame.origin.x+city.frame.size.width+15, city.frame.origin.y, 20, 10);
//    [bakview addSubview:schoolview];
    //aihaoci
    UILabel *intr=[[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x+headview.frame.size.width+15, city.frame.origin.y+city.frame.size.height+5, 50, 12)];
    intr.text=_uuser2.hobbies;
    intr.textAlignment=NSTextAlignmentLeft;
    intr.font=[UIFont fontWithName:@"Helvetica" size:14];
    [bakview addSubview:intr];
    
    //qianming
    
    UIImage *signimg=[UIImage imageNamed:@"infoline"];
    UIImageView *signview=[[UIImageView alloc] initWithImage:signimg];
    signview.frame=CGRectMake(10, headview.frame.origin.y+headview.frame.size.height+20, bakview.frame.size.width-20, bakview.frame.size.height/2-10);
    
    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, signview.frame.size.width-20, 50)];
    sininfo.text=@"testXXXXXXXXXXXXXXXXdfjsklajxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
    sininfo.textAlignment=NSTextAlignmentLeft;
    [sininfo setNumberOfLines:0];
    //                    sininfo.lineBreakMode = UILineBreakModeWordWrap;
    sininfo.font=[UIFont fontWithName:@"Helvetica" size:14];
    [signview addSubview:sininfo];
    
    [bakview addSubview:signview];


    
}




@end
