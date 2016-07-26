//
//  TitleInfoTableViewCell.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TitleInfoTableViewCell.h"

@implementation TitleInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (void)setBlogDetail:(OSCBlogDetail *)blogDetail
{
    if (blogDetail.recommend) {//推荐
        _recommendTagIv.image = [UIImage imageNamed:@"ic_label_recommend"];
        _propertyTagIv.hidden = NO;
        if (blogDetail.original) {//原
            _propertyTagIv.image = [UIImage imageNamed:@"ic_label_originate"];
        } else {//转
            _propertyTagIv.image = [UIImage imageNamed:@"ic_label_reprint"];
        }
    } else {
        _propertyTagIv.hidden = YES;
        if (blogDetail.original) {//原
            _recommendTagIv.image = [UIImage imageNamed:@"ic_label_originate"];
        } else {//转
            _recommendTagIv.image = [UIImage imageNamed:@"ic_label_reprint"];
        }
    }
    
    _TitleLabel.text = blogDetail.title;
    _viewCountLabel.text = [NSString stringWithFormat:@"%ld", (long)blogDetail.viewCount];
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)blogDetail.commentCount];
}

@end
