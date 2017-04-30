//
//  MsgCell.m
//  RCIMLib
//
//  Created by GeekRRK on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import "MsgLeftCell.h"

@implementation MsgLeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _bubbleImgView.image = [UIImage imageNamed:@"chat_from_bg_normal"];
    self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
