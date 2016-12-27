//
//  AppDelegate.m
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "AppDelegate.h"
#import <RongIMLib/RongIMLib.h>
#import "MsgModel.h"

@interface AppDelegate () <RCIMClientReceiveMessageDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[RCIMClient sharedRCIMClient] initWithAppKey:@"mgb7ka1nb9q6g"];
    [[RCIMClient sharedRCIMClient] connectWithToken:@"B6DG021oEvs7ouJgOsInTSVp/CNMqpPvPJzshjB++fG5FXnh3Wb3BuBlBL5q/atZAuDNkiJEwCc="
                                            success:^(NSString *userId) {
                                                NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                                                [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
                                            } error:^(RCConnectErrorCode status) {
                                                NSLog(@"登陆的错误码为:%ld", status);
                                            } tokenIncorrect:^{
                                                NSLog(@"token错误");
                                            }];
    
    return YES;
}

- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object {
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        NSLog(@"消息内容：%@", testMessage.content);
        
        if (message.conversationType == ConversationType_CHATROOM) {
            [_msgs addObject:testMessage];
            
            if (nLeft == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"update_msgs" object:nil];
            }
        }
    }
    
    NSLog(@"还剩余的未接收的消息数：%d", nLeft);
}

@end
