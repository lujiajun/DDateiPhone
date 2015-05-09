//
//  UIColor+Category.m
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/5/4.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "UIColor+Category.h"

#define MAX_COLOR_VALUE 255.0

@implementation UIColor (Category)

+ (UIColor *)colorWithR:(int)red G:(int)green B:(int)blue {
	return [UIColor colorWithRed:red / MAX_COLOR_VALUE green:green / MAX_COLOR_VALUE blue:blue / MAX_COLOR_VALUE alpha:1];
}

@end
