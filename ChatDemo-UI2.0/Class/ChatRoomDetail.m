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

@interface ChatRoomDetail ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) NSMutableArray *datasouce;
@property (strong, nonatomic) DDBDynamoDB *ddbDynamoDB;
@property (strong, nonatomic) AWSDynamoDBObjectMapper *dynamoDBObjectMapper;
@property (strong, nonatomic) DDUser *uuser1;
@property (strong, nonatomic) DDUser *uuser2;
@property (strong, nonatomic) NSString *motto;
@property (nonatomic) LocalDbService *localDbService;

@end

@implementation ChatRoomDetail


- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = _motto;
	self.view.backgroundColor = [UIColor redColor];

	self.tableView.backgroundColor = [UIColor whiteColor];
	self.tableView.tableFooterView = self.footerView;
}

- (id)initChatRoom:(DDUser *)uuser1 uuser2:(DDUser *)uuser2 motto:(NSString *)motto {
	_motto = motto;
	//查询
	_uuser1 = uuser1;

	_uuser2 = uuser2;

	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark - Table view datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

//每行缩进
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return 10;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			EGOImageView *headview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
			if (_uuser1 != nil && _uuser1.picPath != nil) {
				headview.imageURL = [NSURL URLWithString:[DDPicPath stringByAppendingString:_uuser1.picPath]];
			}
			headview.frame = CGRectMake(50, 10, 80, 80);
			headview.layer.masksToBounds = YES;
			headview.layer.cornerRadius = 40;
			[cell.contentView addSubview:headview];

			//姓名
			UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x + headview.frame.size.width + 10, headview.frame.origin.y + 10, 50, 12)];
			nickname.text = _uuser1.nickName;
			nickname.textAlignment = NSTextAlignmentLeft;
			nickname.font = [UIFont fontWithName:@"Helvetica" size:12];
			[cell.contentView addSubview:nickname];
			//性别
			BOOL *isboy = NO;
			if (_uuser1 != nil) {
				if (_uuser1.gender == @"Male" || _uuser1.gender == @"男") {
					isboy = YES;
				}
			}
			UIImage *isboyimg;
			if (isboy) {
				isboyimg = [UIImage imageNamed:@"sexboy"];
			} else {
				isboyimg = [UIImage imageNamed:@"sexgirl"];
			}
			UIImageView *isboyview = [[UIImageView alloc] initWithImage:isboyimg];
			isboyview.frame = CGRectMake(headview.frame.origin.x + headview.frame.size.width + nickname.frame.size.width + 15, headview.frame.origin.y + 8, 10, 10);
			[cell.contentView addSubview:isboyview];
			//学校
			UILabel *university = [[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x + headview.frame.size.width + 10, nickname.frame.origin.y + nickname.frame.size.height + 2, 50, 12)];
			university.text = _uuser1.university;
			university.textAlignment = NSTextAlignmentLeft;
			university.font = [UIFont fontWithName:@"Helvetica" size:12];
			[cell.contentView addSubview:university];
			//学校图片
			UIImage *schoolimg = [UIImage imageNamed:@"confirm"];
			UIImageView *schoolview = [[UIImageView alloc] initWithImage:schoolimg];
			schoolview.frame = CGRectMake(university.frame.origin.x + university.frame.size.width + 15, university.frame.origin.y, 20, 10);
			[cell.contentView addSubview:schoolview];
			//年级
			UILabel *gender = [[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x + headview.frame.size.width + 10, university.frame.origin.y + university.frame.size.height + 2, 50, 12)];
			gender.text = _uuser1.grade;
			gender.textAlignment = NSTextAlignmentLeft;
			gender.font = [UIFont fontWithName:@"Helvetica" size:12];
			[cell.contentView addSubview:gender];


			//qianming

			UIImage *signimg = [UIImage imageNamed:@"infoline"];
			UIImageView *signview = [[UIImageView alloc] initWithImage:signimg];
			signview.frame = CGRectMake(10, headview.frame.origin.y + headview.frame.size.height + 5, cell.frame.size.width - 10, 50);
			[cell.contentView addSubview:signview];
//
//                UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(5, 50, cell.frame.size.width-20, 50)];
//                sininfo.text=@"testXXXXXXXXXXXXXXX";
//                sininfo.textAlignment=NSTextAlignmentLeft;
//                sininfo.lineBreakMode = UILineBreakModeWordWrap;
//                sininfo.font=[UIFont fontWithName:@"Helvetica" size:12];
//                [signview addSubview:sininfo];
		} else if (indexPath.row == 1) {
			UIImage *user1;
			if (_uuser2 != nil && _uuser2.picPath != nil) {
				NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[DDPicPath stringByAppendingString:_uuser2.picPath]]];
				user1 = [UIImage imageWithData:data];
			} else {
				user1 = [UIImage imageNamed:@"Logo_new"];
			}

			UIImageView *headview = [[UIImageView alloc] initWithImage:user1];
			headview.frame = CGRectMake(50, 10, 80, 80);
			headview.layer.masksToBounds = YES;
			headview.layer.cornerRadius = 40;
			[cell.contentView addSubview:headview];

			//姓名
			UILabel *nickname = [[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x + headview.frame.size.width + 10, headview.frame.origin.y + 10, 50, 12)];
			nickname.text = _uuser2.nickName;
			nickname.textAlignment = NSTextAlignmentLeft;
			nickname.font = [UIFont fontWithName:@"Helvetica" size:12];
			[cell.contentView addSubview:nickname];
			//性别
			BOOL *isboy = NO;
			if (_uuser1 != nil) {
				if (_uuser1.gender == @"Male" || _uuser1.gender == @"男") {
					isboy = YES;
				}
			}
			UIImage *isboyimg;
			if (isboy) {
				isboyimg = [UIImage imageNamed:@"sexboy"];
			} else {
				isboyimg = [UIImage imageNamed:@"sexgirl"];
			}
			UIImageView *isboyview = [[UIImageView alloc] initWithImage:isboyimg];
			isboyview.frame = CGRectMake(headview.frame.origin.x + headview.frame.size.width + nickname.frame.size.width + 15, headview.frame.origin.y + 8, 10, 10);
			[cell.contentView addSubview:isboyview];
			//学校
			UILabel *university = [[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x + headview.frame.size.width + 10, nickname.frame.origin.y + nickname.frame.size.height + 2, 50, 10)];
			university.text = _uuser2.university;
			university.textAlignment = NSTextAlignmentLeft;
			university.font = [UIFont fontWithName:@"Helvetica" size:12];
			[cell.contentView addSubview:university];
			//学校图片
			UIImage *schoolimg = [UIImage imageNamed:@"confirm"];
			UIImageView *schoolview = [[UIImageView alloc] initWithImage:schoolimg];
			schoolview.frame = CGRectMake(university.frame.origin.x + university.frame.size.width + 15, university.frame.origin.y, 20, 10);
			[cell.contentView addSubview:schoolview];
			//年级
			UILabel *gender = [[UILabel alloc] initWithFrame:CGRectMake(headview.frame.origin.x + headview.frame.size.width + 10, university.frame.origin.y + university.frame.size.height + 2, 50, 12)];
			gender.text = _uuser2.grade;
			gender.textAlignment = NSTextAlignmentLeft;
			gender.font = [UIFont fontWithName:@"Helvetica" size:12];
			[cell.contentView addSubview:gender];

			//qianming

			UIImage *signimg = [UIImage imageNamed:@"infoline"];
			UIImageView *signview = [[UIImageView alloc] initWithImage:signimg];
			signview.frame = CGRectMake(10, headview.frame.origin.y + headview.frame.size.height + 5, cell.frame.size.width - 10, 50);
			[cell.contentView addSubview:signview];

//                    UILabel *sininfo=[[UILabel alloc] initWithFrame:CGRectMake(signview.frame.origin.x+5, 100, cell.frame.size.width-20, 50)];
//                    sininfo.text=@"testXXXXXXXXXXXXXXX";
//                    sininfo.textAlignment=NSTextAlignmentLeft;
//                    sininfo.font=[UIFont fontWithName:@"Helvetica" size:12];
//                    [signview addSubview:sininfo];
		}
	}

	return cell;
}

- (void)insertTableRow:(DDUser *)tableRow {
	AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
	[dynamoDBObjectMapper save:tableRow];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 160;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 20;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Method

- (void)joinChatRoom {
}

#pragma mark - getter

- (UIView *)footerView {
	if (_footerView == nil) {
		_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
		_footerView.backgroundColor = [UIColor clearColor];
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 40)];
		button.backgroundColor = [UIColor redColor];
		button.layer.masksToBounds = YES;
		button.layer.cornerRadius = 4;
		button.titleLabel.font =  [UIFont boldSystemFontOfSize:20.0f];
		[button setTitle:@"加入聊天室" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(joinChatRoom) forControlEvents:UIControlEventTouchUpInside];
		[_footerView addSubview:button];
	}
	return _footerView;
}

@end
