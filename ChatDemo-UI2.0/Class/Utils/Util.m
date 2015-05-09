//
//  Util.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/4.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "Util.h"

@implementation Util


+ (NSString *)str1:(NSString *)str1 appendStr2:(NSString *)str2 {
	return [NSString stringWithFormat:@"%@%@", str1 == nil ? @"" : str1, str2 == nil ? @"" : str2];
}

+ (NSString *)str1:(NSString *)str1 appendStr2:(NSString *)str2 appendStr3:(NSString *)str3 {
	str1 = str1 == nil ? @"" : str1;
	str2 = str2 == nil ? @"" : str2;
	str3 = str3 == nil ? @"" : str3;
	return [NSString stringWithFormat:@"%@%@%@", str1, str2, str3];
}

+(NSString *)getToken{
    //第一步，创建URL
//    NSString *orgname=@"doubledate";
//    NSString *appname=@"doubledate";
//    NSString *clientid=@"YXA69sABINDUEeSJTcEVdBD_aw";
//    NSString *clientsecret=@"YXA6cNuqH-9TG82JLXmVYZPAGRFZ7cM";
    
    NSURL *url = [NSURL URLWithString:@"https://a1.easemob.com/doubledate/doubledate/token"];
    
    //第二步，创建请求
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET

    NSString *str = @"{\"grant_type\": \"client_credentials\",\"client_id\": \"YXA69sABINDUEeSJTcEVdBD_aw\",\"client_secret\": \"YXA6cNuqH-9TG82JLXmVYZPAGRFZ7cM\"}";//设置参数
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //第三步，连接服务器
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSLog([[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding]);
    
    NSDictionary *tokenInfo = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSLog([tokenInfo objectForKey:@"access_token"]);
    return  [tokenInfo objectForKey:@"access_token"];
    //修改密码
   
    
//    NSLog(@"%@",str1);
    return @"";
}

+(BOOL) updatePassword:(NSString *) newPassword username:(NSString *) username oldpassword:(NSString *) oldpassword{
    
    NSURL *url = [NSURL URLWithString:[[[@"https://a1.easemob.com/doubledate/doubledate/users/" stringByAppendingString:username] stringByAppendingString:@"/" ] stringByAppendingString:oldpassword]];
    
    //第二步，创建请求 /{org_name}/{app_name}/users/{username}/password
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"PUT"];//设置请求方式为POST，默认为GET
    
    //    Request Headers : {“Content-Type”:”application/json”}
    
    NSString *str = [[@"{\"newpassword\" : \"${" stringByAppendingString: newPassword ] stringByAppendingString:@"}\"}"];//设置参数
    
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    //Request Headers : {“Authorization”:”Bearer ${token}”}
//    [request setValue: [[@"Bearer ${" stringByAppendingString:Util.getToken] stringByAppendingString:@"}\""] forHTTPHeaderField:@"Authorization"];
    
    //第三步，连接服务器
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSLog([[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding]);
    //    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if(!error){
        return NO;
    }
    return YES;
}

@end

