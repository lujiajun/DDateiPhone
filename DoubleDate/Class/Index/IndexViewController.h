
#import <UIKit/UIKit.h>
#import "AWSDynamoDB_DDUser.h"

@interface IndexViewController : UITableViewController

+(DDUser *) instanceDDuser;
+(void) setDDUser:(DDUser *) user;

- (void)initdduser;
-(BOOL) haveDoubleFriend;
@end
