//
//  CommentsViewController.m
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentsControllerDefaultDataSource.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import <Masonry/View+MASAdditions.h>
#import "CommentCell.h"
#import "CommentModel.h"
#import "PRTaskProtocol.h"
#import "MetricaLogger.h"
#import "NewsModel.h"
#import "MetricaLogger.h"

#define INDEX(indexPath) ((NSUInteger)indexPath.row)

static NSString *kCommentCellIdentifier = @"CommentCellIdentifier";
static NSInteger kNoInternetErrorCode = -1009;

@interface CommentsViewController () <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nothingFoundLabel;
@property (nonatomic, strong) UIView *errorView;

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic, strong) id <CommentsControllerDataSource> dataSource;
@property (nonatomic, strong) NSArray *presentedItems;
@property (nonatomic, strong) id <PRTaskProtocol> itemsRequestTask;

@end

@implementation CommentsViewController

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addComment:)];
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Comments", nil);

    self.dataSource = CommentsControllerDefaultDataSource.new;

    UIView *contentContainer = UIView.new;
    contentContainer.clipsToBounds = NO;
    contentContainer.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];

    self.contentContainer = contentContainer;
    [self.view addSubview:contentContainer];
    contentContainer.backgroundColor = [UIColor whiteColor];
    [contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.columnCount = 1;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:CommentCell.class forCellWithReuseIdentifier:kCommentCellIdentifier];
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    collectionView.clipsToBounds = NO;
    [contentContainer addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentContainer);//.offset(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);;
        make.leading.trailing.bottom.equalTo(contentContainer);
    }];

    self.coverView = UIImageView.new;
    self.coverView.image = [UIImage imageNamed:@"belarus-launch"];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    [contentContainer addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentContainer).offset(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        make.leading.trailing.bottom.equalTo(contentContainer);
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

- (void)clearPresentedItems
{
    self.presentedItems = @[];
}

- (void)addComment:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@{ self.newsModel.sourceUrl.absoluteString : self.newsModel.title }, @"Add Comment Action", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://belarus-today.com/%@#disqus_thread", self.newsModel.newsId]]];
}

- (void)showItemsFromDataSource:(id <CommentsControllerDataSource>)dataSource
{
    [self clearPresentedItems];

    self.dataSource = dataSource;
    self.itemsRequestTask = [self.dataSource getCommentsInfoFromUrl:self.newsModel.sourceUrl];
    [self showWait:YES];

    [UIView animateWithDuration:1.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.collectionView.layer.opacity = 0.0;
        self.nothingFoundLabel.layer.opacity = 0.0;
        self.coverView.layer.opacity = 1.0;
    } completion:nil];

    __weak typeof(self) weakSelf = self;
    [self.itemsRequestTask onComplete:^(NSArray *items, id error) {
        [weakSelf showWait:NO];
        if (error == nil) {
            [weakSelf presentItems:items];
        } else {
            [weakSelf showErrorOccurred:error];
        }

        weakSelf.itemsRequestTask = nil;
    }];
}

- (void)presentItems:(NSArray *)items
{
    if (items.count > 0) {
        [UIView animateWithDuration:1.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.collectionView.layer.opacity = 1.0;
            self.coverView.layer.opacity = 0.0;
        } completion:^(BOOL finished) {
        }];

        self.presentedItems = items;

        [self.collectionView reloadData];
    } else {
        [UIView animateWithDuration:0.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.nothingFoundLabel.layer.opacity = 1.0;
            self.coverView.layer.opacity = 1.0;
        } completion:nil];
    }
}

# pragma mark - collection view delegate / data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.presentedItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommentModel *item = self.presentedItems[INDEX(indexPath)];

    CommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCommentCellIdentifier forIndexPath:indexPath];
    [cell setPreviewImageWithUrl:nil];
    cell.thumbnail.image = nil;

    cell.authorLabel.text = item.author;
    cell.timeLabel.text = item.time;
    if (![item.likes isEqualToString:@"0"]) {
        cell.likesLabel.text = [NSString stringWithFormat:@"👍 %@", item.likes];
    }
    else {
        cell.likesLabel.text = @"👻";
    }
    cell.contentLabel.text = item.content;
    [cell setPreviewImageWithUrl:item.avatar];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommentModel *item = self.presentedItems[INDEX(indexPath)];

    CGRect contentRect = [item.content
                        boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 0)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:16] }
                        context:nil];

    CGFloat height = 130 + contentRect.size.height;
    CGSize result = CGSizeMake(collectionView.bounds.size.width, height);
    return result;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets result = UIEdgeInsetsZero;
    return result;
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
    errorPopup.backgroundColor = [UIColor whiteColor];
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
    return @"CommentsViewController";
}

@end
