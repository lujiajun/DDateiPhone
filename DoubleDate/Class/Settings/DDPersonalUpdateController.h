
#import <UIKit/UIKit.h>

@interface DDPersonalUpdateController : UIViewController

- (id)init:(NSString *)username password:(NSString *)password city:(NSString *)city university:(NSString *)university;

- (id)init:(NSString *)nickname gender:(NSString *)gender grade:(NSString *)grade university:(NSString *)university city:(NSString *)city;

@end