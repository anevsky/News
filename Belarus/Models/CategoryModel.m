//
//  CategoryModel.m
//  Belarus
//
//  Created by  Alex Nevsky on 22.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "CategoryModel.h"

@interface CategoryModel ()

@property (nonatomic, strong, readwrite) NSMutableArray *items;


@end

@implementation CategoryModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.items = NSMutableArray.new;
}

- (void)addNewsModel:(NewsModel *)newsModel
{
    if (newsModel != nil) {
        [self.items addObject:newsModel];
    }
}

@end
