
#import <UIKit/UIKit.h>
#import "DDBDynamoDB.h"

@interface IndexViewController : UITableViewController

+(DDUser *) instanceDDuser;
+(void) setDDUser:(DDUser *) user;

- (void)initdduser;
@end
