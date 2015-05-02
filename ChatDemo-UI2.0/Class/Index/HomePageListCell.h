//
//  HomePageListCell.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/2.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface HomePageListCell : UITableViewCell

@property(strong, nonatomic) EGOImageView *bakview;
@property(strong, nonatomic) EGOImageView *user1Avatar;
@property(strong, nonatomic) EGOImageView *user2Avatar;
@property(strong, nonatomic) UIImageView *genderView;
@property(strong, nonatomic) UILabel *clicknumber;
@property(strong, nonatomic) UILabel *motto;

@end
