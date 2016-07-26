//
//  NewCommentCell.m
//  iosapp
//
//  Created by 李萍 on 16/6/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewCommentCell.h"
#import "Utils.h"

@implementation NewCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setLayOutForSubView];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLayOutForSubView
{
    _commentPortrait = [UIImageView new];
    _commentPortrait.layer.cornerRadius = 16;
    _commentPortrait.clipsToBounds = YES;
    _commentPortrait.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:_commentPortrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = [UIColor colorWithHex:0x111111];
    [self.contentView addSubview:_nameLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    _timeLabel.textColor = [UIColor colorWithHex:0x9d9d9d];
    [self.contentView addSubview:_timeLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = [UIColor colorWithHex:0x111111];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_contentLabel];
    
    _currentContainer = [UIView new];
    [self.contentView addSubview:_currentContainer];

    _commentButton = [UIButton new];
    [_commentButton setImage:[UIImage imageNamed:@"ic_comment_30"] forState:UIControlStateNormal];
    [self.contentView addSubview:_commentButton];
    
    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_commentPortrait, _nameLabel, _timeLabel, _currentContainer, _contentLabel, _commentButton);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_commentPortrait(32)]-<=7-[_currentContainer]-7-[_contentLabel]-16-|"
                                                                 options:NSLayoutFormatAlignAllLeft
                                                                 metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_nameLabel]-2-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]-<=7-[_currentContainer]-7-[_contentLabel]-16-|"
                                                                             options:0
                                                                             metrics:nil views:views]];
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[_commentButton(20)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[_commentPortrait(32)]-8-[_nameLabel]-8-[_commentButton(30)]-10-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[_currentContainer]-16-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-16-[_contentLabel]-16-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
}

#pragma mark - contentData

- (void)setComment:(OSCBlogDetailComment *)comment
{
    [_commentPortrait loadPortrait:[NSURL URLWithString:comment.authorPortrait]];
    _nameLabel.text = comment.author;
    _timeLabel.text = [[NSDate dateFromString:comment.pubDate] timeAgoSinceNow];
    
     NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.content]];
    _contentLabel.attributedText = contentString;
    
    if (comment.refer.author.length > 0) {
        _currentContainer.hidden = NO;
        [self setLayOutForRefer:comment.refer];
    } else {
        _currentContainer.hidden = YES;
    }
    
}

#pragma mark - refer
- (void)setLayOutForRefer:(OSCBlogCommentRefer *)refer
{
    if (refer.author.length  <= 0) {
        return;
    }
    while (refer.author.length > 0) {
        UIView *subContainer = [UIView new];
        [_currentContainer addSubview:subContainer];
        
        UILabel *contentLabel = [UILabel new];
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
        contentLabel.numberOfLines = 0;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_currentContainer addSubview:contentLabel];
        contentLabel.text = [NSString stringWithFormat:@"%@:\n%@", refer.author, [refer.content deleteHTMLTag]];
        
        UIView *leftLine = [UIView new];
        leftLine.backgroundColor = [UIColor colorWithHex:0xd7d6da];
        [_currentContainer addSubview:leftLine];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor colorWithHex:0xd7d6da];
        [_currentContainer addSubview:bottomLine];
        
        for (UIView *view in _currentContainer.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
        NSDictionary *views = NSDictionaryOfVariableBindings(subContainer, contentLabel, leftLine, bottomLine);
        if (refer.refer.author.length > 0) {
            subContainer.hidden = NO;
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLine]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
            
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subContainer]-6-[contentLabel]-5-[bottomLine(1)]|"
                                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                                      metrics:nil
                                                                                        views:views]];
            
            
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftLine(1)]-8-[subContainer]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
            
            
        } else {
            subContainer.hidden = YES;
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLine]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
            
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[contentLabel]-5-[bottomLine(1)]|"
                                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                                      metrics:nil
                                                                                        views:views]];
            
            
            [_currentContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftLine(1)]-8-[contentLabel]|"
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:views]];
        }
        _currentContainer = subContainer;
        refer = refer.refer;
        
    }
    
}

@end
