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

- (void)insertLocalChatroom2:(CHATROOM2 *)chatRoom2;

- (CHATROOM2 *)getLocalChatRoom2ByRid:(NSString *)rid;

- (NSMutableArray *)getLocalChatRoom2sByCount:(int)count;

- (void)delChatRoom4ByRid:(NSString *)rid ;

@end
