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

@end

