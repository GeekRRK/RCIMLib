//
//  DBUtil.h
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/28.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

#define USERTABLE @"usertable"

@interface DBUtil : NSObject

+ (void)createUserTable;

+ (void)replaceUserModel:(UserModel *)userModel intoTable:(NSString *)tableName;

+ (UserModel *)queryUserModelByUserid:(NSString *)userid fromTable:(NSString *)tableName;
    
@end
