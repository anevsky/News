//
//  CategoryModel.h
//  Belarus
//
//  Created by  Alex Nevsky on 22.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewsModel;

@interface CategoryModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, readonly) NSMutableArray *items;

- (void)addNewsModel:(NewsModel *)newsModel;

@end
