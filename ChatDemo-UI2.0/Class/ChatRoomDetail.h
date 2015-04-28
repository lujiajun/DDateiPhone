#import <UIKit/UIKit.h>
#import "DDBDynamoDB.h"


@interface ChatRoomDetail : UITableViewController
-(id) initChatRoom:(DDUser *) uuser1 uuser2:(DDUser *) uuser2  motto:(NSString *) motto;
@end