//
//  AboutViewController.m
//  Belarus
//
//  Created by  Alex Nevsky on 26.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "AboutViewController.h"
#import <Masonry/View+MASAdditions.h>
#import "MetricaLogger.h"

static NSString *kAppRateLink = @"itms-apps://itunes.apple.com/app/id1180300697";
static NSString *kFbAccount = @"belarus.today";
static NSString *kVkAccount = @"belarus.today";
static NSString *kInstagramAccount = @"belarustodaycom";

@interface AboutViewController ()

@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIImageView *coverView;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"About Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"About", nil);
    
    UIView *contentContainer = UIView.new;
    
    self.contentContainer = contentContainer;
    [self.view addSubview:contentContainer];
    [contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    
    self.coverView = UIImageView.new;
    self.coverView.image = [UIImage imageNamed:@"belarus-launch"];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentContainer addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentContainer);
    }];
    
    UIView *descriptionView = UIView.new;
//    descriptionView.backgroundColor = [UIColor colorWithRed:57.0/255.0 green:73.0/255.0 blue:171.0/255.0 alpha:0.1];
    
    [self.contentContainer addSubview:descriptionView];
    [descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.contentContainer);
        make.height.equalTo(@230);
    }];
    
    UIImageView *avatar = UIImageView.new;
    avatar.image = [UIImage imageNamed:@"avatar"];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.clipsToBounds = YES;
    avatar.layer.cornerRadius = 40;
    avatar.layer.opacity = 0.0;
    avatar.layer.borderColor = [UIColor grayColor].CGColor;
    avatar.layer.borderWidth = 0.5;
    
    [descriptionView addSubview:avatar];
    [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descriptionView);
        make.centerX.equalTo(descriptionView);
        make.width.height.equalTo(@80);
    }];
    
    UILabel *authorLabel = UILabel.new;
    authorLabel.text = [NSString stringWithFormat:@"2017 © %@", NSLocalizedString(@"From Belarus with ♥.", nil)];
    authorLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7];
    authorLabel.textAlignment = NSTextAlignmentCenter;
    authorLabel.backgroundColor = [UIColor colorWithRed:103.0/255.0 green:58.0/255.0 blue:183.0/255.0 alpha:0.3];
    authorLabel.clipsToBounds = YES;
    authorLabel.layer.cornerRadius = 5;
    authorLabel.font = [UIFont boldSystemFontOfSize:14.0];
    
    [descriptionView addSubview:authorLabel];
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(avatar).offset(17);
        make.centerX.equalTo(descriptionView);
        make.height.equalTo(@25);
        make.width.equalTo(@210);
    }];
    
    UIImageView *vkIcon = UIImageView.new;
    vkIcon.image = [UIImage imageNamed:@"Vk.com"];
    vkIcon.contentMode = UIViewContentModeScaleAspectFill;
    vkIcon.layer.opacity = 0.7;
    
    [descriptionView addSubview:vkIcon];
    [vkIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(authorLabel.mas_bottom).offset(10);
        make.centerX.equalTo(descriptionView);
        make.width.height.equalTo(@50);
    }];
    
    UIImageView *fbIcon = UIImageView.new;
    fbIcon.image = [UIImage imageNamed:@"Facebook"];
    fbIcon.contentMode = UIViewContentModeScaleAspectFill;
    fbIcon.layer.opacity = 0.7;
    
    [descriptionView addSubview:fbIcon];
    [fbIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(vkIcon);
        make.trailing.equalTo(vkIcon.mas_leading).offset(-7);
        make.width.height.equalTo(@50);
    }];
    
    UIImageView *instagramIcon = UIImageView.new;
    instagramIcon.image = [UIImage imageNamed:@"Instagram"];
    instagramIcon.contentMode = UIViewContentModeScaleAspectFill;
    instagramIcon.layer.opacity = 0.7;
    
    [descriptionView addSubview:instagramIcon];
    [instagramIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(vkIcon);
        make.leading.equalTo(vkIcon.mas_trailing).offset(7);
        make.width.height.equalTo(@50);
    }];
    
    UIImageView *heartIcon = UIImageView.new;
    heartIcon.image = [UIImage imageNamed:@"Hearts"];
    heartIcon.contentMode = UIViewContentModeScaleAspectFill;
    heartIcon.layer.opacity = 0.7;
    
    [descriptionView addSubview:heartIcon];
    [heartIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(vkIcon.mas_bottom);
        make.centerX.equalTo(descriptionView);
        make.width.height.equalTo(@50);
    }];
    
    fbIcon.userInteractionEnabled = YES;
    vkIcon.userInteractionEnabled = YES;
    instagramIcon.userInteractionEnabled = YES;
    heartIcon.userInteractionEnabled = YES;

    UITapGestureRecognizer *fbTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fbTap:)];
    fbTap.cancelsTouchesInView = YES;
    [fbIcon addGestureRecognizer:fbTap];
    
    UITapGestureRecognizer *vkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vkTap:)];
    vkTap.cancelsTouchesInView = YES;
    [vkIcon addGestureRecognizer:vkTap];
    
    UITapGestureRecognizer *instagramTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramTap:)];
    instagramTap.cancelsTouchesInView = YES;
    [instagramIcon addGestureRecognizer:instagramTap];
    
    UITapGestureRecognizer *heartTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAppStore:)];
    heartTap.cancelsTouchesInView = YES;
    [heartIcon addGestureRecognizer:heartTap];
}

- (void)fbTap:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Tap", @"FB Action", nil];
    [MetricaLogger reportToMetricaEvent:@"About Statistics" withParams:deviceStat];
    
    NSString *link = [NSString stringWithFormat:@"fb://profile/%@", kFbAccount];
    NSURL *url = [NSURL URLWithString:link];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        NSString *link = [NSString stringWithFormat:@"https://facebook.com/%@", kFbAccount];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    }
}

- (void)vkTap:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Tap", @"VK Action", nil];
    [MetricaLogger reportToMetricaEvent:@"About Statistics" withParams:deviceStat];
    
    NSString *link = [NSString stringWithFormat:@"vk://vk.com/%@", kVkAccount];
    NSURL *url = [NSURL URLWithString:link];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        NSString *link = [NSString stringWithFormat:@"https://vk.com/%@", kVkAccount];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    }
}

- (void)instagramTap:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Tap", @"Instagram Action", nil];
    [MetricaLogger reportToMetricaEvent:@"About Statistics" withParams:deviceStat];
    
    NSString *link = [NSString stringWithFormat:@"instagram://user?username=%@", kInstagramAccount];
    NSURL *url = [NSURL URLWithString:link];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        NSString *link = [NSString stringWithFormat:@"https://instagram.com/%@", kInstagramAccount];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
    }
}

- (void)openAppStore:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Tap", @"Rate Action", nil];
    [MetricaLogger reportToMetricaEvent:@"About Statistics" withParams:deviceStat];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppRateLink]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
