//
//  ChatRoom2DAO.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "BaseDAO.h"

@interface ChatRoom2DAO : BaseDAO

@property(strong, nonatomic) NSArray *chatroom2s;

- (void)refreshList;

@end
