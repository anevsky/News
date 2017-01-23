//
//  CommentCell.m
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+AFNetworking.h"
#import <Masonry/View+MASAdditions.h>

@interface CommentCell ()

@property (nonatomic, strong, readwrite) UILabel *authorLabel;
@property (nonatomic, strong, readwrite) UILabel *timeLabel;
@property (nonatomic, strong, readwrite) UILabel *likesLabel;
@property (nonatomic, strong, readwrite) UILabel *contentLabel;
@property (nonatomic, strong, readwrite) UIImageView *thumbnail;

@end

@implementation CommentCell

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
    contentContainer.backgroundColor = [UIColor clearColor];

    UIImageView *coverImage = UIImageView.new;
    coverImage.image = [UIImage imageNamed:@"photo-frame"];
    [contentContainer addSubview:coverImage];
    [coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentContainer);
    }];

    UIView *headerView = UIView.new;
    [contentContainer addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentContainer);
        make.leading.equalTo(contentContainer);
        make.trailing.equalTo(contentContainer);
        make.height.equalTo(@80);
    }];

    UIImageView *thumbnailView = [UIImageView new];
    self.thumbnail = thumbnailView;
    thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    thumbnailView.clipsToBounds = YES;
    thumbnailView.layer.cornerRadius = 30;
    thumbnailView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    thumbnailView.layer.borderWidth = 1.0;
    [headerView addSubview:thumbnailView];

    [self.thumbnail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(12);
        make.leading.equalTo(headerView).offset(12);
        make.width.height.equalTo(@60);
    }];

    UILabel *timeLabel = [UILabel new];
    self.timeLabel = timeLabel;
    timeLabel.numberOfLines = 0;
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.adjustsFontSizeToFitWidth = YES;
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor colorWithRed:57.0/255.0 green:73.0/255.0 blue:171.0/255.0 alpha:1.0];
    [headerView addSubview:timeLabel];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thumbnail);
        make.leading.equalTo(self.thumbnail.mas_trailing).offset(10);
        make.trailing.equalTo(headerView).offset(-7);
    }];

    UILabel *authorLabel = [UILabel new];
    self.authorLabel = authorLabel;
    authorLabel.numberOfLines = 1;
    authorLabel.textAlignment = NSTextAlignmentLeft;
    authorLabel.adjustsFontSizeToFitWidth = NO;
    authorLabel.font = [UIFont systemFontOfSize:22];
    authorLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0];
    [headerView addSubview:authorLabel];

    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeLabel.mas_bottom).offset(2);
        make.leading.equalTo(self.thumbnail.mas_trailing).offset(10);
        make.trailing.equalTo(headerView).offset(-7);
    }];

    UILabel *likesLabel = [UILabel new];
    self.likesLabel = likesLabel;
    likesLabel.numberOfLines = 1;
    likesLabel.textAlignment = NSTextAlignmentLeft;
    likesLabel.adjustsFontSizeToFitWidth = NO;
    likesLabel.font = [UIFont systemFontOfSize:12];
    likesLabel.textColor = [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:0.7];
    [headerView addSubview:likesLabel];

    [self.likesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(authorLabel.mas_bottom).offset(7);
        make.leading.equalTo(self.thumbnail.mas_trailing).offset(10);
        make.trailing.equalTo(headerView).offset(-7);
    }];

    UILabel *contentLabel = [UILabel new];
    self.contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.adjustsFontSizeToFitWidth = NO;
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.textColor = [UIColor colorWithRed:38.0/255.0 green:50.0/255.0 blue:56.0/255.0 alpha:1.0];
    [contentContainer addSubview:contentLabel];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom).offset(5);
        make.leading.equalTo(contentContainer).offset(12);
        make.trailing.equalTo(contentContainer).offset(-12);
    }];

//    UIView *separatorView = UIView.new;
//    separatorView.backgroundColor = [UIColor blackColor];
//    [contentContainer addSubview:separatorView];
//
//    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.bottom.equalTo(contentContainer);
//        make.height.equalTo(@1);
//    }];
}

- (void)setPreviewImageWithUrl:(NSURL *)previewUrl
{
    [self.thumbnail setImageWithURL:previewUrl placeholderImage:[UIImage imageNamed:@"avatar-placeholder"]];
}

@end
