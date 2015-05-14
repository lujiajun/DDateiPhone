#import <UIKit/UIKit.h>
#import "AWSDynamoDB_DDUser.h"

@interface IndexViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic) BOOL showOppositeGender;

+ (DDUser *)instanceDDuser;
+ (void)setDDUser:(DDUser *)user;

- (void)initdduser;
- (BOOL)haveDoubleFriend;
- (void)indexAddFriendAction;
-(void) reloadChatRoom2;
@end
