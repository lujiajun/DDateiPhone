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

#import "NewSettingViewController.h"
#import "SettingsViewController.h"

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
#import "PersonalController.h"
#import "IndexViewController.h"
#import "HelpViewController.h"
#import "DDUserDAO.h"
#import "UIImageView+EMWebCache.h"
#import "Constants.h"
#import "DDupdatePicAndName.h"
#import "Util.h"
#import "IndexViewController.h"
#import "DDDataManager.h"


@interface NewSettingViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;

@property (strong, nonatomic) UISwitch *beInvitedSwitch;
@property (strong, nonatomic) UILabel *beInvitedLabel;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) NSMutableArray *addedPicArray;
@property (strong, nonatomic) NSString *loginname;
// @property (strong, nonatomic) UIImageView *plusImageView;

@property (nonatomic)  NSUInteger *picnumber;


@end

@implementation NewSettingViewController

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;


#define  PIC_WIDTH 80
#define  PIC_HEIGHT 80

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
	self.tableView.tableFooterView = self.footerView;

    
    _headerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 130)];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DDUser* user = [DDDataManager sharedManager].user;
    _loginname = user.UID;
    if (user.photos) {
        _addedPicArray = [[NSMutableArray alloc] initWithArray:[user.photos componentsSeparatedByString:@","]];
    }

    [self.tableView reloadData];
}

#pragma mark - getter

- (UISwitch *)autoLoginSwitch {
	if (_autoLoginSwitch == nil) {
		_autoLoginSwitch = [[UISwitch alloc] init];
		[_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
	}

	return _autoLoginSwitch;
}

- (UISwitch *)beInvitedSwitch {
	return _beInvitedSwitch;
}

- (UILabel *)beInvitedLabel {
	if (_beInvitedLabel == nil) {
		_beInvitedLabel = [[UILabel alloc] init];
		_beInvitedLabel.backgroundColor = [UIColor clearColor];
		_beInvitedLabel.font = [UIFont systemFontOfSize:12.0];
		_beInvitedLabel.textColor = [UIColor grayColor];
	}

	return _beInvitedLabel;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 3:
			return 2;
			break;

		default:
			return 1;
			break;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    DDUser* user = [DDDataManager sharedManager].user;
    
	switch (indexPath.section) {
		case 0:
		{
			cell.accessoryType = UITableViewCellAccessoryNone;
			//background
			UIImage *bak = [UIImage imageNamed:@"settingback"];
			UIImageView *bakview = [[UIImageView alloc] initWithImage:bak];
			bakview.frame = CGRectMake(0, 0, self.view.frame.size.width, 160);
			[cell.contentView addSubview:bakview];


			UIImageView *imgHead = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 - 50, 10, 100, 100)];
			[imgHead sd_setImageWithURL:[NSURL URLWithString:[Util str1:DDPicPath appendStr2:user.picPath]] placeholderImage:[UIImage imageNamed:@"80"]];
			imgHead.layer.cornerRadius = 50;
			imgHead.layer.masksToBounds = YES;
			[imgHead setContentMode:UIViewContentModeScaleToFill];

			[bakview addSubview:imgHead];
			//添加nickname
			UILabel *mylable = [[UILabel alloc]initWithFrame:CGRectMake(0, 112, self.view.frame.size.width, 20)];
			mylable.text = user.nickName;
			mylable.textAlignment = NSTextAlignmentCenter;
			mylable.font = [UIFont fontWithName:@"Helvetica" size:14];
			[bakview addSubview:mylable];
			//添加性别图标
			NSString *sex;

			if (user.gender.intValue == 0) {
				sex = @"sexboy";
			} else {
				sex = @"sexgirl";
			}

			UIImage *seximg = [UIImage imageNamed:sex];
			UIImageView *sexview = [[UIImageView alloc] initWithImage:seximg];
			sexview.frame = CGRectMake(self.view.frame.size.width / 2 + 50, imgHead.frame.origin.y + 80, 20, 20);
			[bakview addSubview:sexview];
			//添加double 号
			UILabel *doubledate = [[UILabel alloc]initWithFrame:CGRectMake(0, 134, self.view.frame.size.width, 20)];

			doubledate.text = [Util str1:@"Double号:" appendStr2:user.UID];
			doubledate.textAlignment = NSTextAlignmentCenter;
			doubledate.font = [UIFont fontWithName:@"Helvetica" size:14];
			[bakview addSubview:doubledate];
		}
		break;


		case 1:
		{
			// 1.创建UIScrollView

			if (_addedPicArray.count> 0) {
				int i = 0;
				for (id element in _addedPicArray) {
					if (element != nil && ![element isEqual:@""]) {
						//图片显示
						UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(PIC_WIDTH * i, cell.frame.origin.y, PIC_WIDTH, PIC_HEIGHT)];

                        NSString* url = DD_PHOTO_URL(_loginname, element);
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
                [cell.contentView addSubview:_headerView];
			}
			break;
		}

		case 2: {
			//background
			UIImage *bak = [UIImage imageNamed:@"files"];
			UIImageView *bakview = [[UIImageView alloc] initWithImage:bak];
			bakview.frame = CGRectMake(0, cell.frame.origin.y + 5, self.view.frame.size.width, 140);
			[cell.contentView addSubview:bakview];

			UILabel *mylable = [[UILabel alloc]initWithFrame:CGRectMake(30, bakview.frame.origin.y + 5, 250, 20)];

			mylable.text = [Util str1:@"城市：   " appendStr2:user.city == nil ? @"请编辑城市信息" : user.city];
			mylable.textAlignment = NSTextAlignmentLeft;
			mylable.font = [UIFont fontWithName:@"Helvetica" size:12];
			[bakview addSubview:mylable];


			UILabel *university = [[UILabel alloc]initWithFrame:CGRectMake(30, mylable.frame.origin.y + 20, 260, 20)];
			university.text = [Util str1:@"学校：   " appendStr2:user.university == nil ? @"请编辑学校信息" : user.university];
			university.font = [UIFont fontWithName:@"Helvetica" size:12];
			[bakview addSubview:university];

//            UILabel *school=[[UILabel alloc]initWithFrame:CGRectMake(30, city.frame.origin.y+20, 200, 20)];
//            if(_user!=nil&&_user.city!=nil){
//                school.text=[@"年级：   " stringByAppendingString:[IndexViewController instanceDDuser].grade];
//            }
//
//            school.font=[UIFont fontWithName:@"Helvetica" size:12];
//            [bakview addSubview:school];

			UILabel *gender = [[UILabel alloc]initWithFrame:CGRectMake(30, university.frame.origin.y + 20, 200, 20)];
			if (user.gender.intValue == 0) {
				gender.text = @"性别：   男";
			} else {
				gender.text = @"性别：   女";
			}


			gender.font = [UIFont fontWithName:@"Helvetica" size:12];
			[bakview addSubview:gender];


			UILabel *birth = [[UILabel alloc]initWithFrame:CGRectMake(30, gender.frame.origin.y + 20, self.view.frame.size.width-40, 20)];

			birth.text = [Util str1:@"BIRTH：   " appendStr2:user.birthday == nil ? @"请编辑出生日期信息" : user.birthday];

			birth.font = [UIFont fontWithName:@"Helvetica" size:12];
			[bakview addSubview:birth];

			UILabel *intre = [[UILabel alloc]initWithFrame:CGRectMake(30, birth.frame.origin.y + 20, self.view.frame.size.width-40, 20)];
			intre.text = [Util str1:@"爱好：   " appendStr2:user.hobbies == nil ? @"请编辑爱好信息" : user.hobbies];
			intre.font = [UIFont fontWithName:@"Helvetica" size:12];
			[bakview addSubview:intre];

			UILabel *sign = [[UILabel alloc]initWithFrame:CGRectMake(30, intre.frame.origin.y + 20, self.view.frame.size.width-40, 20)];
			sign.text = [Util str1:@"签名：   " appendStr2:user.sign == nil ? @"请编辑签名信息" : user.sign];
			sign.font = [UIFont fontWithName:@"Helvetica" size:12];
			[bakview addSubview:sign];
			//            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
			//            cell.textLabel.text=@"CESHI";
			//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			break;
		}

		case 3:
		{
			if (indexPath.row == 0) {
				UIImage *img = [UIImage imageNamed:@"setting"];
				UIImageView *imgHead = [[UIImageView alloc] initWithImage:img];
				imgHead.frame = CGRectMake(20, cell.frame.origin.y + 15, 15, 15);
				[cell.contentView addSubview:imgHead];
				UILabel *sets = [[UILabel alloc] initWithFrame:CGRectMake(imgHead.frame.origin.x + imgHead.frame.size.width + 5, cell.frame.origin.y + 15, 100, 20)];
				sets.text = NSLocalizedString(@"title.setting", @"Setting");
				sets.font = [UIFont fontWithName:@"Helvetica" size:12];
				[cell.contentView addSubview:sets];

				//            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			} else if (indexPath.row == 1) {
				UIImage *img = [UIImage imageNamed:@"help"];
				UIImageView *imgHead = [[UIImageView alloc] initWithImage:img];
				imgHead.frame = CGRectMake(20, cell.frame.origin.y + 15, 15, 15);
				[cell.contentView addSubview:imgHead];
				UILabel *sets = [[UILabel alloc] initWithFrame:CGRectMake(imgHead.frame.origin.x + imgHead.frame.size.width + 5, cell.frame.origin.y + 15, 100, 20)];
				sets.text = @"帮助";
				sets.font = [UIFont fontWithName:@"Helvetica" size:12];
				[cell.contentView addSubview:sets];

				//            cell.textLabel.text = NSLocalizedString(@"title.setting", @"Setting");
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
	}


	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0)
		return 0;
	else
		return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 3) {
		return 50;
	} else if (indexPath.section == 1)     {
		return 130;
	}
	return 160;
}

- (void)btnClick {
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
	                              initWithTitle:@"请选择文件来源"
	                                       delegate:self
	                              cancelButtonTitle:@"取消"
	                         destructiveButtonTitle:nil
	                              otherButtonTitles:@"照相机", @"本地相簿", nil];
	[actionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0://照相机
		{
			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.delegate = self;
			imagePicker.allowsEditing = YES;
			imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentViewController:imagePicker animated:YES completion:nil];
		}
		break;

		case 1://本地相簿
		{
			UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
			imagePicker.delegate = self;
			imagePicker.allowsEditing = YES;
			imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imagePicker animated:YES completion:nil];
		}
		break;

		default:
			break;
	}
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	switch (indexPath.section) {
		case 0: {
			DDupdatePicAndName *pushController = [DDupdatePicAndName alloc];
			[self.navigationController pushViewController:pushController animated:YES];

			break;
		}

		case 2: {
            break;
		}

		case 3: {
			if (indexPath.row == 0) {
				SettingsViewController *debugController = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
				[self.navigationController pushViewController:debugController animated:YES];
			} else {
				HelpViewController *help = [HelpViewController alloc];
				[self.navigationController pushViewController:help animated:YES];
			}
		}
	}
}

#pragma mark - getter

- (UIView *)footerView {
	if (_footerView == nil) {
		_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
		_footerView.backgroundColor = [UIColor clearColor];
	}
	return _footerView;
}

#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch {
	[[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:autoSwitch.isOn];
}

- (void)useIpChanged:(UISwitch *)ipSwitch {
	[[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
}

- (void)beInvitedChanged:(UISwitch *)beInvitedSwitch {
	//    if (beInvitedSwitch.isOn) {
	//        self.beInvitedLabel.text = @"允许选择";
	//    }
	//    else{
	//        self.beInvitedLabel.text = @"自动加入";
	//    }
	//
	//    [[EaseMob sharedInstance].chatManager setAutoAcceptGroupInvitation:!(beInvitedSwitch.isOn)];
}

- (void)refreshConfig {
	[self.autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled] animated:YES];
	[self.ipSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];

	[self.tableView reloadData];
}

- (void)logoutAction {
	__weak NewSettingViewController *weakSelf = self;
	[self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
	[[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion: ^(NSDictionary *info, EMError *error) {
	    [weakSelf hideHud];
	    if (error && error.errorCode != EMErrorServerNotLogin) {
	        [weakSelf showHint:error.description];
		} else {
	        [[ApplyViewController shareController] clear];
	        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
		}
	} onQueue:nil];
}

@end
