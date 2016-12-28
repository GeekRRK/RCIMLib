//
//  ChatRoomVC.m
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "ChatRoomVC.h"
#import <RongIMLib/RongIMLib.h>
#import "MsgRightCell.h"
#import "MsgLeftCell.h"
#import "AppDelegate.h"
#import "MsgModel.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface ChatRoomVC () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *msgs;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UITextField *inputTextField;

@end

@implementation ChatRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天室";
    
    CGRect rect = self.view.bounds;
    rect.size.height -= 44;
    
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [_tableView addGestureRecognizer:tapGest];
    
    float screenWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tableView.frame), screenWidth, 44)];
    [self.view addSubview:_inputTextField];
    _inputTextField.delegate = self;
    _inputTextField.backgroundColor = [UIColor whiteColor];
    _inputTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _inputTextField.layer.borderWidth = 2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMsgs) name:@"update_msgs" object:nil];
}

- (void)hideKeyboard {
    [_inputTextField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_tableView.contentSize.height > _tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
        [_tableView setContentOffset:offset animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _inputTextField) {
        RCTextMessage *msgModel = [RCTextMessage messageWithContent:_inputTextField.text];
        
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM
                                          targetId:@"110"
                                           content:msgModel
                                       pushContent:nil
                                          pushData:nil
                                           success:^(long messageId) {
                                               NSLog(@"发送成功。当前消息ID：%ld", messageId);
                                               
                                               AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
                                               [appDelegate.msgs addObject:msgModel];
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   textField.text = @"";
                                                   [_tableView reloadData];
                                                   
                                                   if (_tableView.contentSize.height > _tableView.frame.size.height) {
                                                       CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
                                                       [_tableView setContentOffset:offset animated:YES];
                                                   }
                                               });
                                           } error:^(RCErrorCode nErrorCode, long messageId) {
                                               NSLog(@"发送失败。消息ID：%ld， 错误码：%ld", messageId, nErrorCode);
                                           }];
        
        return NO;
    }
    return YES;
}

- (void)updateMsgs {
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    _msgs = appDelegate.msgs;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgModel *msgModel = _msgs[indexPath.row];
    
    UIFont *font = [UIFont systemFontOfSize:12];
    
    float screenWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    
    CGSize size = [self textDynamicHeight:msgModel.content fixedWidth:screenWidth - 44 - 3 * 8 fontSize:font];
    float addedH = 0;
    if (size.height > 15) {
        addedH += size.height - 15;
    }
    
    return 60 + addedH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCTextMessage *msgModel = _msgs[indexPath.row];
    
    if ([msgModel.senderUserInfo.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        NSString *reusableRightCell = @"ReusableRightCell";
        MsgRightCell *rightCell = [tableView dequeueReusableCellWithIdentifier:reusableRightCell];
        
        if (rightCell == nil) {
            rightCell = [[[NSBundle mainBundle] loadNibNamed:@"MsgRightCell" owner:nil options:nil] firstObject];
        }
        
        [rightCell.avatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:@"http://diy.qqjay.com/u2/2012/0924/7032b10ffcdfc9b096ac46bde0d2925b.jpg"] forState:UIControlStateNormal];
        rightCell.nameLabel.text = @"nick";
        rightCell.msgLabel.text = msgModel.content;
        rightCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return rightCell;
    } else {
        NSString *reusableLeftCell = @"ReusableLeftCell";
        MsgLeftCell *leftCell = [tableView dequeueReusableCellWithIdentifier:reusableLeftCell];
        if (leftCell == nil) {
            leftCell = [[[NSBundle mainBundle] loadNibNamed:@"MsgLeftCell" owner:nil options:nil] firstObject];
        }
        
        [leftCell.avatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:@"http://diy.qqjay.com/u2/2012/0924/7032b10ffcdfc9b096ac46bde0d2925b.jpg"] forState:UIControlStateNormal];
        leftCell.nameLabel.text = @"nick";
        leftCell.msgLabel.text = msgModel.content;
        leftCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return leftCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGSize)textDynamicHeight:(NSString *)text fixedWidth:(CGFloat)width fontSize:(UIFont *)font {
    return [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{
                                        NSFontAttributeName : font
                                        }
                              context:nil].size;
}

@end
