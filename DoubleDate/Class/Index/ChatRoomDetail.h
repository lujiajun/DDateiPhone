#import <UIKit/UIKit.h>
#import "DDUser.h"
#import "CHATROOM2.h"


@interface ChatRoomDetail : UIViewController
-(id) initChatRoom:(CHATROOM2 *) room  uuser1:(DDUser *) uuser1 uuser2:(DDUser *) uuser2;

@property (nonatomic, strong) NSString *doublerId;
@end