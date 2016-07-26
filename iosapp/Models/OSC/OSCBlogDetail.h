//
//  OSCBlogDetail.h
//  iosapp
//
//  Created by Graphic-one on 16/5/26.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSCBlogDetailRecommend , OSCBlogDetailComment, OSCBlogCommentRefer;

@interface OSCBlogDetail : NSObject

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *body;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy) NSString *category;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *href;

@property (nonatomic, copy) NSString *authorPortrait;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, assign) BOOL recommend;

@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL original;

@property (nonatomic, assign) NSInteger authorRelation;

@property (nonatomic, assign) NSInteger viewCount;

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic,strong) NSArray<OSCBlogDetailRecommend* >* abouts;

@property (nonatomic,strong) NSArray<OSCBlogDetailComment* >* comments;

@property (nonatomic, assign) BOOL favorite;

@property (nonatomic, copy) NSString *abstract;//摘要

@end



@interface OSCBlogDetailRecommend : NSObject

@property (nonatomic, assign) NSInteger commentCount;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) NSInteger viewCount;

@end



@interface OSCBlogDetailComment : NSObject

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) NSInteger appClient;

@property (nonatomic, assign) NSInteger id;

@property (nonatomic, assign) NSInteger authorId;

@property (nonatomic, copy) NSString *pubDate;

@property (nonatomic, copy) NSString *authorPortrait;

@property (nonatomic, strong) OSCBlogCommentRefer *refer;

@end


@interface OSCBlogCommentRefer : NSObject

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *pubDate;
@property (nonatomic, strong) OSCBlogCommentRefer *refer;

//@property (nonatomic, copy) NSMutableString *trimmedContent;
//@property (nonatomic, strong) NSMutableArray *hrefs;

@end


//@interface HrefMark :NSObject
//
//@property (nonatomic, strong) NSURL *href;
//@property (nonatomic, assign) NSRange range;
//
//@end