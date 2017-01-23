//
//  ArticleModel.h
//  Belarus
//
//  Created by Aliaksei Neuski on 22.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *commentsCount;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *markup;

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSURL *imagePreviewUrl;
@property (nonatomic, strong) NSURL *sourceUrl;

@property (nonatomic, strong) NSNumber *level;

@end
