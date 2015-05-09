//
//  ChatRoom2DAO.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "BaseDAO.h"
#import "CHATROOM2.h"

@interface ChatRoom2DAO : BaseDAO

- (NSMutableArray *)getLocalChatRoom2ByCount:(int)count;
- (CHATROOM2 *)getChatRoom2ByRid:(NSString *)rid;

@end
