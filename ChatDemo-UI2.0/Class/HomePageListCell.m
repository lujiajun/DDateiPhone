//
//  HomePageListCell.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/2.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "HomePageListCell.h"

@implementation HomePageListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		//Background
		_bakview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
		_bakview.frame = CGRectMake(5, 5, self.frame.size.width - 10, 150);
		_bakview.layer.masksToBounds = YES;
		_bakview.layer.cornerRadius = 5;
		[self.contentView addSubview:_bakview];
        
        //渐变
        UIImage *background=[UIImage imageNamed:@"jianbian"];
        UIImageView *bakgroundview=[[UIImageView alloc] initWithImage:background];
        bakgroundview.frame=CGRectMake(5, 5, self.frame.size.width-10, 150);
        bakgroundview.layer.masksToBounds =YES;
        bakgroundview.layer.cornerRadius =5;
        [self.contentView addSubview:bakgroundview];

		//User1 Avatar
		_user1Avatar = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
		_user1Avatar.frame = CGRectMake(10, _bakview.frame.origin.y + 5, 50, 50);
		_user1Avatar.layer.masksToBounds = YES;
		_user1Avatar.layer.cornerRadius = 25;
		[_bakview addSubview:_user1Avatar];

		//User2 Avatar
		_user2Avatar = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"Logo_new.png"]];
		_user2Avatar.frame = CGRectMake(_bakview.frame.size.width - 60, _bakview.frame.origin.y + 5, 50, 50);
		_user2Avatar.layer.masksToBounds = YES;
		_user2Avatar.layer.cornerRadius = 25;
		[_bakview addSubview:_user2Avatar];

		//GenderView
		_genderView = [[UIImageView alloc] init];
		_genderView.frame = CGRectMake(_bakview.frame.size.width - 40, _bakview.frame.origin.y + 80, 20, 20);
		[_bakview addSubview:_genderView];

		//Click Number Background
		UIImage *clicknumber2 = [UIImage imageNamed:@"clicknum2"];
		UIImageView *clicknumber2view = [[UIImageView alloc] initWithImage:clicknumber2];
		clicknumber2view.frame = CGRectMake(_bakview.frame.size.width - 60, _bakview.frame.origin.y + 110, 56, 25);
		[_bakview addSubview:clicknumber2view];

		UIImage *clicknumber1 = [UIImage imageNamed:@"clicknum1"];
		UIImageView *clicknumber1view = [[UIImageView alloc] initWithImage:clicknumber1];
		clicknumber1view.frame = CGRectMake(5, 5, 12, 12);
		[clicknumber2view addSubview:clicknumber1view];

		//Click Number Label
		_clicknumber = [[UILabel alloc]initWithFrame:CGRectMake(19, 2, 30, 20)];
		_clicknumber.textAlignment = NSTextAlignmentCenter;
		_clicknumber.font = [UIFont fontWithName:@"Helvetica" size:11];
		_clicknumber.textColor = [UIColor whiteColor];
		[clicknumber2view addSubview:_clicknumber];

		//Motto Label
		//添加宣言
		_motto = [[UILabel alloc]initWithFrame:CGRectMake(0, _bakview.frame.origin.y + 110, 100, 30)];
		_motto.textAlignment = NSTextAlignmentCenter;
		_motto.font = [UIFont fontWithName:@"Helvetica" size:14];
		_motto.textColor = [UIColor whiteColor];
		[_bakview addSubview:_motto];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

@end
