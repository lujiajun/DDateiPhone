//
//  DDUserDAO.h
//  ChatDemo-UI2.0
//
//  Created by Jeffrey on 15/4/30.
//  Copyright (c) 2015年 Jeffrey. All rights reserved.
//

#import "BaseDAO.h"
#import "DDUser.h"

@interface DDUserDAO : BaseDAO

- (DDUser *) selectDDuserByUid:(NSString *)uid;


- (void)insertDDUser:(DDUser *)dduser ;
- (void)updatePhotosByUID:(NSString *)photos uid:(NSString *) UID;
- (void)updateByUID:(DDUser *)user;
@end
