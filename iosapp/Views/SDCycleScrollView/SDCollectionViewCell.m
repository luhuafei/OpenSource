//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDCollectionViewCell.h"
#import "UIView+SDExtension.h"

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
    __weak UILabel *_titleTextLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
    }
    
    return self;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
//    _titleLabelTextColor = titleLabelTextColor;
//    _titleLabel.textColor = titleLabelTextColor;
    
    _titleLabelTextColor = titleLabelTextColor;
    _titleTextLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleTextLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
//    _titleLabel.hidden = YES;
    [self.contentView addSubview:titleLabel];
    
    UILabel *titleTextLabel = [[UILabel alloc] init];
    _titleTextLabel = titleTextLabel;
    _titleTextLabel.backgroundColor = [UIColor clearColor];
//    _titleTextLabel.hidden = YES;
    [self.contentView addSubview:titleTextLabel];
    
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
//    _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
    _titleTextLabel.text = [NSString stringWithFormat:@"   %@", title];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    
    CGFloat titleLabelW = self.sd_width;
    CGFloat titleLabelH = _titleLabelHeight;
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = self.sd_height - titleLabelH;
    _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
//    _titleLabel.hidden = !_titleLabel.text;
    
    _titleTextLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW-60, titleLabelH);
}

@end
