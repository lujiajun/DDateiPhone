//
//  DDDataManager.h
//  DoubleDate
//
//  Created by liruqi on 5/16/15.
//  Copyright (c) 2015 liruqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDUserDAO.h"
#import "AliCloudController.h"

@interface DDDataManager : NSObject


+ (DDDataManager*) sharedManager;

- (int) loadUser: (NSString*) uid;
- (DDUser*) user;
- (void) saveUser: (DDUser*) user;
- (AliCloudController*) aliCloud;

@end
