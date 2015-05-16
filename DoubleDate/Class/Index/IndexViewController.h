#import <UIKit/UIKit.h>
#import "AWSDynamoDB_DDUser.h"

@interface IndexViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic) BOOL showOppositeGender;

- (BOOL)haveDoubleFriend;
- (void)indexAddFriendAction;
-(void) reloadChatRoom2;
@end
