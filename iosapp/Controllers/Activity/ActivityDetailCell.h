//
//  ActivityDetailCell.h
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCPostDetails.h"
#import "OSCActivity.h"

@interface ActivityDetailCell : UITableViewCell

@property (nonatomic, copy) NSString *cellType;/* cell类型 */

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIWebView *ActivityWebView;

@property (nonatomic,strong) OSCActivity *eventDetail;

@end
