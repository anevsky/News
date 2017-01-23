//
//  PageViewController.h
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NewsModel;

@protocol PRTaskProtocol;

@protocol PageControllerDataSource <NSObject>

- (id <PRTaskProtocol>)getPageInfoWithModel:(NewsModel *)model;

@end

@interface PageViewController : UIViewController

@property (nonatomic, strong) NewsModel *newsModel;

+ (NSString *)identifier;

@end
