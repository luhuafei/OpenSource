//
//  NewsBlogDetailTableViewController.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewsBlogDetailTableViewController.h"
#import "FollowAuthorTableViewCell.h"
#import "TitleInfoTableViewCell.h"
#import "webAndAbsTableViewCell.h"
#import "RecommandBlogTableViewCell.h"
#import "ContentWebViewCell.h"
#import "NewCommentCell.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCBlogDetail.h"
#import "Utils.h"
#import "Config.h"
#import "OSCBlog.h"
#import "OSCNewHotBlogDetails.h"
#import "CommentsBottomBarViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"


#import <MJExtension.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <TOWebViewController.h>
#import "UMSocial.h"

static NSString *followAuthorReuseIdentifier = @"FollowAuthorTableViewCell";
static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
static NSString *abstractReuseIdentifier = @"abstractTableViewCell";
static NSString *contentWebReuseIdentifier = @"contentWebTableViewCell";
static NSString *newCommentReuseIdentifier = @"NewCommentCell";

@interface NewsBlogDetailTableViewController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) OSCBlogDetail *blogDetails;
@property (nonatomic, strong) NSMutableArray *blogDetailComments;
@property (nonatomic, strong) NSMutableArray *blogDetailRecommends;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *hud;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic,strong) OSCNewHotBlogDetails *detail;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@end




@implementation NewsBlogDetailTableViewController

-(instancetype) initWithBlogId:(NSInteger)blogId
                  isBlogDetail:(BOOL)isBlogDetail {
    if(self) {
        self.blogId = blogId;
        self.isBlogDetail = isBlogDetail;
        
        _blogDetailRecommends = [NSMutableArray new];
        _blogDetailComments = [NSMutableArray new];
    }
    return self;
}
- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    _hud = [[MBProgressHUD alloc] initWithWindow:window];
    _hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    [window addSubview:_hud];
    [self.view addSubview:coverView];
    [_hud show:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}
- (void)hideHubView {
    [_hud hide:YES];
    [[self.view viewWithTag:10] removeFromSuperview];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"博文";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextField.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FollowAuthorTableViewCell" bundle:nil] forCellReuseIdentifier:followAuthorReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"webAndAbsTableViewCell" bundle:nil] forCellReuseIdentifier:abstractReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentWebViewCell" bundle:nil] forCellReuseIdentifier:contentWebReuseIdentifier];
    [self.tableView registerClass:[NewCommentCell class] forCellReuseIdentifier:newCommentReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    // 添加等待动画
    [self showHubView];
    
    [self getBlogData];
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarButtonClicked)];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideHubView];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonClicked
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"举报"
                                                        message:[NSString stringWithFormat:@"链接地址：%@", _blogDetails.href]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].placeholder = @"举报原因";
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode)
    {
        [alertView textFieldAtIndex:0].keyboardAppearance = UIKeyboardAppearanceDark;
    }
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:@"http://www.oschina.net/action/communityManage/report"
           parameters:@{
                        @"memo":        [alertView textFieldAtIndex:0].text.length == 0? @"其他原因": [alertView textFieldAtIndex:0].text,
                        @"obj_id":      @(_blogDetails.id),
                        @"obj_type":    @"2",
                        @"reason":      @"4",
                        @"url":         _blogDetails.href
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  HUD.labelText = @"举报成功";
                  
                  [HUD hide:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = @"网络异常，操作失败";
                  
                  [HUD hide:YES afterDelay:1];
              }];
    }
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextField resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark - 获取数据

-(void)getBlogData{
    //@"http://192.168.1.15:8000/action/apiv2/blog?id=179590"
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@blog?id=%lld", OSCAPI_V2_PREFIX, self.blogId];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:blogDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _blogDetails = [OSCBlogDetail mj_objectWithKeyValues:responseObject[@"result"]];
                _blogDetailRecommends = [OSCBlogDetailRecommend mj_objectArrayWithKeyValuesArray:_blogDetails.abouts];
                _blogDetailComments = [OSCBlogDetailComment mj_objectArrayWithKeyValuesArray:_blogDetails.comments];
                
                NSDictionary *data = @{@"content":  _blogDetails.body};
                _blogDetails.body = [Utils HTMLWithData:data
                                          usingTemplate:@"blog"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self favButtonImage];
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    
//    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
//    topLineView.backgroundColor = [UIColor separatorColor];
//    [headerView addSubview:topLineView];
//    
//    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
//    bottomLineView.backgroundColor = [UIColor separatorColor];
//    [headerView addSubview:bottomLineView];
    
    return headerView;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionNumber = 1;
    if (_blogDetailComments.count > 0) {
        sectionNumber += 1;
    }
    if (_blogDetailRecommends.count > 0) {
        sectionNumber += 1;
    }
    
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return _blogDetails.abstract.length?4:3;
            break;
        }
        case 1://相关文章
        {
            return _blogDetailRecommends.count;
            break;
        }
        case 2://讨论
        {
            return _blogDetailComments.count+1;
            break;
        }
        default:
            break;
    }
    return 0;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return [self headerViewWithSectionTitle:@"相关文章"];
    }else if (section == 2) {
        if (_blogDetailComments.count > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"评论(%lu)", (unsigned long)_blogDetailComments.count]];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    return [tableView fd_heightForCellWithIdentifier:followAuthorReuseIdentifier configuration:^(FollowAuthorTableViewCell *cell) {
                        cell.blogDetail = _blogDetails;
                    }];
                    break;
                case 1:
                    return [tableView fd_heightForCellWithIdentifier:titleInfoReuseIdentifier configuration:^(TitleInfoTableViewCell *cell) {
                        cell.blogDetail = _blogDetails;
                        
                    }];
                    break;
                case 2:
                {
                    if (_blogDetails.abstract.length > 0) {
                        return [tableView fd_heightForCellWithIdentifier:abstractReuseIdentifier configuration:^(webAndAbsTableViewCell *cell) {
                            cell.abstractLabel.text = _blogDetails.abstract;
                        }];
                    } else if (_blogDetails.abstract.length == 0) {
                        return _webViewHeight+30;
                    }
                    break;
                }
                case 3:
                    return _webViewHeight+30;
                    break;
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            if (_blogDetailRecommends.count > 0) {
                return [tableView fd_heightForCellWithIdentifier:recommandBlogReuseIdentifier configuration:^(RecommandBlogTableViewCell *cell) {
                    OSCBlogDetailRecommend *blogRecommend = _blogDetailRecommends[indexPath.row];
                    cell.abouts = blogRecommend;
                }];
            }
            return 54;
            break;
        }
        case 2:
        {
            if (_blogDetailComments.count > 0) {
                if (indexPath.row == _blogDetailComments.count) {
                    return 44;
                } else {
                    UILabel *label = [UILabel new];
                    label.font = [UIFont systemFontOfSize:14];
                    label.numberOfLines = 0;
                    label.lineBreakMode = NSLineBreakByWordWrapping;
                    
                    OSCBlogDetailComment *blogComment = _blogDetailComments[indexPath.row];
                     NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:blogComment.content]];
                    label.attributedText = contentString;
                    
                    CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 32, MAXFLOAT)].height;
                    
                    
                    height += 7;
                    OSCBlogCommentRefer *refer = blogComment.refer;
                    int i = 0;
                    while (refer.author.length > 0) {
                        label.text = [NSString stringWithFormat:@"%@:\n%@", refer.author, refer.content];
                        height += [label sizeThatFits:CGSizeMake( self.tableView.frame.size.width - 60 - (i+1)*8, MAXFLOAT)].height + 12;
                        i++;
                        refer = refer.refer;
                    }
                    
                    return height + 71;
                }
            }
            return 44;
            break;
        }
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerViewHeight = 0.001;
    switch (section) {
        case 0:
            break;
        case 1:
            headerViewHeight = 32;
            break;
        case 2:
            headerViewHeight = 32;
            break;
        default:
            break;
    }
    return headerViewHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row==0) {
                FollowAuthorTableViewCell *followAuthorCell = [tableView dequeueReusableCellWithIdentifier:followAuthorReuseIdentifier forIndexPath:indexPath];
                followAuthorCell.blogDetail = _blogDetails;
                
                followAuthorCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [followAuthorCell.followBtn addTarget:self action:@selector(favSelected) forControlEvents:UIControlEventTouchUpInside];
                
                return followAuthorCell;
            } else if (indexPath.row==1) {
                TitleInfoTableViewCell *titleInfoCell = [tableView dequeueReusableCellWithIdentifier:titleInfoReuseIdentifier forIndexPath:indexPath];
                titleInfoCell.blogDetail = _blogDetails;
                
                titleInfoCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return titleInfoCell;
            } else if (indexPath.row == 2) {
                if (_blogDetails.abstract.length > 0) {
                    webAndAbsTableViewCell *abstractCell = [tableView dequeueReusableCellWithIdentifier:abstractReuseIdentifier forIndexPath:indexPath];
                    abstractCell.abstractLabel.text = _blogDetails.abstract;
                    abstractCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return abstractCell;

                } else {
                    ContentWebViewCell *webViewCell = [tableView dequeueReusableCellWithIdentifier:contentWebReuseIdentifier forIndexPath:indexPath];
                    webViewCell.contentWebView.delegate = self;
                    [webViewCell.contentWebView loadHTMLString:_blogDetails.body baseURL:[NSBundle mainBundle].resourceURL];
                    webViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return webViewCell;
                }
            } else if (indexPath.row == 3) {
                ContentWebViewCell *webViewCell = [tableView dequeueReusableCellWithIdentifier:contentWebReuseIdentifier forIndexPath:indexPath];
                webViewCell.contentWebView.delegate = self;
                [webViewCell.contentWebView loadHTMLString:_blogDetails.body baseURL:[NSBundle mainBundle].resourceURL];
                webViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return webViewCell;
            }
            
        }
            break;
        case 1: {
            RecommandBlogTableViewCell *recommandBlogCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
            
            if (_blogDetailRecommends.count > 0) {
                OSCBlogDetailRecommend *about = _blogDetailRecommends[indexPath.row];
                recommandBlogCell.abouts = about;
            }
            
            recommandBlogCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            
            return recommandBlogCell;
        }
            break;
        case 2: {
            if (_blogDetailComments.count > 0) {
                if (indexPath.row == _blogDetailComments.count) {
                    UITableViewCell *cell = [UITableViewCell new];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.textLabel.text = @"更多评论";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.font = [UIFont systemFontOfSize:14];
                    cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                    
                    return cell;
                } else {
                    NewCommentCell *commentBlogCell = [NewCommentCell new];
                    commentBlogCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    OSCBlogDetailComment *detailComment = _blogDetailComments[indexPath.row];
                    commentBlogCell.comment = detailComment;
                    
                    if (detailComment.refer.author.length > 0) {
                        commentBlogCell.currentContainer.hidden = NO;
                    } else {
                        commentBlogCell.currentContainer.hidden = YES;
                    }
                    
                    
                    commentBlogCell.commentButton.tag = indexPath.row;
                    [commentBlogCell.commentButton addTarget:self action:@selector(selectedToComment:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return commentBlogCell;
                }
                
            } else {
                UITableViewCell *cell = [UITableViewCell new];
                cell.textLabel.text = @"还没有评论";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
            
        }
            break;
        default:
            break;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (_blogDetailRecommends.count > 0) {
            OSCBlogDetailRecommend *detailRecommend = _blogDetailRecommends[indexPath.row];
            
            NewsBlogDetailTableViewController *newsBlogDetailVc = [[NewsBlogDetailTableViewController alloc]initWithBlogId:detailRecommend.id
                                                                                                              isBlogDetail:YES];
            [self.navigationController pushViewController:newsBlogDetailVc animated:YES];
        }
    }
    
    if (indexPath.section == 2) {
        if (_blogDetailComments.count > 0) {
            if (indexPath.row == _blogDetailComments.count) {
                //评论列表
                CommentsBottomBarViewController *commentsBVC = [[CommentsBottomBarViewController alloc] initWithCommentType:5 andObjectID:_blogDetails.id];
                [self.navigationController pushViewController:commentsBVC animated:YES];
            }
        }
    }
}
#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
    
//    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
//
//    [self.navigationController pushViewController:[[TOWebViewController alloc] initWithURL:request.URL]
//                                         animated:YES];
//
//    return NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webViewHeight == webViewHeight) {return;}
    _webViewHeight = webViewHeight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self hideHubView];
    });
}

#pragma mark - fav关注
- (void)favSelected
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_USER_UPDATERELATION]
           parameters:@{
                        @"uid":             @([Config getOwnID]),
                        @"hisuid":          @(_blogDetails.authorId),
                        @"newrelation":     _blogDetails.authorRelation <= 2? @(0) : @(1)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDoment) {
                  ONOXMLElement *result = [responseDoment.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  if (errorCode == 1) {
                      _blogDetails.authorRelation = [[[responseDoment.rootElement firstChildWithTag:@"relation"] numberValue] intValue];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                                withRowAnimation:UITableViewRowAnimationNone];
                      });
                  } else {
                      MBProgressHUD *HUD = [Utils createHUD];
                      HUD.mode = MBProgressHUDModeCustomView;
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.labelText = errorMessage;
                      
                      [HUD hide:YES afterDelay:1];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = @"网络异常，操作失败";
                  
                  [HUD hide:YES afterDelay:1];
              }];
    }
    
}

#pragma mark - 评论
- (void)selectedToComment:(UIButton *)button
{
    OSCBlogDetailComment *comment = _blogDetailComments[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        _commentTextField.placeholder = [NSString stringWithFormat:@"@%@", comment.author];
    } else {
        _commentTextField.placeholder = @"发表评论";
    }
    
    
}

#pragma mark - 发评论
- (void)sendComment:(NSInteger)replyID authorID:(NSInteger)authorID
{
    //
    MBProgressHUD *HUD = [Utils createHUD];
    //    HUD.labelText = @"评论发送中";
    
    
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSDictionary *parameters =  @{
                                      @"blog"     : @(_blogDetails.id),
                                      @"uid"      : @([Config getOwnID]),
                                      @"content"  : _commentTextField.text,
                                      @"reply_id" : @(replyID),
                                      @"objuid"   : @(authorID),
                                      };
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_BLOGCOMMENT_PUB]
           parameters:parameters
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
                  ONOXMLElement *result = [responseDocument.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.labelText = @"评论发表成功";
                      
                      [self.tableView reloadData];
                      _commentTextField.text = @"";
                  } else {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [HUD hide:YES afterDelay:1];
                  
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = @"网络异常，动弹发送失败";
                  
                  [HUD hide:YES afterDelay:1];
              }];
        
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"send mesage");
    
    if (_isReply) {
        OSCBlogDetailComment *comment = _blogDetailComments[_selectIndexPath];
        [self sendComment:comment.id authorID:comment.authorId];
    } else {
        [self sendComment:0 authorID:0];
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
    _bottmTextFiled.constant = _keyboardHeight;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _bottmTextFiled.constant = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - collect 收藏

- (void)favButtonImage
{
    if (_blogDetails.favorite) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    } else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}
- (IBAction)collected:(UIButton *)sender {
    NSLog(@"collect");
    
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *API = _blogDetails.favorite? OSCAPI_FAVORITE_DELETE: OSCAPI_FAVORITE_ADD;
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, API]
           parameters:@{
                        @"uid":   @([Config getOwnID]),
                        @"objid": @(_blogDetails.id),
                        @"type":  @(3)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *result = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
                  
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.labelText = _blogDetails.favorite? @"删除收藏成功": @"添加收藏成功";
                      
                      _blogDetails.favorite = !_blogDetails.favorite;
                  } else {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                      HUD.labelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                  }
                  
                  [self favButtonImage];
                  [HUD hide:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = @"网络异常，操作失败";
                  
                  [HUD hide:YES afterDelay:1];
              }];
    }
}


#pragma mark - share
- (IBAction)share:(UIButton *)sender {
    NSLog(@"share");
    
    [_commentTextField resignFirstResponder];
    
    NSString *trimmedHTML = [_blogDetails.body deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 60 ? trimmedHTML.length : 60;
    NSString *digest = [trimmedHTML substringToIndex:length];
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _blogDetails.href;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _blogDetails.href;
    [UMSocialData defaultData].extConfig.title = _blogDetails.title;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = _blogDetails.title;
    //[UMSocialData defaultData].extConfig.qqData.shareText = weakSelf.objectTitle;
    [UMSocialData defaultData].extConfig.qqData.url = _blogDetails.href;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:_blogDetails.href];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"54c9a412fd98c5779c000752"
                                      shareText:[NSString stringWithFormat:@"%@...分享来自 %@", digest, _blogDetails.href]
                                     shareImage:[UIImage imageNamed:@"logo"]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}

- (NSString *)mURL
{
    if (_mURL) {
        return _mURL;
    } else {
        NSMutableString *strUrl = [NSMutableString stringWithFormat:@"%@", _blogDetails.href];
        //        if (_commentType == CommentTypeBlog) {
        strUrl = [NSMutableString stringWithFormat:@"http://m.oschina.net/blog/%ld", (long)_blogDetails.id];
        //        } else {
        //            [strUrl replaceCharactersInRange:NSMakeRange(7, 3) withString:@"m"];
        //        }
        _mURL = [strUrl copy];
        return _mURL;
    }
}

@end
