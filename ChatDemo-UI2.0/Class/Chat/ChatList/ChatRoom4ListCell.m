//
//  ChatRoom4ListCell.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/3.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "ChatRoom4ListCell.h"

#define AVARTAR_SIZE 60
#define AVARTAR_MARGIN_TOP 10

#define CELL_HEIGHT 110

@interface ChatRoom4ListCell ()

@property (strong, nonatomic) UILabel *unreadLabel;
@property (strong, nonatomic) UIView *lineView;

@end


@implementation ChatRoom4ListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		int start = (self.frame.size.width - AVARTAR_SIZE * 4) / 2;

		//User1
		_user1Avatar = [[UIImageView alloc] init];
		_user1Avatar.frame = CGRectMake(start, AVARTAR_MARGIN_TOP, AVARTAR_SIZE, AVARTAR_SIZE);
		[self.contentView addSubview:_user1Avatar];

		_user1Name = [[UILabel alloc] init];
		_user1Name.frame = CGRectMake(0, 0, AVARTAR_SIZE, 10);
		_user1Name.center = CGPointMake(_user1Avatar.center.x, _user1Avatar.center.y + AVARTAR_SIZE / 2 + 10);
		_user1Name.textAlignment = NSTextAlignmentCenter;
		_user1Name.font = [UIFont systemFontOfSize:12];
		[self.contentView addSubview:_user1Name];

		//User2
		_user2Avatar = [[UIImageView alloc] init];
		_user2Avatar.frame = CGRectMake(start + AVARTAR_SIZE, AVARTAR_MARGIN_TOP, AVARTAR_SIZE, AVARTAR_SIZE);
		[self.contentView addSubview:_user2Avatar];

		_user2Name = [[UILabel alloc] init];
		_user2Name.frame = CGRectMake(0, 0, AVARTAR_SIZE, 10);
		_user2Name.center = CGPointMake(_user2Avatar.center.x, _user2Avatar.center.y + AVARTAR_SIZE / 2 + 10);
		_user2Name.textAlignment = NSTextAlignmentCenter;
		_user2Name.font = [UIFont systemFontOfSize:12];
		[self.contentView addSubview:_user2Name];

		//User3
		_user3Avatar = [[UIImageView alloc] init];
		_user3Avatar.frame = CGRectMake(start + AVARTAR_SIZE * 2, AVARTAR_MARGIN_TOP, AVARTAR_SIZE, AVARTAR_SIZE);
		[self.contentView addSubview:_user3Avatar];

		_user3Name = [[UILabel alloc] init];
		_user3Name.frame = CGRectMake(0, 0, AVARTAR_SIZE, 10);
		_user3Name.center = CGPointMake(_user3Avatar.center.x, _user3Avatar.center.y + AVARTAR_SIZE / 2 + 10);
		_user3Name.textAlignment = NSTextAlignmentCenter;
		_user3Name.font = [UIFont systemFontOfSize:12];
		[self.contentView addSubview:_user3Name];

		//User4
		_user4Avatar = [[UIImageView alloc] init];
		_user4Avatar.frame = CGRectMake(start + AVARTAR_SIZE * 3, AVARTAR_MARGIN_TOP, AVARTAR_SIZE, AVARTAR_SIZE);
		[self.contentView addSubview:_user4Avatar];

		_user4Name = [[UILabel alloc] init];
		_user4Name.frame = CGRectMake(0, 0, AVARTAR_SIZE, 10);
		_user4Name.center = CGPointMake(_user4Avatar.center.x, _user4Avatar.center.y + AVARTAR_SIZE / 2 + 10);
		_user4Name.textAlignment = NSTextAlignmentCenter;
		_user4Name.font = [UIFont systemFontOfSize:12];
		[self.contentView addSubview:_user4Name];

		//time label
		_timeLabel = [[UILabel alloc] init];
		_timeLabel.frame = CGRectMake(self.frame.size.width - 175, CELL_HEIGHT - 20, 175, 20);
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.textAlignment = NSTextAlignmentRight;
		_timeLabel.font = [UIFont systemFontOfSize:11];
		_timeLabel.textColor = [UIColor lightGrayColor];
		[self.contentView addSubview:_timeLabel];

		//unread label
		_unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(start - 10 + AVARTAR_SIZE * 4, 0, 20, 20)];
		_unreadLabel.backgroundColor = [UIColor redColor];
		_unreadLabel.textColor = [UIColor whiteColor];

		_unreadLabel.textAlignment = NSTextAlignmentCenter;
		_unreadLabel.font = [UIFont systemFontOfSize:11];
		_unreadLabel.layer.cornerRadius = 10;
		_unreadLabel.clipsToBounds = YES;
		[self.contentView addSubview:_unreadLabel];

		//line view
		_lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
		_lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
		[self.contentView addSubview:_lineView];
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (_unreadCount > 0) {
		if (_unreadCount < 9) {
			_unreadLabel.font = [UIFont systemFontOfSize:13];
		} else if (_unreadCount > 9 && _unreadCount < 99) {
			_unreadLabel.font = [UIFont systemFontOfSize:12];
		} else {
			_unreadLabel.font = [UIFont systemFontOfSize:10];
		}
		[_unreadLabel setHidden:NO];
		[self.contentView bringSubviewToFront:_unreadLabel];
		_unreadLabel.text = [NSString stringWithFormat:@"%ld", (long)_unreadCount];
	} else {
		[_unreadLabel setHidden:YES];
	}

	CGRect frame = _lineView.frame;
	frame.origin.y = self.contentView.frame.size.height - 1;
	_lineView.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return CELL_HEIGHT;
}

@end
