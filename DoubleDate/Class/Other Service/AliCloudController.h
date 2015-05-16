#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface AliCloudController : BaseViewController
-(void) initSdk;
-(NSString *) uploadPic:(NSData *) upData;
- (NSString *)createUUID;

-(void) uploadPic:(NSData *)upData name:(NSString *) name;

-(void) asynUploadPic:(NSData *) upData name:(NSString *) picname username:(NSString *) username;
-(void) asynUploadPic:(NSData *) upData key:(NSString *) key callback:(void (^)(BOOL, NSError *)) cb;

-(void) updateHeadPic:(NSData *)upData name:(NSString *) name;

@end