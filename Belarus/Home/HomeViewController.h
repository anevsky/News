//
//  ViewController.h
//  Belarus
//
//  Created by Alex Nevsky on 11/19/16.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HomeViewController;
@class NewsModel;

@protocol PRTaskProtocol;

@protocol HomeControllerDataSource <NSObject>

- (id <PRTaskProtocol>)getNewsInfo;

@end

@protocol HomeControllerDelegate <NSObject>

- (void)homeController:(HomeViewController *)controller didSelectItem:(NewsModel *)news;
- (void)homeController:(HomeViewController *)controller onErrorOccured:(NSString *)error;

@end

@interface HomeViewController : UIViewController

+ (NSString *)identifier;

@property (nonatomic, weak) id <HomeControllerDelegate> delegate;

@end

