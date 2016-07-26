//
//  ActivityDetailCell.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityDetailCell.h"
#import "Utils.h"

@implementation ActivityDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _label.hidden = NO;
    _iconImageView.hidden = NO;
    _ActivityWebView.hidden = YES;
    
    _ActivityWebView.scrollView.bounces = NO;
    _ActivityWebView.scrollView.scrollEnabled = NO;
    _ActivityWebView.opaque = NO;
    _ActivityWebView.backgroundColor = [UIColor themeColor];
}

- (void)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString:@"timeType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        _ActivityWebView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_ calendar"];
    } else if ([identifier isEqualToString:@"addressType"]) {
        _label.hidden = NO;
        _iconImageView.hidden = NO;
        _ActivityWebView.hidden = YES;
        
        _iconImageView.image = [UIImage imageNamed:@"ic_location"];
    } else if ([identifier isEqualToString:@"descType"]) {
        _label.hidden = YES;
        _iconImageView.hidden = YES;
        _ActivityWebView.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - CONTENT

- (void)setEventDetail:(OSCActivity *)eventDetail
{
    [self dequeueReusableCellWithIdentifier:_cellType];
    
    if ([_cellType isEqualToString:@"timeType"]) {
        _label.text = [NSString stringWithFormat:@"%@", eventDetail.startTime];
    } else if ([_cellType isEqualToString:@"addressType"]) {
        _label.text = eventDetail.location;
    }
}

@end
