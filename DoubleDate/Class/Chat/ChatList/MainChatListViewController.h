//
//  MainChatListViewController.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/28.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MainChatListViewController : BaseViewController

- (void)refreshDataSource;

- (void)isConnect:(BOOL)isConnect;
- (void)networkChanged:(EMConnectionState)connectionState;

@end
