//
//  CommentsControllerDefaultDataSource.m
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "CommentsControllerDefaultDataSource.h"
#import "PRTaskProtocol.h"
#import "PRBlockOperation.h"
#import "CommentModel.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

@implementation CommentsControllerDefaultDataSource

- (id <PRTaskProtocol>)getCommentsInfoFromUrl:(NSURL *)sourceUrl
{
    id <PRTaskProtocol> apiRequestTask = [PRBlockOperation performOperationWithBlock:^(id <PRPromiseProtocol> promise) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:[sourceUrl absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *markup = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

            NSMutableArray *itemsCollection = NSMutableArray.new;

            NSError *error;
            if (error == nil) {
                NSArray *commentsNodes = nil;
                
                NSString *content = nil;
                NSString *likes = nil;
                NSString *author = nil;
                NSString *avatar = nil;
                NSString *time = nil;

                CommentModel *model = CommentModel.new;
                model.content = content;
                model.likes = likes;
                model.author = author;
                model.avatar = [NSURL URLWithString:avatar];
                model.time = time;

                [itemsCollection addObject:model];
            }
            
            [promise fulfillWithResult:itemsCollection];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error getPageInfoWithModel %@: %@", sourceUrl.absoluteString, error);
            [promise rejectWithError:error];
        }];
    }];
    
    return apiRequestTask;
}


@end
