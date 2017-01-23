//
//  ArticleCell.m
//  Belarus
//
//  Created by Aliaksei Neuski on 22.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "NewsCell.h"
#import "UIImageView+AFNetworking.h"
#import <Masonry/View+MASAdditions.h>
#import "GlobalConstants.h"

@interface NewsCell ()

@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *categoryLabel;
@property (nonatomic, strong, readwrite) UILabel *commentsLabel;
@property (nonatomic, strong, readwrite) UIImageView *thumbnail;

@end

@implementation NewsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self setupContent];
}

- (void)setupContent
{
    UIView *contentContainer = self.contentView;
    contentContainer.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];

    UIImageView *thumbnailView = [UIImageView new];
    self.thumbnail = thumbnailView;
    thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailView.clipsToBounds = YES;
    [contentContainer addSubview:thumbnailView];

    [self.thumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.leading.trailing.equalTo(self);
        if (IS_IPAD) {
            make.height.equalTo(@300);
        }
        else if (IS_IPHONE_6_OR_GREATER) {
            make.height.equalTo(@200);
        }
        else {
            make.height.equalTo(@150);
        }
    }];

    UIView *headerView = UIView.new;
    headerView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
    [contentContainer addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thumbnail.mas_bottom).offset(-30);
        make.leading.equalTo(self).offset(7);
        make.trailing.equalTo(self).offset(-7);
        make.bottom.equalTo(self);
    }];

    UILabel *categoryLabel = [UILabel new];
    self.categoryLabel = categoryLabel;
    categoryLabel.numberOfLines = 1;
    categoryLabel.textAlignment = NSTextAlignmentLeft;
    categoryLabel.adjustsFontSizeToFitWidth = NO;
    categoryLabel.font = [UIFont systemFontOfSize:12];
    categoryLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0];
    [headerView addSubview:categoryLabel];

    [self.categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(5);
        make.leading.equalTo(headerView).offset(7);
        make.trailing.equalTo(headerView).offset(-7);
    }];

    UILabel *titleLabel = [UILabel new];
    self.titleLabel = titleLabel;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
    [headerView addSubview:titleLabel];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(categoryLabel.mas_bottom).offset(1);
        make.leading.equalTo(headerView).offset(7);
        make.trailing.equalTo(headerView).offset(-7);
    }];
    
    UILabel *commentsLabel = [UILabel new];
    self.commentsLabel = commentsLabel;
    commentsLabel.numberOfLines = 0;
    commentsLabel.textAlignment = NSTextAlignmentLeft;
    commentsLabel.adjustsFontSizeToFitWidth = NO;
    commentsLabel.font = [UIFont systemFontOfSize:12];
    commentsLabel.textColor = [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0];
    [contentContainer addSubview:commentsLabel];
    
    [self.commentsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(7);
        make.leading.equalTo(headerView).offset(7);
        make.trailing.equalTo(headerView).offset(-7);
    }];
}

- (void)setPreviewImageWithUrl:(NSURL *)previewUrl
{
    [self.thumbnail setImageWithURL:previewUrl placeholderImage:[UIImage imageNamed:@"news-placeholder"]];
}

@end
