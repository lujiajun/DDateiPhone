//
//  ChatRoom4ListCell.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/3.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatRoom4ListCell : UITableViewCell

@property (strong, nonatomic) UIImageView *user1Avatar;
@property (strong, nonatomic) UIImageView *user2Avatar;
@property (strong, nonatomic) UIImageView *user3Avatar;
@property (strong, nonatomic) UIImageView *user4Avatar;

@property (strong, nonatomic) UILabel *user1Name;
@property (strong, nonatomic) UILabel *user2Name;
@property (strong, nonatomic) UILabel *user3Name;
@property (strong, nonatomic) UILabel *user4Name;

@property (strong, nonatomic) UILabel *timeLabel;

@property (nonatomic) NSInteger unreadCount;

+(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
