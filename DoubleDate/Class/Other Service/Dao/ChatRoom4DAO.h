#import "BaseDAO.h"
#import "CHATROOM4.h"

@interface ChatRoom4DAO : BaseDAO

- (NSMutableArray *)getLocalChatRoom4ByCount:(int) count;
- (CHATROOM4 *)getChatRoom4ByRid:(NSString *)rid;
- (void)insertChatroom4:(CHATROOM4 *)chatRoom4;
- (void)updateChatroom4:(CHATROOM4 *)chatRoom4;
- (NSArray *)queryChatRoom4s;
- (void)delChatRoom4ByRid:(NSString *)rid;
- (CHATROOM4 *)isUniqueRoom:(NSString *)UID1 UID2:(NSString *)UID2 UID3:(NSString *)UID3 UID4:(NSString *)UID4;

- (void)updateLikeByGID:(CHATROOM4 *) room4 ;

- (void)updateSubGroupByGID:(CHATROOM4 *) room4 ;

@end
