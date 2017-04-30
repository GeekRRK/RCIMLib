//
//  MsgModel.m
//  RCIMLib
//
//  Created by GeekRRK on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "MsgModel.h"

@implementation MsgModel

+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

- (void)decodeWithData:(NSData *)data {
    __autoreleasing NSError *__error = nil;
    if (!data) {
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&__error];
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (!__error && dict) {
        self.userId = [dict objectForKey:@"userId"];
        self.thumb = [dict objectForKey:@"thumb"];
        self.nick = [dict objectForKey:@"nick"];
        self.msg = [dict objectForKey:@"msg"];
        NSDictionary *userinfoDic = [dict objectForKey:@"user"];
        [self decodeUserInfo:userinfoDic];
    } else {
        self.rawJSONData = data;
    }
}

- (NSData *)encode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.userId) {
        [dict setObject:self.userId forKey:@"userId"];
    }
    
    if (self.thumb) {
        [dict setObject:self.thumb forKey:@"thumb"];
    }
    
    if (self.nick) {
        [dict setObject:self.nick forKey:@"nick"];
    }
    
    if (self.msg) {
        [dict setObject:self.msg forKey:@"msg"];
    }
    
    if (self.senderUserInfo) {
        NSMutableDictionary *__dic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [__dic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
        }
        [dict setObject:__dic forKey:@"user"];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    return jsonData;
}

+ (NSString *)getObjectName {
    return @"MsgModel";
}

@end
