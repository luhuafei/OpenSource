//
//  NewHotBlogTableViewController.m
//  iosapp
//
//  Created by Holden on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewHotBlogTableViewController.h"
#import "NewHotBlogTableViewCell.h"
#import "OSCBlog.h"
#import "Config.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "DetailsViewController.h"
#import "OSCNewHotBlog.h"
#import <MBProgressHUD.h>
#import <MJExtension.h>
#import "NewsBlogDetailTableViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>

static NSString *reuseIdentifier = @"NewHotBlogTableViewCell";

@interface NewHotBlogTableViewController ()<networkingJsonDataDelegate>

@property (nonatomic, strong) NSMutableArray *newestBlogObjects;
@property (nonatomic, strong) NSMutableArray *hottestBlogObjects;
@property (nonatomic, strong) NSDictionary *newblogParaDic;
@property (nonatomic, strong) NSMutableArray *blogObjects;
@property (nonatomic, assign) NewBlogsType blogType;

@end

@implementation NewHotBlogTableViewController

- (instancetype)initWithUserID:(NSInteger)userID
{
    self = [super init];
    if (self) {
        __weak NewHotBlogTableViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@blog?userId=%ld",OSCAPI_V2_PREFIX, (long)userID];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
        self.blogType = NewBlogsTypeUserBlogs;
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        __weak NewHotBlogTableViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return [NSString stringWithFormat:@"%@blog",OSCAPI_V2_PREFIX];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);
        };
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
        self.blogType = NewBlogsTypeOtherBlogs;
    }
    return self;
}

- (void)dawnAndNightMode
{
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _newestBlogObjects = [NSMutableArray new];
    _hottestBlogObjects = [NSMutableArray new];
    _blogObjects = [NSMutableArray new];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NewHotBlogTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.separatorColor = [UIColor separatorColor];
    
    _newblogParaDic = @{@"catalog":@1};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        [self getHotBlogIsRefresh:isRefresh];
        [self getNewBlogIsRefresh:isRefresh];
        [self getBlogsObjectIsRefresh:isRefresh];
    }else {
        [self getNewBlogIsRefresh:isRefresh];
        [self getBlogsObjectIsRefresh:isRefresh];
    }
}

#pragma mark - 获取具体用户博客
- (void)getBlogsObjectIsRefresh:(BOOL)isRefresh
{
    [self.manager GET:self.generateUrl()
           parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject[@"code"]integerValue] == 1) {
                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:[responseObject[@"result"] objectForKey:@"items"]];
                      if (isRefresh) {
                          [_blogObjects removeAllObjects];
                      }
                      [_blogObjects addObjectsFromArray:blogModels];
                  }
                  [self.tableView reloadData];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
              }
     ];
}

#pragma mark - 获取最热博客
-(void)getHotBlogIsRefresh:(BOOL)isRefresh {
//    NSLog(@"hotPara:%@",@{@"catalog":@1});
    
    [self.manager GET:self.generateUrl()
           parameters:@{@"catalog":@2}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                  NSLog(@"hotres:%ld",[[responseObject[@"result"] objectForKey:@"items"] count]);
                  if ([responseObject[@"code"]integerValue] == 1) {
                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:[responseObject[@"result"] objectForKey:@"items"]];
                      if (isRefresh) {
                          [_hottestBlogObjects removeAllObjects];
                      }
                      [_hottestBlogObjects addObjectsFromArray:blogModels];
                  }
                  [self.tableView reloadData];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  
              }
     ];
}
#pragma mark - 获取最新博客
- (void)getNewBlogIsRefresh:(BOOL)isRefresh
{
    if (isRefresh) {
        _newblogParaDic = @{@"catalog":@1};
    }
//    NSLog(@"newPara:%@",_newblogParaDic);
    
    [self.manager GET:self.generateUrl()
           parameters:_newblogParaDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                  NSLog(@"newres:%ld",[[responseObject[@"result"] objectForKey:@"items"] count]);
                  if ([[responseObject objectForKey:@"code"]integerValue] == 1) {
                      NSDictionary* resultDic = responseObject[@"result"];
                      NSArray* blogModels = [OSCNewHotBlog mj_objectArrayWithKeyValuesArray:resultDic[@"items"]];
                      if (isRefresh) {
                          [_newestBlogObjects removeAllObjects];
                      }
                      [_newestBlogObjects addObjectsFromArray:blogModels];
                      self.lastCell.status = blogModels.count<20?LastCellStatusFinished:LastCellStatusMore;
                      _newblogParaDic = @{@"catalog":@1,
                                          @"pageToken":resultDic[@"nextPageToken"]?:@""};
                  }
                  
                  if (self.tableView.mj_header.isRefreshing) {
                      [self.tableView.mj_header endRefreshing];
                  }
                  
                  [self.tableView reloadData];
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.detailsLabelText = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
                  
                  [HUD hide:YES afterDelay:1];
                  
                  self.lastCell.status = LastCellStatusError;
                  if (self.tableView.mj_header.isRefreshing) {
                      [self.tableView.mj_header endRefreshing];
                  }
                  [self.tableView reloadData];
              }
     ];
}

#pragma mark -- DIY_headerView
- (UIView*)setUpHeaderViewWithSectionTitle:(NSString*)title iconUrl:(NSURL*)iconUrl {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor newCellColor];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    lineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:lineView];
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_blogType == NewBlogsTypeUserBlogs) {
        return 1;
    } else if (_blogType == NewBlogsTypeOtherBlogs) {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array;
    if (_blogType == NewBlogsTypeUserBlogs) {
        array = self.blogObjects;
        
    } else if (_blogType == NewBlogsTypeOtherBlogs) {
        array = section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
    }
//    NSMutableArray *array = section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
    
    return array.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_blogType == NewBlogsTypeUserBlogs) {
        return nil;
    } else if (_blogType == NewBlogsTypeOtherBlogs) {
        NSString *seriesTitle = section==0?@"最热":@"最新";
        NSURL *seriesUrl = section==0?nil:nil;
        return [self setUpHeaderViewWithSectionTitle:seriesTitle iconUrl:seriesUrl];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_blogType == NewBlogsTypeUserBlogs) {
        return 0.001;
    } else if (_blogType == NewBlogsTypeOtherBlogs) {
        return 32;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewHotBlogTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.titleLabel.textColor = [UIColor newTitleColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    
    NSMutableArray *array;
    if (_blogType == NewBlogsTypeUserBlogs) {
        array = self.blogObjects;
        
    } else if (_blogType == NewBlogsTypeOtherBlogs) {
        array = indexPath.section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
    }
//    NSMutableArray *array = indexPath.section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
    
    if (array.count > 0) {
        OSCNewHotBlog *blog = array[indexPath.row];
        
        cell.blog = blog;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:reuseIdentifier configuration:^(NewHotBlogTableViewCell *cell) {
        NSMutableArray *array;
        if (_blogType == NewBlogsTypeUserBlogs) {
            array = self.blogObjects;
            
        } else if (_blogType == NewBlogsTypeOtherBlogs) {
            array = indexPath.section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
        }
        OSCNewHotBlog *blog = array[indexPath.row];
        
        cell.blog = blog;
    }];
    
    return 87;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSMutableArray *array = indexPath.section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
    
    NSMutableArray *array;
    OSCNewHotBlog *blog;
    if (_blogType == NewBlogsTypeUserBlogs) {
        array = self.blogObjects;
        
    } else if (_blogType == NewBlogsTypeOtherBlogs) {
        array = indexPath.section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
    }
    
    if (array.count > 0) {
        blog = array[indexPath.row];
    }
    
    NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithBlogId:blog.id isBlogDetail:YES];
    newsBlogDetailVc.hidesBottomBarWhenPushed = YES;
//    newsBlogDetailVc.blogId = blog.id;
    [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
    

//旧博客详情页面
//    NSMutableArray *array = indexPath.section == 0 ? self.hottestBlogObjects : self.newestBlogObjects;
//    OSCNewHotBlog *blog;
//    
//    if (array.count > 0) {
//        blog = array[indexPath.row];
//    }
//    
//    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithNewHotBlog:blog];
//    [self.navigationController pushViewController:detailsViewController animated:YES];
}

@end
