//
//  DBUtil.m
//  RCIMLib
//
//  Created by GeekRRK on 2016/12/28.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "DBUtil.h"
#import <FMDB.h>

@implementation DBUtil

+ (FMDatabase *)shareDateBase {
    static FMDatabase *db;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        NSString *filePath = [CACHE_DIR stringByAppendingPathComponent:@"rcimdb"];
        db = [FMDatabase databaseWithPath:filePath];
        if (![db open]) {
            db = nil;
        }
    });
    
    return db;
}

+ (void)createUserTable {
    NSString *createStarTable = [NSString stringWithFormat:@"create table if not exists %@ (userid text primary key, nick text, thumb text)", USERTABLE];
    [[DBUtil shareDateBase] executeUpdate:createStarTable];
}

+ (void)replaceUserModel:(UserModel *)userModel intoTable:(NSString *)tableName {
    [DBUtil createUserTable];
    
    NSString *replaceSql = [NSString stringWithFormat:
                            @"replace into %@ (userid, nick, thumb) values ('%@', '%@', '%@')",
                            tableName,
                            userModel.userid,
                            userModel.nick,
                            userModel.thumb];
    [[DBUtil shareDateBase] executeUpdate:replaceSql];
}

+ (UserModel *)queryUserModelByUserid:(NSString *)userid fromTable:(NSString *)tableName {
    [DBUtil createUserTable];
    
    UserModel *userModel = [[UserModel alloc] init];
    
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where userid = '%@'", tableName, userid];
    FMResultSet *resultSet = [[DBUtil shareDateBase] executeQuery:querySql];
    if ([resultSet next]) {
        userModel.userid = [resultSet stringForColumn:@"userid"];
        userModel.nick = [resultSet stringForColumn:@"nick"];
        userModel.thumb = [resultSet stringForColumn:@"thumb"];
        
        return userModel;
    }
    
    return nil;
}

@end
