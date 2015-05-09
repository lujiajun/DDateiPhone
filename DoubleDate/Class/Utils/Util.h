//
//  Util.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/4.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString *)str1:(NSString *)str1 appendStr2:(NSString *) str2;

+ (NSString *)str1:(NSString *)str1 appendStr2:(NSString *)str2 appendStr3:(NSString *)str3;

+(BOOL) updatePassword:(NSString *) newPassword username:(NSString *) username  oldpassword:(NSString *) oldpassword;

+(NSString*)getToken;
+(BOOL) registerUser:(NSString *) userName password:(NSString *) password;
@end
