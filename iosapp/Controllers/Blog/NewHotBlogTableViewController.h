//
//  NewHotBlogTableViewController.h
//  iosapp
//
//  Created by Holden on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCObjsViewController.h"

typedef NS_ENUM(NSUInteger, NewBlogsType)
{
    NewBlogsTypeOtherBlogs,
    NewBlogsTypeUserBlogs,
};

@interface NewHotBlogTableViewController : OSCObjsViewController

- (void)dawnAndNightMode;

- (instancetype)initWithUserID:(NSInteger)userID;

@end
