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


#import "ChatListCell.h"
#import "UIImageView+EMWebCache.h"

@interface ChatListCell () {
	UILabel *_timeLabel;
	UILabel *_unreadLabel;
//	UILabel *_detailLabel;
	UIView *_lineView;
}

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UILabel *textLabel1;

@end

@implementation ChatListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 7, 80, 16)];
		_timeLabel.font = [UIFont systemFontOfSize:13];
		_timeLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_timeLabel];

		_unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 20, 20)];
		_unreadLabel.backgroundColor = [UIColor redColor];
		_unreadLabel.textColor = [UIColor whiteColor];

		_unreadLabel.textAlignment = NSTextAlignmentCenter;
		_unreadLabel.font = [UIFont systemFontOfSize:11];
		_unreadLabel.layer.cornerRadius = 10;
		_unreadLabel.clipsToBounds = YES;
		[self.contentView addSubview:_unreadLabel];

//		_detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 30, 175, 20)];
//		_detailLabel.backgroundColor = [UIColor clearColor];
//		_detailLabel.font = [UIFont systemFontOfSize:15];
//		_detailLabel.textColor = [UIColor lightGrayColor];
//		[self.contentView addSubview:_detailLabel];

		self.textLabel.backgroundColor = [UIColor clearColor];

		_lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 1)];
		_lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
		[self.contentView addSubview:_lineView];


		_imageView1 = [[UIImageView alloc] init];
		[self.contentView addSubview:_imageView1];
        _textLabel1 = [[UILabel alloc] init];
        [self.contentView addSubview:_textLabel1];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	if (![_unreadLabel isHidden]) {
		_unreadLabel.backgroundColor = [UIColor redColor];
	}
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (![_unreadLabel isHidden]) {
		_unreadLabel.backgroundColor = [UIColor redColor];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect frame = self.imageView.frame;

	[self.imageView sd_setImageWithURL:_imageURL placeholderImage:_placeholderImage];
	self.imageView.frame = CGRectMake(10, 7, 45, 45);
	[self.imageView1 sd_setImageWithURL:_imageURL1 placeholderImage:_placeholderImage];
	self.imageView1.frame = CGRectMake(150, 10, 45, 45);

	self.textLabel.text = _name;
	self.textLabel.frame = CGRectMake(10, 62, 175, 20);
    self.textLabel1.text = @"我";
    self.textLabel1.frame = CGRectMake(150, 62, 175, 20);

//	_detailLabel.text = _detailMsg;
	_timeLabel.text = _time;
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

	frame = _lineView.frame;
	frame.origin.y = self.contentView.frame.size.height - 1;
	_lineView.frame = frame;
}

- (void)setName:(NSString *)name {
	_name = name;
	self.textLabel.text = name;
}

- (void)setName1:(NSString *)name1 {
    _name1 = name1;
    self.textLabel1.text = name1;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100;
}

@end
