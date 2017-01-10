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
#import "DBUtil.h"

#ifdef iOS_USER
    #define AVATAR @"http://diy.qqjay.com/u2/2012/0924/7032b10ffcdfc9b096ac46bde0d2925b.jpg"
    #define NICK @"iOS"
#else 
    #define AVATAR @"http://diy.qqjay.com/u2/2012/1118/ed0d58cbf87895c01196d560133dd8ba.jpg"
    #define NICK @"Android"
#endif

@interface ChatRoomVC () <UITableViewDelegate, UITableViewDataSource>

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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [_tableView addGestureRecognizer:tapGest];
    
    float btnW = 55;
    float btnH = 40;
    
    float screenWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_tableView.frame) + 2, screenWidth - btnW - 5 - 10, btnH)];
    [self.view addSubview:_inputTextField];
    _inputTextField.backgroundColor = [UIColor whiteColor];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.frame = CGRectMake(CGRectGetMaxX(_inputTextField.frame) + 5, CGRectGetMinY(_inputTextField.frame), btnW, btnH);
    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.cornerRadius = 2.5;
    sendBtn.backgroundColor = [UIColor colorWithRed:0 green:0.6 blue:1 alpha:1.0];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMsgs) name:@"update_msgs" object:nil];
}

- (void)clickSendBtn {
    MsgModel *msgModel = [[MsgModel alloc] init];
    
    msgModel.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    msgModel.thumb = AVATAR;
    msgModel.nick = NICK;
    msgModel.msg = _inputTextField.text;
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM
                                      targetId:@"110"
                                       content:msgModel
                                   pushContent:nil
                                      pushData:nil
                                       success:^(long messageId) {
                                           NSLog(@"发送成功。当前消息ID：%ld", messageId);
                                           
                                           UserModel *userModel = [[UserModel alloc] init];
                                           userModel.userid = msgModel.userId;
                                           userModel.thumb = msgModel.thumb;
                                           userModel.nick = msgModel.nick;
                                           [DBUtil replaceUserModel:userModel intoTable:USERTABLE];
                                           
                                           [APPDELEGATE.msgs addObject:msgModel];
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               _inputTextField.text = @"";
                                               [_tableView reloadData];
                                               
                                               if (_tableView.contentSize.height > _tableView.frame.size.height) {
                                                   CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
                                                   [_tableView setContentOffset:offset animated:YES];
                                               }
                                           });
                                       } error:^(RCErrorCode nErrorCode, long messageId) {
                                           NSLog(@"发送失败。消息ID：%ld， 错误码：%ld", messageId, nErrorCode);
                                       }];
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

- (void)updateMsgs {
    _msgs = APPDELEGATE.msgs;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        
        if (_tableView.contentSize.height > _tableView.frame.size.height) {
            CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height);
            [_tableView setContentOffset:offset animated:YES];
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgModel *msgModel = _msgs[indexPath.row];
    
    UIFont *font = [UIFont systemFontOfSize:12];
    
    float screenWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    
    CGSize size = [self textDynamicHeight:msgModel.msg fixedWidth:screenWidth - 44 - 3 * 8 - 10 fontSize:font];
    float addedH = 0;
    if (size.height > 15) {
        addedH += size.height - 15;
    }
    
    return 60 + addedH + 16;
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
    
    UserModel *userModel = [DBUtil queryUserModelByUserid:msgModel.userId fromTable:USERTABLE];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *thumb;
    NSString *nick;
    
    if (userModel) {
        thumb = userModel.thumb;
        nick = userModel.nick;
    } else {
        thumb = msgModel.thumb;
        nick = msgModel.nick;
    }
    
    [cell.avatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:thumb] forState:UIControlStateNormal];
    cell.nameLabel.text = nick;
    cell.msgLabel.text = msgModel.msg;
    
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
