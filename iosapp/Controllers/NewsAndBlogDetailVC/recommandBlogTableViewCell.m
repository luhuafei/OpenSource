//
//  RecommandBlogTableViewCell.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "RecommandBlogTableViewCell.h"

@implementation RecommandBlogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAbouts:(OSCBlogDetailRecommend *)abouts
{
    _titleLabel.text = abouts.title;
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)abouts.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)abouts.commentCount];
}

@end
