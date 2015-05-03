#import "BaseDAO.h"
#import "ChatRoom4DB.h"

@interface ChatRoom4DAO : BaseDAO

@property (strong, nonatomic) NSArray *chatroom4s;

- (void)refreshList;
- (void)insertChatroom4:(CHATROOM4 *)chatRoom4;
- (NSArray *)queryChatRoom4s;

@end
