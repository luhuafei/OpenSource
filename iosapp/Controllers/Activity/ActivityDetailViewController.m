//
//  ActivityDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "ActivityHeadCell.h"
#import "ActivityDetailCell.h"
#import "PresentMembersViewController.h"
#import "ActivitySignUpViewController.h"

#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <UITableView+FDTemplateLayoutCell.h>

#import "OSCActivity.h"
#import "OSCPostDetails.h"

static NSString * const activityHeadDetailReuseIdentifier = @"ActivityHeadCell";
static NSString * const activityDetailReuseIdentifier = @"ActivityDetailCell";
@interface ActivityDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic, strong) NSArray *cellTypes;

@property (nonatomic, strong) OSCPostDetails *postDetails;
@property (nonatomic, strong) OSCActivity *activity;
@property (nonatomic, assign) int64_t     activityID;
@property (nonatomic, copy)   NSString *HTML;
@property (nonatomic, assign) BOOL      isLoadingFinished;
@property (nonatomic, assign) CGFloat   webViewHeight;

@property (nonatomic, assign) BOOL isFav;

@end

@implementation ActivityDetailViewController

- (instancetype)initWithActivityID:(int64_t)activityID
{
    self = [super init];
    if (self) {
//        _activityID = activityID;
        _activityID = 2180196;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityHeadCell" bundle:nil] forCellReuseIdentifier:activityHeadDetailReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityDetailCell" bundle:nil] forCellReuseIdentifier:activityDetailReuseIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_share_black_pressed"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(shareForActivity:)];
    
    [self fetchForActivityDetailDate];
    _cellTypes = @[@"timeType", @"addressType", @"descType"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchForActivityDetailDate
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    NSString *str= [NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, _activityID];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%lld", OSCAPI_PREFIX, OSCAPI_POST_DETAIL, _activityID]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
             ONOXMLElement *postXML = [responseObject.rootElement firstChildWithTag:@"post"];
             _postDetails = [[OSCPostDetails alloc] initWithXML:postXML];
             _activity = [[OSCActivity alloc] initWithXML:[postXML firstChildWithTag:@"event"]];
             
             _HTML = [Utils HTMLWithData:@{
                                           @"content": _postDetails.body,
                                           @"night": @([Config getMode]),
                                           }
                           usingTemplate:@"activity"];
             
             [self setFavButtonAction:_postDetails.isFavorite];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [MBProgressHUD new];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，加载失败";
             
             [HUD hide:YES afterDelay:1];
         }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ActivityHeadCell *cell = [_tableView dequeueReusableCellWithIdentifier:activityHeadDetailReuseIdentifier forIndexPath:indexPath];
        
        [cell setContentForHeadCell:_postDetails activity:_activity];
        
        return cell;
    } else if (indexPath.row > 0){
        ActivityDetailCell *cell = [_tableView dequeueReusableCellWithIdentifier:activityDetailReuseIdentifier forIndexPath:indexPath];
        cell.cellType = _cellTypes[indexPath.row-1];
        
        if (indexPath.row == 3) {
            cell.ActivityWebView.delegate = self;
            [cell.ActivityWebView loadHTMLString:_HTML baseURL:[NSBundle mainBundle].resourceURL];
        } else {
            
            cell.eventDetail = _activity;
        }
        
        return cell;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 204;
    }else if (indexPath.row == 3) {
        return _isLoadingFinished? _webViewHeight + 30 : 400;
    } else {
        return [tableView fd_heightForCellWithIdentifier:activityDetailReuseIdentifier configuration:^(ActivityDetailCell *cell) {
            cell.eventDetail = _activity;
        }];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_HTML == nil) {return;}
    if (_isLoadingFinished) {
        webView.hidden = NO;
        return;
    }
    
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    _isLoadingFinished = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
//    [self.bottomBarVC.navigationController handleURL:request.URL];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

#pragma mark - right BarButton
- (void)shareForActivity:(UIBarButtonItem *)barButton
{
    //share
    NSLog(@"share");
}

#pragma mark - button clicked

- (IBAction)clickedButton:(UIButton *)sender {
    if (sender.tag == 1) {
        //收藏
        [self postFav];
    } else if (sender.tag == 2){
        //报名
        NSLog(@"add");
        [self enrollActivity];
    }
}

- (void)setFavButtonAction:(BOOL)isStarted
{
    if (isStarted) {
        self.isFav = YES;
        [_favButton setTitle:@"已收藏" forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    } else {
        self.isFav = NO;
        [_favButton setTitle:@"收藏" forState:UIControlStateNormal];
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

#pragma mark - fav
- (void)postFav
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = self.isFav? OSCAPI_FAVORITE_DELETE: OSCAPI_FAVORITE_ADD;
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, API]
       parameters:@{
                    @"uid":   @([Config getOwnID]),
                    @"objid": @(self.activityID),
                    @"type":  @(2)
                    }
          success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
              ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
              int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
              NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
              
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              
              if (errorCode == 1) {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = self.isFav? @"删除收藏成功": @"添加收藏成功";
                  self.isFav = !self.isFav;
              } else {
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
              }
              [self setFavButtonAction:self.isFav];
              [HUD hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
          }];
}

#pragma mark - 报名

- (void)enrollActivity
{
    if (_postDetails.category == 4) {
        [[UIApplication sharedApplication] openURL:_postDetails.signUpUrl];
    } else {
        if (_postDetails.applyStatus == 2) {
            PresentMembersViewController *presentMembersViewController = [[PresentMembersViewController alloc] initWithEventID:_postDetails.postID];
            [self.navigationController pushViewController:presentMembersViewController animated:YES];
        } else {
            ActivitySignUpViewController *signUpViewController = [ActivitySignUpViewController new];
            signUpViewController.eventId = _postDetails.postID;
            signUpViewController.remarkTipStr = _activity.remarkTip;
            signUpViewController.remarkCitys = _activity.remarkCitys;
            [self.navigationController pushViewController:signUpViewController animated:YES];
        }
    }
}

@end
