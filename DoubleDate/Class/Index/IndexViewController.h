#import <UIKit/UIKit.h>
#import "AWSDynamoDB_DDUser.h"

@interface IndexViewController : UIViewController

@property (strong, nonatomic) UITableView *tableView;

+ (DDUser *)instanceDDuser;
+ (void)setDDUser:(DDUser *)user;

- (void)initdduser;
- (BOOL)haveDoubleFriend;
@end
