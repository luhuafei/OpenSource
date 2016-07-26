//
//  QuesListViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/25.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesListViewController.h"
#import "QuesAnsCell.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCQuestion.h"
#import "DetailsViewController.h"

#import <MJExtension.h>
#import <MBProgressHUD.h>
static NSString * const reuseIdentifier = @"QuesAnsCell";
@interface QuesListViewController () <UITableViewDelegate, UITableViewDataSource, networkingJsonDataDelegate>

@property (nonatomic, copy) NSString *pageToken;
@property (nonatomic) NSInteger catalog;
//@property (nonatomic, copy) NSString *nextPageToken;
//@property (nonatomic, copy) NSString *prevPageToken;

@end

@implementation QuesListViewController

-(instancetype)initWithQuestionType:(NSInteger)catalog {
    self = [super init];
    if (self) {
        _pageToken = @"";
        //        __weak QuesListViewController *weakSelf = self;
        self.generateUrl = ^NSString * () {
            return @"http://192.168.1.15:8000/action/apiv2/question";
        };
        //        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
        //            responseObjectsCount < 20? (weakSelf.lastCell.status = LastCellStatusFinished) :
        //            (weakSelf.lastCell.status = LastCellStatusMore);
        //        };
        //        self.objClass = [OSCQuestion class];
        
        self.netWorkingDelegate = self;
        self.isJsonDataVc = YES;
        
        _catalog = catalog;
        self.paraDic = @{
                         @"catalog"   : @(_catalog),
                         @"pageToken" : _pageToken
                         };
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = @"NewsRefreshInterval";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _questions = [NSMutableArray new];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([QuesAnsCell class]) bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:reuseIdentifier];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - JSON解析数据
//- (void)fetchForQuestions:(id)responseObject
//{
//    NSDictionary *result = [responseObject objectForKey:@"result"];
//    NSArray *items = [result objectForKey:@"items"];
//    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        OSCQuestion *question = [OSCQuestion mj_objectWithKeyValues:obj];
//        
//        [_questions addObject:question];
//    }];
//    
//    _nextPageToken = [result objectForKey:@"nextPageToken"];
//    _prevPageToken = [result objectForKey:@"prevPageToken"];
//}

#pragma mark -- networkingDelegate
-(void)getJsonDataWithParametersDic:(NSDictionary*)paraDic isRefresh:(BOOL)isRefresh{
    
    [self.manager GET:self.generateUrl()
           parameters:_paraDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([[responseObject objectForKey:@"code"]integerValue] == 1) {
                      NSDictionary *resultDic = [responseObject objectForKey:@"result"];
                      NSArray* questions = [OSCQuestion mj_objectArrayWithKeyValuesArray:[resultDic objectForKey:@"items"]];
                      if (isRefresh) {
                          [_questions removeAllObjects];
                      }
                      [_questions addObjectsFromArray:questions];
                      
                      _pageToken = [resultDic objectForKey:@"nextPageToken"];
                      self.lastCell.status = questions.count < 20 ? LastCellStatusFinished : LastCellStatusMore;
                  }else {
                      self.lastCell.status = LastCellStatusError;
                  }
                  _paraDic = @{
                               @"catalog"   : @(_catalog),
                               @"pageToken" : _pageToken
                               };
                  
                  
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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_questions.count > 0) {
        return _questions.count;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 2;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (_questions.count > 0) {
        OSCQuestion *question = _questions[indexPath.row];
        
        label.font = [UIFont systemFontOfSize:15];
        label.text = question.title;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 85, MAXFLOAT)].height;
        
        label.font = [UIFont systemFontOfSize:14];
        label.text = question.body;
        height += [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 85, MAXFLOAT)].height;
        
        return height + 64;
    }
    return 101;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QuesAnsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.titleLabel.textColor = [UIColor newTitleColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    if (_questions.count > 0) {
        OSCQuestion *question = _questions[indexPath.row];
        [cell setcontentForQuestionsAns:question];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCQuestion *question = _questions[indexPath.row];
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithQuestion:question];
    [self.navigationController pushViewController:detailsViewController animated:YES];
}

@end
