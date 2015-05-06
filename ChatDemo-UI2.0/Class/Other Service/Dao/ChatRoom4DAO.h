#import "BaseDAO.h"
#import "ChatRoom4DB.h"

@interface ChatRoom4DAO : BaseDAO

@property (strong, nonatomic) NSArray *chatroom4s;

- (void)refreshList;
- (void)insertChatroom4:(CHATROOM4 *)chatRoom4;
- (NSArray *)queryChatRoom4s;
-(void)delChatRoom4ByRid:(NSString *)rid;
-(CHATROOM4 *) isUniqueRoom:(NSString *) UID1 UID2:(NSString *) UID2 UID3:(NSString *) UID3 UID4:(NSString *) UID4;

@end
