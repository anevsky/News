//
//  HomeDataSource.m
//  Belarus
//
//  Created by Alex Nevsky on 22.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "HomeControllerDefaultDataSource.h"
#import "PRTaskProtocol.h"
#import "PRBlockOperation.h"
#import "NewsModel.h"
#import "CategoryModel.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import <HTMLReader/HTMLReader.h>

static NSString *kNewsInfoUrlString = @"";

@interface HomeControllerDefaultDataSource ()

@end

@implementation HomeControllerDefaultDataSource

- (id <PRTaskProtocol>)getNewsInfo
{
    id <PRTaskProtocol> apiRequestTask = [PRBlockOperation performOperationWithBlock:^(id <PRPromiseProtocol> promise) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:kNewsInfoUrlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {            
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            if (error == nil) {
                NSMutableArray *news = NSMutableArray.new;
                
                NSArray *newsInfoCollection = json[@"news"];
                for (NSDictionary *newsInfo in newsInfoCollection) {
                    NewsModel *model = NewsModel.new;
                    
                    model.newsId = newsInfo[@"id"];
                    model.title = newsInfo[@"title"];
                    model.author = newsInfo[@"author"];
                    model.category = newsInfo[@"category"];
                    
                    model.imagePreviewUrl = [NSURL URLWithString:newsInfo[@"imageUrl"]];
                    model.sourceUrl = [NSURL URLWithString:newsInfo[@"sourceUrl"]];
                    
                    model.commentsCount = @"∞";
                    model.level = @1;
                    
                    [news addObject:model];
                }
                
                NSMutableArray *categoriesWithNews = NSMutableArray.new;
                CategoryModel *peopleNews = CategoryModel.new;
                peopleNews.title = @"Люди";
                CategoryModel *autoNews = CategoryModel.new;
                autoNews.title = @"Авто";
                CategoryModel *techNews = CategoryModel.new;
                techNews.title = @"Технологии";
                CategoryModel *entertainmentNews = CategoryModel.new;
                entertainmentNews.title = @"Развлечения";
                
                for (NewsModel *model in news) {
                    if ([model.category isEqualToString:@"Люди"]) {
                        [peopleNews addNewsModel:model];
                    }
                    else if ([model.category isEqualToString:@"Авто"]) {
                        [autoNews addNewsModel:model];
                    }
                    else if ([model.category isEqualToString:@"Технологии"]) {
                        [techNews addNewsModel:model];
                    }
                    else if ([model.category isEqualToString:@"Развлечения"]) {
                        [entertainmentNews addNewsModel:model];
                    }
                }
                
                [categoriesWithNews addObject:peopleNews];
                [categoriesWithNews addObject:autoNews];
                [categoriesWithNews addObject:techNews];
                [categoriesWithNews addObject:entertainmentNews];
                
                [promise fulfillWithResult:categoriesWithNews];
            }
            else {
                [promise rejectWithError:error];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [promise rejectWithError:error];
        }];
    }];
    
    return apiRequestTask;
}

@end
