#import "AliCloudController.h"
#import "OSSClient.h"
#import "OSSTool.h"
#import "OSSData.h"
#import "OSSLog.h"
#import "DDBDynamoDB.h"
#import "DDUserDAO.h"

@interface AliCloudController()
@property(strong,nonatomic) OSSClient *ossclient;
@property(strong,nonatomic) NSString  *yourBucket;

@end

static OSSBucket *bucket;
@implementation AliCloudController


-(void) initSdk{
    
    _ossclient = [OSSClient sharedInstanceManage];
    NSString *accessKey = @"0Ys9RBjY6FOVGeYd";
    NSString *secretKey = @"DrqT4WbMCkGLJJ5MTvscW7iFuR9yNk";
//    _yourBucket = @"doubledateuser";
    _yourBucket = @"doubledatelujiajun";
    
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
    bucket = [[OSSBucket alloc] initWithBucket:_yourBucket];
    
}

-(void) uploadPic:(NSData *)upData name:(NSString *) name{
    NSError *error = nil;
    OSSData *testData = [[OSSData alloc] initWithBucket:bucket withKey:name];
    [testData setData:upData withType:@"jpg"];
    [testData upload:&error];
    
}

-(void) updateHeadPic:(NSData *)upData name:(NSString *) name
{
    
    OSSData *testData = [[OSSData alloc] initWithBucket:bucket withKey:name];
    NSError *error = nil;
    [testData delete:&error];
    //插入
    [self uploadPic:upData name:name];
}

//OSS ,username_1
//1|2|3|4
-(void) asynUploadPic:(NSData *) upData name:(NSString *) picname username:(NSString *) username{
    OSSData *testData = [[OSSData alloc] initWithBucket:bucket withKey:[[username stringByAppendingString:@"_"] stringByAppendingString:picname]];
    [testData setData:upData withType:@"jpg"];
    [testData uploadWithUploadCallback:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
           //成功了，则插入AWS
            DDBDynamoDB *dynamoDB=[DDBDynamoDB alloc];
            DDUserDAO *dao=[[DDUserDAO alloc]init];
            DDUser *dduser= [dao selectDDuserByUid:username];
            if(dduser!=nil){
                if(dduser.photos==nil){
                    dduser.photos=[picname stringByAppendingString:@","];
                }else{
                    dduser.photos=[[dduser.photos stringByAppendingString:picname] stringByAppendingString:@","];
                }
                
                [dao updatePhotosByUID:dduser.photos uid:username];
                //更新AWS
                [dynamoDB insertTableRow:dduser];
            }
            
            //修改本地
        } else {
            NSLog(@"errorInfo_testDataUploadWithProgress:%@", [error userInfo]);
        }
    } withProgressCallback:^(float progress) { NSLog(@"current get %f", progress);
    }];
    
}

-(NSString *) uploadPic:(NSData *)upData{
    NSError *error = nil;
    NSString *name=self.createUUID;
    OSSData *testData = [[OSSData alloc] initWithBucket:bucket withKey:self.createUUID];
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
//    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    
    return uuidStr;
}

@end