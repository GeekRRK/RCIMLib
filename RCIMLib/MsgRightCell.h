//
//  MsgCell.h
//  RCIMLib
//
//  Created by UGOMEDIA on 2016/12/27.
//  Copyright © 2016年 GeekRRK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgRightCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImgView;

@end
