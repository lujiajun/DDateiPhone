//
//  DDDataManager.m
//  DoubleDate
//
//  Created by liruqi on 5/16/15.
//  Copyright (c) 2015 liruqi. All rights reserved.
//

#import "DDDataManager.h"
#import "AWSDynamoDB_DDUser.h"
#import "SVProgressHUD.h"

static DDDataManager *dataManager;

@interface DDDataManager()
{
    unsigned int _state;
    AWSDynamoDB_DDUser *_awsDBUser;
    AliCloudController *_aliCloud;
}

@property (nonatomic, retain) DDUser *user;

@end

@implementation DDDataManager


+ (DDDataManager*) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[DDDataManager alloc] init];
        dataManager->_state = 0;
        dataManager->_awsDBUser = [[AWSDynamoDB_DDUser alloc] init];
        dataManager->_aliCloud = [AliCloudController alloc];
        [dataManager->_aliCloud initSdk];
    });
    return dataManager;
}

- (int) loadUser: (NSString*) uid {
    if (_state > 0) {
        return _state;
    }
    _state = 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    [_awsDBUser getUserByUID:uid withBlock:^(DDUser* user) {
        if (user) {
            self.user = user;
            self->_state = 2;
        } else {
            self->_state = 0;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
    return _state;
}

- (void) saveUser: (DDUser*) user {
    if (user) {
        _state = 2;
        self.user = user;
        [_awsDBUser updateDDUser:user];
    } else {
        _state = 0;
        self.user = nil;
    }
}

- (AliCloudController*) aliCloud {
    return _aliCloud;
}

- (BOOL) haveAnyFriends {
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    return buddyList.count > 0;
}
@end
