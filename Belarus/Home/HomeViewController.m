//
//  ViewController.m
//  Belarus
//
//  Created by Alex Nevsky on 11/19/16.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeControllerDefaultDataSource.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import <Masonry/View+MASAdditions.h>
#import "NewsCell.h"
#import "PRTaskProtocol.h"
#import "MetricaLogger.h"
#import "NewsModel.h"
#import "CategoryModel.h"
#import "PageViewController.h"
#import "MenuViewController.h"
#import "GlobalConstants.h"

#define INDEX(indexPath) ((NSUInteger)indexPath.row)

static NSString *kNewsCellIdentifier = @"NewsCellIdentifier";
static NSInteger kNoInternetErrorCode = -1009;

@interface HomeViewController () <UICollectionViewDataSource, HomeControllerDelegate, CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nothingFoundLabel;
@property (nonatomic, strong) UIView *errorView;

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic, strong) id <HomeControllerDataSource> dataSource;
@property (nonatomic, strong) NSArray *presentedItems;
@property (nonatomic, strong) id <PRTaskProtocol> itemsRequestTask;

@property (nonatomic, strong) NSString *currentNewsCategoryPref;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"☰"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showMenu:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refresh:)];
    
    if (![self.currentNewsCategoryPref isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"NewsCategoryPref"]]) {
        [self.collectionView setContentOffset:CGPointZero];
        [self showItemsFromDataSource:self.dataSource];
    }
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Main", nil);

    self.dataSource = HomeControllerDefaultDataSource.new;
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"NewsCategoryPref"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"All" forKey:@"NewsCategoryPref"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

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
    [collectionView registerClass:NewsCell.class forCellWithReuseIdentifier:kNewsCellIdentifier];
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    collectionView.clipsToBounds = NO;
    [contentContainer addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentContainer);//.offset(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        make.leading.trailing.bottom.equalTo(contentContainer);
    }];

    self.coverView = UIImageView.new;
    self.coverView.image = [UIImage imageNamed:@"belarus-launch"];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    [contentContainer addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentContainer);
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

//- (void)clearPresentedItems
//{
//    self.presentedItems = nil;
//}

- (void)refresh:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Tap", @"Refresh Action", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];

    [self showItemsFromDataSource:self.dataSource];
}

- (void)showMenu:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Tap", @"Menu Open Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [self performSegueWithIdentifier:@"goToMenu" sender:self];
}

- (void)showItemsFromDataSource:(id <HomeControllerDataSource>)dataSource
{
//    [self clearPresentedItems];

    self.dataSource = dataSource;
    self.itemsRequestTask = [self.dataSource getNewsInfo];
//    [self showWait:YES];

    [UIView animateWithDuration:0.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if (items.count > 0) {
        [UIView animateWithDuration:0.9 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.collectionView.layer.opacity = 1.0;
            self.coverView.layer.opacity = 0.0;
        } completion:^(BOOL finished) {
        }];

        self.presentedItems = [self filterItemsCollection:items];

        [self.collectionView reloadData];
    } else {
        [UIView animateWithDuration:0.24 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.nothingFoundLabel.layer.opacity = 1.0;
            self.coverView.layer.opacity = 1.0;
        } completion:nil];
    }
}

- (NSArray *)filterItemsCollection:(NSArray *)items
{
    NSString *newsCategoryPref = [[NSUserDefaults standardUserDefaults] stringForKey:@"NewsCategoryPref"];
    self.currentNewsCategoryPref = newsCategoryPref;
    
    NSMutableArray *itemsCollection = NSMutableArray.new;
    for (CategoryModel *category in items) {
        if (newsCategoryPref == nil || [newsCategoryPref isEqualToString:@"All"]) {
            [itemsCollection addObjectsFromArray:category.items];
        }
        else if ([newsCategoryPref isEqualToString:@"People"] && [category.title isEqualToString:@"Люди"]) {
            [itemsCollection addObjectsFromArray:category.items];
        }
        else if ([newsCategoryPref isEqualToString:@"Auto"] && [category.title isEqualToString:@"Авто"]) {
            [itemsCollection addObjectsFromArray:category.items];
        }
        else if ([newsCategoryPref isEqualToString:@"Technology"] && [category.title isEqualToString:@"Технологии"]) {
            [itemsCollection addObjectsFromArray:category.items];
        }
        else if ([newsCategoryPref isEqualToString:@"Entertainment"] && [category.title isEqualToString:@"Развлечения"]) {
            [itemsCollection addObjectsFromArray:category.items];
        }
    }
    
    return itemsCollection;
}

- (void)homeController:(HomeViewController *)controller didSelectItem:(NewsModel *)item
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:item.sourceUrl.absoluteString, @"News Selection URL", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];
    
    deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:item.title, @"News Selection Title", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];
    
    deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:item.category, @"News Selection Category", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"hh";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@ { [dateFormatter stringFromDate:now] : item.title }, @"News Title Selection Time", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];
    
    deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@ { [dateFormatter stringFromDate:now] : item.category }, @"News Category Selection Time", nil];
    [MetricaLogger reportToMetricaEvent:@"App Statistics" withParams:deviceStat];

    [self performSegueWithIdentifier:@"goToPage" sender:item];
}

- (void)homeController:(HomeViewController *)controller onErrorOccured:(NSString *)error
{
    //
}

# pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"goToPage"]) {
        PageViewController *vc = [segue destinationViewController];
        vc.newsModel = sender;
    }
    else if ([[segue identifier] isEqualToString:@"goToMenu"]) {
        // nothing
    }
}

# pragma mark - collection view delegate / data source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.presentedItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel *item = nil;
    if (self.presentedItems.count > 0) {
        item = self.presentedItems[INDEX(indexPath)];
    }

    NewsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNewsCellIdentifier forIndexPath:indexPath];
    [cell setPreviewImageWithUrl:nil];
    cell.thumbnail.image = nil;
    
    if (item.level.intValue == 1) {
        cell.titleLabel.text = [NSString stringWithFormat:@"✪ %@", item.title];
    }
    else {
        cell.titleLabel.text = item.title;
    }
    
    cell.categoryLabel.text = item.category;
    cell.commentsLabel.text = [NSString stringWithFormat:@"👻 %@ ❯", item.commentsCount];
    
    [cell setPreviewImageWithUrl:item.imagePreviewUrl];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel *item = nil;
    if (self.presentedItems.count > 0) {
        item = self.presentedItems[INDEX(indexPath)];
    }

    [self homeController:self didSelectItem:item];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 275;
    
    if (IS_IPAD) {
        height = 400;
    }
    else if (IS_IPHONE_6_OR_GREATER) {
        height = 325;
    }
    
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
    return @"HomeViewController";
}

@end
