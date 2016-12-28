//
//  ViewController.m
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "ViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "ChatRoomVC.h"
#import "MsgModel.h"

@interface ViewController () <RCIMClientReceiveMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickInitRCIMLibBtn:(id)sender {
    [[RCIMClient sharedRCIMClient] initWithAppKey:@"mgb7ka1nb9q6g"];
    [[RCIMClient sharedRCIMClient] connectWithToken:@"B6DG021oEvs7ouJgOsInTSVp/CNMqpPvPJzshjB++fG5FXnh3Wb3BuBlBL5q/atZAuDNkiJEwCc="
                                            success:^(NSString *userId) {
                                                NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                                                [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
                                                
                                                [[RCIMClient sharedRCIMClient] registerMessageType:[MsgModel class]];
                                            } error:^(RCConnectErrorCode status) {
                                                NSLog(@"登陆的错误码为:%ld", status);
                                            } tokenIncorrect:^{
                                                NSLog(@"token错误");
                                            }];
}

- (IBAction)clickJoinChatRoomBtn:(id)sender {
    APPDELEGATE.msgs = [[NSMutableArray alloc] init];
    
    ChatRoomVC *chatRoomVC = [[ChatRoomVC alloc] init];
    [self.navigationController pushViewController:chatRoomVC animated:YES];
    
    [[RCIMClient sharedRCIMClient] joinChatRoom:@"110" messageCount:20 success:^{
        NSLog(@"加入聊天室成功");
    } error:^(RCErrorCode status) {
        NSLog(@"加入聊天室失败");
    }];
}

- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object {
    if ([message.content isKindOfClass:[MsgModel class]]) {
        MsgModel *msgModel = (MsgModel *)message.content;
        NSLog(@"消息内容：%@", msgModel.msg);
        
        if (message.conversationType == ConversationType_CHATROOM) {
            [APPDELEGATE.msgs addObject:msgModel];
            
            NSLog(@"还剩余的未接收的消息数：%d", nLeft);
            
            if (nLeft == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"update_msgs" object:nil];
            }
        }
    }
}

@end
