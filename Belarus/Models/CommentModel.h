//
//  CommentModel.h
//  Belarus
//
//  Created by Aliaksei Neuski on 24.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *likes;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSURL *avatar;

@end
