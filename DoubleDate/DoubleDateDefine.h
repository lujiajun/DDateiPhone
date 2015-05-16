/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#ifndef ChatDemo_UI2_0_ChatDemoUIDefine_h
#define ChatDemo_UI2_0_ChatDemoUIDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"

#define CHATVIEWBACKGROUNDCOLOR [UIColor colorWithRed:0.936 green:0.932 blue:0.907 alpha:1]

#define DD_DEBUG YES

#define TOTAL_SECONDS 60*5

#define DD_PHOTO_SERVER @"http://doubledatelujiajun.oss-cn-beijing.aliyuncs.com/"
#define DD_PHOTO_URL(name, idx) [NSString stringWithFormat:@"%@%@_photo_%@.jpeg", DD_PHOTO_SERVER, name,idx]
#define DD_PHOTO_KEY(name, idx) [NSString stringWithFormat:@"%@_photo_%@.jpeg", name,idx]

#endif
