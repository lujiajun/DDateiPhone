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

#import <UIKit/UIKit.h>
#import "CHATROOM4.h"
@interface ChatViewController : UIViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup isSubGroup:(BOOL)isSubGroup;

- (void)reloadData;

- (id)initRoom4:(CHATROOM4 *)room4 friend:(NSString *)friend isNewRoom:(BOOL)isNewRoom;

@end
