//
//  ActivityHeadCell.h
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCPostDetails.h"
#import "OSCActivity.h"

@interface ActivityHeadCell : UITableViewCell

- (void)setContentForHeadCell:(OSCPostDetails *)detailPost activity:(OSCActivity *)activity;

@end
