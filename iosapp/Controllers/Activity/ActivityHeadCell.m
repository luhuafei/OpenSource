//
//  ActivityHeadCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityHeadCell.h"
#import "Utils.h"

@interface ActivityHeadCell ()

@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *catalogLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *applyLabel;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;

@end

@implementation ActivityHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    _typeButton.layer.borderWidth = 1.0;
    _typeButton.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
    [_typeButton setTitleColor:[UIColor colorWithHex:0xffffff] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentForHeadCell:(OSCPostDetails *)detailPost activity:(OSCActivity *)activity
{
    [_activityImageView loadPortrait:activity.coverURL];
    _titleLable.text = detailPost.title;
    _authorLabel.text = [NSString stringWithFormat:@"发起人：%@", detailPost.author];
    _catalogLabel.text = [self categoryString:activity];
    _priceLabel.text = @"";
    _applyLabel.text = [NSString stringWithFormat:@"%d人参与", detailPost.viewCount];
    
    [self typeActivityStatus:activity];
}

/* 活动状态按钮 */
- (void)typeActivityStatus:(OSCActivity *)activity
{
    NSString *string = @"";
    if (activity.status == ActivityStatusActivityFinished) {
        string = @"源创会";
    } else if (activity.status == ActivityStatusGoing) {
        string = @"技术交流";
    } else if (activity.status == ActivityStatusSignUpClosing) {
        string = @"其他";
    }
    [_typeButton setTitle:string forState:UIControlStateNormal];
}
/* 活动类型 */
- (NSString *)categoryString:(OSCActivity *)activity
{
    NSString *string = @"";
    if (activity.category == ActivityCategoryStatusOSChinaMeeting) {
        string = @"源创会";
    } else if (activity.category == ActivityCategoryStatusTechnical) {
        string = @"技术交流";
    } else if (activity.category == ActivityCategoryStatusOther) {
        string = @"其他";
    } else if (activity.category == ActivityCategoryStatuseBelow) {
        string = @"站外活动";
    }
    
    return [NSString stringWithFormat:@"类型：%@", string];
}

@end
