//
//  TitleInfoTableViewCell.h
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBlogDetail.h"

@interface TitleInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *recommendTagIv;
@property (weak, nonatomic) IBOutlet UIImageView *propertyTagIv;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@property (nonatomic, strong) OSCBlogDetail *blogDetail;

@end
