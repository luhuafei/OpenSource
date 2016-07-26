//
//  NewCommentCell.h
//  iosapp
//
//  Created by 李萍 on 16/6/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"

@interface NewCommentCell : UITableViewCell

@property (strong, nonatomic) UIImageView *commentPortrait;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIButton *commentButton;

@property (nonatomic, strong) UIView *currentContainer;

@property (nonatomic, strong) OSCBlogDetailComment *comment;

@end

