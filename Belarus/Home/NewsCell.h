//
//  ArticleCell.h
//  Belarus
//
//  Created by Aliaksei Neuski on 22.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NewsCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *categoryLabel;
@property (nonatomic, strong, readonly) UILabel *commentsLabel;
@property (nonatomic, strong, readonly) UIImageView *thumbnail;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *spinnerView;

- (void)setPreviewImageWithUrl:(NSURL *)previewUrl;

@end
