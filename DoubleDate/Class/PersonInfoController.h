
#import <UIKit/UIKit.h>
#import "DDUser.h"

@interface PersonInfoController : UITableViewController

- (void)refreshConfig;

-(void) btnClick;

-(id) initUser:(DDUser *)user;

@end
