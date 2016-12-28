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
        MsgModel *msgModel = [[MsgModel alloc] init];
        
        msgModel.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
        msgModel.thumb = @"http://diy.qqjay.com/u2/2012/0924/7032b10ffcdfc9b096ac46bde0d2925b.jpg";
        msgModel.nick = [RCIMClient sharedRCIMClient].currentUserInfo.name;
        msgModel.msg = _inputTextField.text;
        
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM
                                          targetId:@"110"
                                           content:msgModel
                                       pushContent:nil
                                          pushData:nil
                                           success:^(long messageId) {
                                               NSLog(@"发送成功。当前消息ID：%ld", messageId);
                                               
                                               [APPDELEGATE.msgs addObject:msgModel];
                                               
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
    _msgs = APPDELEGATE.msgs;
    
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
    
    CGSize size = [self textDynamicHeight:msgModel.msg fixedWidth:screenWidth - 44 - 3 * 8 fontSize:font];
    float addedH = 0;
    if (size.height > 15) {
        addedH += size.height - 15;
    }
    
    return 60 + addedH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgModel *msgModel = _msgs[indexPath.row];
    MsgRightCell *cell;
    NSString *reusableCell;
    
    if ([msgModel.userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        reusableCell= @"ReusableRightCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:reusableCell];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MsgRightCell" owner:nil options:nil] firstObject];
        }
    } else {
        reusableCell = @"ReusableLeftCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:reusableCell];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MsgLeftCell" owner:nil options:nil] firstObject];
        }
    }
    
    [cell.avatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:msgModel.thumb] forState:UIControlStateNormal];
    cell.nameLabel.text = msgModel.nick;
    cell.msgLabel.text = msgModel.msg;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
