//
//  OSCActivities.h
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSUInteger, ActivityStatus){
    ActivityStatusEnd = 1,// 活动已经结束
    ActivityStatusHaveInHand,//活动进行中
    ActivityStatusClose//活动报名已经截止
};

typedef NS_ENUM (NSUInteger, ActivityType){
    ActivityTypeOSChinaMeeting = 1,//源创会
    ActivityTypeTechnical,//技术交流
    ActivityTypeOther,// 其他
    ActivityTypeBelow//站外活动(当为站外活动的时候，href为站外活动报名地址)
};

@interface OSCActivities : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* body;

@property (nonatomic,strong) NSString* img;

@property (nonatomic,strong) NSString* startDate;

@property (nonatomic,strong) NSString* endDate;

@property (nonatomic,strong) NSString* pubDate;

@property (nonatomic,strong) NSString* href;

@property (nonatomic,assign) NSInteger applyCount;

@property (nonatomic,assign) ActivityStatus status;

@property (nonatomic,assign) ActivityType type;

@end
