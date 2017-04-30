//
//  MsgModel.h
//  RCIMLib
//
//  Created by GeekRRK on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface MsgModel : RCMessageContent

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *thumb;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) NSString *msg;

@end
