//
//  ViewController.m
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "ViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "AppDelegate.h"
#import "ChatRoomVC.h"
#import "MsgModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickJoinChatRoomBtn:(id)sender {
    AppDelegate *appDelegate = ((AppDelegate *)([UIApplication sharedApplication].delegate));
    appDelegate.msgs = [[NSMutableArray alloc] init];
    
    ChatRoomVC *chatRoomVC = [[ChatRoomVC alloc] init];
    [self.navigationController pushViewController:chatRoomVC animated:YES];
    
    [[RCIMClient sharedRCIMClient] joinChatRoom:@"110" messageCount:20 success:^{
        NSLog(@"加入聊天室成功");
    } error:^(RCErrorCode status) {
        NSLog(@"加入聊天室失败");
    }];
}

@end
