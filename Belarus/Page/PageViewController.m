//
//  PageViewController.m
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "PageViewController.h"
#import "PageControllerDefaultDataSource.h"
#import <Masonry/View+MASAdditions.h>
#import "PRTaskProtocol.h"
#import "MetricaLogger.h"
#import "NewsModel.h"
#import "CommentsViewController.h"
#import "MetricaLogger.h"

static NSInteger kNoInternetErrorCode = -1009;

@interface PageViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UILabel *nothingFoundLabel;
@property (nonatomic, strong) UIView *errorView;

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic, strong) id <PageControllerDataSource> dataSource;
@property (nonatomic, strong) id <PRTaskProtocol> itemsRequestTask;

@end

@implementation PageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self setup];

    [self showItemsFromDataSource:self.dataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *commentsCount = self.newsModel.commentsCount;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"👻 %@", commentsCount] style:UIBarButtonItemStylePlain target:self action:@selector(showComments:)];
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Article", nil);

    self.dataSource = PageControllerDefaultDataSource.new;

    self.webView = UIWebView.new;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    UIView *contentContainer = UIView.new;
    contentContainer.clipsToBounds = YES;
    contentContainer.backgroundColor = [UIColor whiteColor];

    self.contentContainer = contentContainer;
    [self.view addSubview:contentContainer];
    contentContainer.backgroundColor = [UIColor whiteColor];
    [contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.contentContainer addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentContainer);//.offset(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        make.leading.trailing.bottom.equalTo(self.contentContainer);
    }];
    self.webView.layer.opacity = 0.0;

    self.coverView = UIImageView.new;
    self.coverView.image = [UIImage imageNamed:@"belarus-launch"];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    [contentContainer addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentContainer).offset(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        make.leading.trailing.bottom.equalTo(self.contentContainer);
    }];

    UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinnerView = spinnerView;
    [contentContainer addSubview:spinnerView];
    [spinnerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentContainer);
    }];

    UILabel *nothingFoundLabel = UILabel.new;
    nothingFoundLabel.text = NSLocalizedString(@"Unfortunately, nothing was found. Please try again later.", nil);
    self.nothingFoundLabel = nothingFoundLabel;
    nothingFoundLabel.numberOfLines = 0;
    [contentContainer addSubview:nothingFoundLabel];
    [nothingFoundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(contentContainer);
        make.leading.greaterThanOrEqualTo(contentContainer).offset(5);
        make.trailing.lessThanOrEqualTo(contentContainer).offset(-5);
    }];
    nothingFoundLabel.layer.opacity = 0.0;
}

# pragma mark - presentation

- (void)showComments:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@{ self.newsModel.sourceUrl.absoluteString : self.newsModel.title }, @"Show Comments Action", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];
    
//    [self performSegueWithIdentifier:@"goToComments" sender:self.newsModel];
    // else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://belarus-today.com/%@#disqus_thread", self.newsModel.newsId]]];
}

- (void)showItemsFromDataSource:(id <PageControllerDataSource>)dataSource
{
    self.dataSource = dataSource;
    self.itemsRequestTask = [self.dataSource getPageInfoWithModel:self.newsModel];
    [self showWait:YES];

    [UIView animateWithDuration:0.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.nothingFoundLabel.layer.opacity = 0.0;
    } completion:nil];

    __weak typeof(self) weakSelf = self;
    [self.itemsRequestTask onComplete:^(NewsModel *model, id error) {
        [weakSelf showWait:NO];
        if (error == nil) {
            [weakSelf presentItems:model];
        } else {
            [weakSelf showErrorOccurred:error];
        }

        weakSelf.itemsRequestTask = nil;
    }];
}

- (void)presentItems:(NewsModel *)model
{
    if (model.markup.length > 0) {
        [self.webView loadHTMLString:model.markup baseURL:nil];
    } else {
        [UIView animateWithDuration:0.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.nothingFoundLabel.layer.opacity = 1.0;
            self.coverView.layer.opacity = 1.0;
        } completion:nil];
    }
}

# pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToComments"]) {
        CommentsViewController *vc = [segue destinationViewController];
        vc.newsModel = sender;
    }
}

# pragma mark - web view

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showWait:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIView animateWithDuration:0.48 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        webView.layer.opacity = 1.0;
        self.coverView.layer.opacity = 0.0;
        [self showWait:NO];
    } completion:^(BOOL finished) {
    }];
}

# pragma mark - helper methods

- (BOOL)isPresented
{
    return YES;
}

- (void)showWait:(BOOL)show
{
    if (show) {
        [self.spinnerView startAnimating];
    } else {
        [self.spinnerView stopAnimating];
    }
}

- (void)tryAgainToStartup
{
    UIView *errorView = [self.contentContainer viewWithTag:1000];
    if (errorView != nil) {
        [errorView removeFromSuperview];
    }

    [self showItemsFromDataSource:self.dataSource];
}

- (void)showErrorOccurred:(NSError *)error
{
    NSString *errorText;
    if (error.code == kNoInternetErrorCode) {
        errorText = NSLocalizedString(@"Something wrong with Internet. Please try again later.", nil);
    } else {
        errorText = NSLocalizedString(@"Oops!.. Some error occurred. Please try again later.", nil);
    }

    [self.errorView removeFromSuperview];
    UIView *errorView = [self createErrorPopupWithText:errorText];
    self.errorView = errorView;
    errorView.tag = 1000;

    UIGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tryAgainToStartup)];
    [errorView addGestureRecognizer:gr];

    [self.contentContainer addSubview:errorView];
    [errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentContainer);
    }];

    errorView.layer.opacity = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        errorView.layer.opacity = 1.0;
    } completion:nil];
}

- (UIView *)createErrorPopupWithText:(NSString *)text
{
    UIView *errorPopup = [UIView new];
    errorPopup.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    UILabel *message = [UILabel new];
    message.text = text;
    message.numberOfLines = 0;
    message.textAlignment = NSTextAlignmentCenter;
    message.textColor = [UIColor whiteColor];

    [errorPopup addSubview:message];
    [message mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(errorPopup);
        make.leading.greaterThanOrEqualTo(errorPopup).offset(5);
        make.trailing.lessThanOrEqualTo(errorPopup).offset(-5);
    }];

    return errorPopup;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSString *)identifier
{
    return @"PageViewController";
}

@end
