//
//  CommentsViewController.h
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NewsModel;

@protocol PRTaskProtocol;

@protocol CommentsControllerDataSource <NSObject>

- (id <PRTaskProtocol>)getCommentsInfoFromUrl:(NSURL *)sourceUrl;

@end

@interface CommentsViewController : UIViewController

@property (nonatomic, strong) NewsModel *newsModel;

+ (NSString *)identifier;

@end
