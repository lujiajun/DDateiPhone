//
//  CallSessionViewController.h
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-10-29.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import <UIKit/UIKit.h>

static CTCallCenter *g_callCenter;

typedef enum{
    CallNone = 0,
    CallOut,
    CallIn,
}CallType;

@interface CallSessionViewController : UIViewController

- (instancetype)initCallOutWithSession:(EMCallSession *)callSession;
- (instancetype)initCallInWithSession:(EMCallSession *)callSession;

@end
