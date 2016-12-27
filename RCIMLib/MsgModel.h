//
//  MsgModel.h
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

@interface MsgModel : RCTextMessage

@property (copy, nonatomic) NSString *thumb;
@property (copy, nonatomic) NSString *nick;

@end
