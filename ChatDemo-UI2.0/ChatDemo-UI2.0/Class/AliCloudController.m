#import "AliCloudController.h"
#import "OSSClient.h"
#import "OSSTool.h"
#import "OSSData.h"
#import "OSSLog.h"

@interface AliCloudController()
@property(strong,nonatomic) OSSClient *ossclient;
@property(strong,nonatomic) NSString  *yourBucket;
@property(strong,nonatomic) OSSBucket *bucket;

@end

@implementation AliCloudController


-(void) initSdk{
    
    _ossclient = [OSSClient sharedInstanceManage];
    NSString *accessKey = @"lcuuaVHdllrTjYbK";
    NSString *secretKey = @"d2IBrwuWdv48VdNItyZvGYHNSsGgfk";
    _yourBucket = @"doubledateuser";
        
    [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
        NSString *signature = nil;
        NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
        signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
        signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
        NSLog(@"here signature:%@", signature);
        return signature;
    }];
    [_ossclient setGlobalDefaultBucketAcl:PUBLIC_READ_WRITE];
    [_ossclient setGlobalDefaultBucketHostId:@"oss-cn-beijing.aliyuncs.com"];
    _bucket = [[OSSBucket alloc] initWithBucket:_yourBucket];
    
}

-(NSString *) uploadPic:(NSData *)upData{
    NSError *error = nil;
    NSString *name=self.createUUID;
    OSSData *testData = [[OSSData alloc] initWithBucket:_bucket withKey:self.createUUID];
    [testData setData:upData withType:@"jpg"];
    [testData upload:&error];
    return name;
}
- (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   …
    //   UInt8 byte15;
    // } CFUUIDBytes;
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    
    return uuidStr;
}

@end