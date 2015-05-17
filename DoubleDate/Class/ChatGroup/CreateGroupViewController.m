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

#import "CreateGroupViewController.h"

#import "ContactSelectionViewController.h"
#import "EMTextView.h"
#import "AliCloudController.h"
#import "AWSDynamoDB_ChatRoom2.h"
#import "Util.h"
#import "AWSDynamoDB_DDUser.h"

@interface CreateGroupViewController ()<UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, EMChooseViewDelegate>

@property (strong, nonatomic) UIView *switchView;
@property (strong, nonatomic) UIBarButtonItem *rightItem;
@property (strong, nonatomic) UIImageView *chatRoomCover;
@property (strong, nonatomic) EMTextView *mottoTextView;
@property (strong, nonatomic) NSString *coverImagePath;

@property (nonatomic) BOOL isPublic;
@property (strong, nonatomic) UILabel *groupTypeLabel;//群组类型

@property (nonatomic) BOOL isMemberOn;
@property (strong, nonatomic) UILabel *groupMemberTitleLabel;
@property (strong, nonatomic) UISwitch *groupMemberSwitch;
@property (strong, nonatomic) UILabel *groupMemberLabel;
@property(strong,nonatomic) UIButton *button;
@end

@implementation CreateGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isPublic = NO;
        _isMemberOn = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.title = NSLocalizedString(@"title.createGroup", @"Create a group");
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//    addButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [addButton setTitle:NSLocalizedString(@"group.create.addOccupant", @"add members") forState:UIControlStateNormal];
//    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [addButton addTarget:self action:@selector(addContacts:) forControlEvents:UIControlEventTouchUpInside];
//    _rightItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
//    [self.navigationItem setRightBarButtonItem:_rightItem];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self.view addSubview:self.chatRoomCover];
    [self.view addSubview:self.mottoTextView];
//    [self.view addSubview:self.switchView];
    
    UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _mottoTextView.frame.origin.y+_mottoTextView.frame.size.height+10, self.view.frame.size.width, 30)];
    nextButton.backgroundColor=RGBACOLOR(232, 79, 60, 1);
    [nextButton setTitle:@"创建聊天室" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(addContacts:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UIImageView *)chatRoomCover
{
	if (_chatRoomCover == nil) {
		_chatRoomCover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
		_chatRoomCover.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		_chatRoomCover.layer.borderWidth = 0.5;
		_chatRoomCover.layer.cornerRadius = 3;
        _chatRoomCover.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
        _chatRoomCover.userInteractionEnabled = YES;
        if(_button==nil){
            _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
        }
        _button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_button setTitle:@"设置封面" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor colorWithRed:32 / 255.0 green:134 / 255.0 blue:158 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		_button.backgroundColor = RGBACOLOR(232, 79, 60, 1);
		_button.center = CGPointMake(_chatRoomCover.frame.size.width / 2, _chatRoomCover.frame.size.height / 2);
        [_button addTarget:self action:@selector(chooseChatRoomCoverImage:) forControlEvents:UIControlEventTouchUpInside];
        [_chatRoomCover addSubview:_button];
	}

	return _chatRoomCover;
}

- (EMTextView *)mottoTextView
{
    if (_mottoTextView == nil) {
        _mottoTextView = [[EMTextView alloc] initWithFrame:CGRectMake(10, 220, self.view.frame.size.width-20, 80)];
        _mottoTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _mottoTextView.layer.borderWidth = 0.5;
        _mottoTextView.layer.cornerRadius = 3;
        _mottoTextView.font = [UIFont systemFontOfSize:14.0];
        _mottoTextView.backgroundColor = [UIColor whiteColor];
        _mottoTextView.placeholder = NSLocalizedString(@"group.create.declaration", @"please enter the Double Date declaration");
//        _mottoTextView.returnKeyType = UIReturnKeyDone;
        _mottoTextView.delegate = self;
    }
    
    return _mottoTextView;
}

- (UIView *)switchView
{
    if (_switchView == nil) {
        _switchView = [[UIView alloc] initWithFrame:CGRectMake(10, 160, 300, 90)];
        _switchView.backgroundColor = [UIColor clearColor];
        
        CGFloat oY = 0;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, oY, 100, 35)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = NSLocalizedString(@"group.create.groupPermission", @"group permission");
        [_switchView addSubview:label];
        
        UISwitch *switchControl = [[UISwitch alloc] initWithFrame:CGRectMake(100, oY, 50, _switchView.frame.size.height)];
        [switchControl addTarget:self action:@selector(groupTypeChange:) forControlEvents:UIControlEventValueChanged];
        [_switchView addSubview:switchControl];
        
        _groupTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(switchControl.frame.origin.x + switchControl.frame.size.width + 5, oY, 100, 35)];
        _groupTypeLabel.backgroundColor = [UIColor clearColor];
        _groupTypeLabel.font = [UIFont systemFontOfSize:12.0];
        _groupTypeLabel.textColor = [UIColor grayColor];
        _groupTypeLabel.text = NSLocalizedString(@"group.create.private", @"private group");
        [_switchView addSubview:_groupTypeLabel];
        
        oY += (35 + 20);
        _groupMemberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, oY, 100, 35)];
        _groupMemberTitleLabel.font = [UIFont systemFontOfSize:14.0];
        _groupMemberTitleLabel.backgroundColor = [UIColor clearColor];
        _groupMemberTitleLabel.text = NSLocalizedString(@"group.create.occupantPermissions", @"members invite permissions");
        [_switchView addSubview:_groupMemberTitleLabel];
        
        _groupMemberSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, oY, 50, 35)];
        [_groupMemberSwitch addTarget:self action:@selector(groupMemberChange:) forControlEvents:UIControlEventValueChanged];
        [_switchView addSubview:_groupMemberSwitch];
        
        _groupMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_groupMemberSwitch.frame.origin.x + _groupMemberSwitch.frame.size.width + 5, oY, 150, 35)];
        _groupMemberLabel.backgroundColor = [UIColor clearColor];
        _groupMemberLabel.font = [UIFont systemFontOfSize:12.0];
        _groupMemberLabel.textColor = [UIColor grayColor];
        _groupMemberLabel.text = NSLocalizedString(@"group.create.unallowedOccupantInvite", @"don't allow group members to invite others");
        [_switchView addSubview:_groupMemberLabel];
    }
    
    return _switchView;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - EMChooseViewDelegate

- (void)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources {
	[self showHudInView:self.view hint:NSLocalizedString(@"group.create.ongoing", @"create a group...")];
	__weak CreateGroupViewController *weakSelf = self;
	NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
	NSString *username = [loginInfo objectForKey:kSDKUsername];
	[weakSelf hideHud];
	[weakSelf showHint:NSLocalizedString(@"group.create.success", @"create group success")];
	[weakSelf.navigationController popViewControllerAnimated:YES];

	AWSDynamoDB_ChatRoom2 *chatRoom2DynamoDB = [[AWSDynamoDB_ChatRoom2 alloc] init];
    AWSDynamoDB_DDUser *userDynamoDB = [[AWSDynamoDB_DDUser alloc] init];
	CHATROOM2 *chatRoom2 = [CHATROOM2 new];
	NSString *username2 = [[selectedSources objectAtIndex:0] username];
	chatRoom2.RID = [Util str1:username appendStr2:@"_" appendStr3:username2];
	chatRoom2.ClickNum = @"0";
	chatRoom2.Gender = [userDynamoDB.dduserDao selectDDuserByUid:username].gender;
	chatRoom2.Motto = self.mottoTextView.text;
	chatRoom2.PicturePath = self.coverImagePath;
	chatRoom2.UID1 = username;
	chatRoom2.UID2 = username2;
    
    //先删除老得组，替换新的
	[chatRoom2DynamoDB insertChatroom2:chatRoom2];
}

#pragma mark - action

- (void)groupTypeChange:(UISwitch *)control
{
    _isPublic = control.isOn;
    
    [_groupMemberSwitch setOn:NO animated:NO];
    [self groupMemberChange:_groupMemberSwitch];
    
    if (control.isOn) {
        _groupTypeLabel.text = NSLocalizedString(@"group.create.public", @"public group");
    }
    else{
        _groupTypeLabel.text = NSLocalizedString(@"group.create.private", @"private group");
    }
}

- (void)groupMemberChange:(UISwitch *)control
{
    if (_isPublic) {
        _groupMemberTitleLabel.text = NSLocalizedString(@"group.create.occupantJoinPermissions", @"members join permissions");
        if(control.isOn)
        {
            _groupMemberLabel.text = NSLocalizedString(@"group.create.open", @"random join");
        }
        else{
            _groupMemberLabel.text = NSLocalizedString(@"group.create.needApply", @"you need administrator agreed to join the group");
        }
    }
    else{
        _groupMemberTitleLabel.text = NSLocalizedString(@"group.create.occupantPermissions", @"members invite permissions");
        if(control.isOn)
        {
            _groupMemberLabel.text = NSLocalizedString(@"group.create.allowedOccupantInvite", @"allows group members to invite others");
        }
        else{
            _groupMemberLabel.text = NSLocalizedString(@"group.create.unallowedOccupantInvite", @"don't allow group members to invite others");
        }
    }
    
    _isMemberOn = control.isOn;
}

- (void)addContacts:(id)sender
{
    if (self.mottoTextView.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"group.create.declaration.tip", @"请输入Double Date宣言") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self.view endEditing:YES];
    
    ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] init];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

- (void)chooseChatRoomCoverImage:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"请选择文件来源"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"照相机",@"本地相簿",nil];
    [actionSheet showInView:self.view];
}



#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0://照相机
		{
			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentViewController:imagePicker animated:YES completion:nil];
		}
		break;

		case 1://本地相簿
		{
			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imagePicker animated:YES completion:nil];
		}
		break;

		default:
			break;
	}
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString *type = [info objectForKey:UIImagePickerControllerMediaType];

	//当选择的类型是图片
	if ([type isEqualToString:@"public.image"]) {
		//先把图片转成NSData
		UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

		NSData *data;
		if (UIImagePNGRepresentation(image) == nil) {
			data = UIImageJPEGRepresentation(image, 1.0);
		} else {
			data = UIImagePNGRepresentation(image);
		}
        
		//关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        self.chatRoomCover.image = image;
        [_button removeFromSuperview];
        
//        _picpath=[[IndexViewController instanceDDuser].UID stringByAppendingString:@"_head_pic" ];

		AliCloudController *aliCloud = [AliCloudController alloc];
		self.coverImagePath = [aliCloud uploadPic:data];
	}
}


@end
