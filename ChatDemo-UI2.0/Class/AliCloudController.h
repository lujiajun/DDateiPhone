#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface AliCloudController : BaseViewController
-(void) initSdk;
-(NSString *) uploadPic:(NSData *) upData;
- (NSString *)createUUID;
@end