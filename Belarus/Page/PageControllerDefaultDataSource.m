//
//  PageControllerDefaultDataSource.m
//  Belarus
//
//  Created by Aliaksei Neuski on 23.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "PageControllerDefaultDataSource.h"
#import "PRTaskProtocol.h"
#import "PRBlockOperation.h"
#import "NewsModel.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

static NSString *kBootstrapTemplate = @" \
<!DOCTYPE html> \
<html lang=\"ru\"> \
<head> \
<meta charset=\"utf-8\"> \
<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"> \
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"> \
<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags --> \
 \
<title>Belarus</title> \
 \
<!-- Bootstrap core CSS --> \
<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\" integrity=\"sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u\" crossorigin=\"anonymous\"> \
 \
<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css\"> \
 \
<style> \
.blog-masthead { \
    background-color: #62ADEC; \
    -webkit-box-shadow: inset 0 -2px 5px rgba(0,0,0,.1); \
    box-shadow: inset 0 -2px 5px rgba(0,0,0,.1); \
} \
p { \
font-size: 115%; \
} \
</style> \
 \
</head> \
 \
<body> \
 \
<!-- <div class=\"blog-masthead\">&nbsp;</div> --> \
 \
<div> \
#INSERT_HTML_CODE \
</div> \
 \
<!-- Bootstrap core JavaScript \
================================================== --> \
<!-- Placed at the end of the document so the pages load faster --> \
<script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js\"></script> \
<script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js\" integrity=\"sha256-KXn5puMvxCw+dAYznun+drMdG1IFl3agK0p/pqT9KAo= sha512-2e8qq0ETcfWRI4HJBzQiA3UoyFk6tbNyG+qSaIBZLyW9Xf3sWZHN/lxe9fTh1U45DpPf07yj94KsUHHWe4Yk1A==\" crossorigin=\"anonymous\"></script> \
</body> \
</html> \
";

static NSString *kBestCommentTemplate = @" \
<div class=\"container\"> \
<div class=\"panel panel-primary\"> \
<div class=\"panel-heading\"> \
<h3 class=\"panel-title\">Лучший комментарий</h3> \
</div> \
<div class=\"panel-body\"> \
<span class=\"label label-info\">#TIME</span> <br>&nbsp; \
<div><img src=\"#IMAGE\" class=\"img-responsive img-circle\"></div> \
<br> \
<span class=\"label label-success\">#AUTHOR</span> \
<span class=\"label label-danger\">👍 #LIKES</span> \
<div><br> \
#CONTENT \
</div> \
</div> \
</div> \
</div> \
";

static NSString *kResponsiveEmbedTemplate = @" \
<div class=\"embed-responsive embed-responsive-16by9\"> \
<iframe class=\"embed-responsive-item\" src=\"#SRC_URL\"></iframe> \
</div> \
";

@interface PageControllerDefaultDataSource ()

@end

@implementation PageControllerDefaultDataSource

- (id <PRTaskProtocol>)getPageInfoWithModel:(NewsModel *)model
{
    NSString *newsInfoUrl = [NSString stringWithFormat:@"http://localhost/%@", model.newsId];
    
    id <PRTaskProtocol> apiRequestTask = [PRBlockOperation performOperationWithBlock:^(id <PRPromiseProtocol> promise) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:newsInfoUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError* error;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&error];
            if (error == nil) {
                NSArray *newsInfoCollection = json[@"news"];
                for (NSDictionary *newsInfo in newsInfoCollection) {
                    model.newsId = newsInfo[@"id"];
                    model.title = newsInfo[@"title"];
                    model.category = newsInfo[@"category"];
                    model.author = newsInfo[@"author"];
                    model.time = newsInfo[@"publishDate"];
                    model.markup = newsInfo[@"message"];
                    
                    model.tags = [newsInfo[@"tagsCollection"] componentsSeparatedByString:@", "];
                    
                    model.videoUrl = [NSURL URLWithString:newsInfo[@"videoUrl"]];
                    model.imagePreviewUrl = [NSURL URLWithString:newsInfo[@"imageUrl"]];
                    model.sourceUrl = [NSURL URLWithString:newsInfo[@"sourceUrl"]];
                    
                    model.commentsCount = @"∞";
                    model.level = @1;
                }
            }
            
            NSMutableString *sb = NSMutableString.new;
            if (model != nil) {
                // first
                if (model.videoUrl.absoluteString.length == 0) {
                    // image
                    [sb appendString:@"<div>"];
                    [sb appendString:[NSString stringWithFormat:@"<img style=\"width:100%%;\" class=\"img-responsive\" src=\"%@\"/>", model.imagePreviewUrl.absoluteString]];
                    [sb appendString:@"</div>"];
                }
                else {
                    // video
                    [sb appendString:[kResponsiveEmbedTemplate stringByReplacingOccurrencesOfString:@"#SRC_URL" withString:model.videoUrl.absoluteString]];
                }
                
                // category and time
                [sb appendString:[NSString stringWithFormat:@"<div class=\"container\"><br><span class=\"label label-danger\">%@</span> <span class=\"label label-info\">%@</span>", model.category, model.time]];
                [sb appendString:@"</div>"];
                
                // title
                [sb appendString:[NSString stringWithFormat:@"<div class=\"container\"><h4>%@</h4></div>", model.title]];
                
                // tags
                [sb appendString:@"<div class=\"container\">"];
                for (NSString *tag in model.tags) {
                    [sb appendString:[NSString stringWithFormat:@"<span class=\"label label-success\">%@</span> ", tag]];
                }
                [sb appendString:@"<br>&nbsp;</div>"];
                
                // paragraphs
                [sb appendString:[NSString stringWithFormat:@"<div class=\"container\">%@</div>", model.markup]];
                
                // author
                [sb appendString:[NSString stringWithFormat:@"<div class=\"container small\"><br>&nbsp;<span class=\"label label-warning\">%@</span><br>&nbsp;</div>", model.author]];
                
                // best comment
                if ([model.commentsCount intValue] > 1) {
                    NSString *bestCommentAuthor = @"";
                    NSString *bestCommentTime = @"";
                    NSString *avatarLink = @"";
                    NSString *commentContent = @"";
                    NSString *commentLikes = @"";
                    
                    NSString *bestCommentHtml = [[[[[kBestCommentTemplate stringByReplacingOccurrencesOfString:@"#IMAGE" withString:avatarLink] stringByReplacingOccurrencesOfString:@"#AUTHOR" withString:bestCommentAuthor] stringByReplacingOccurrencesOfString:@"#TIME" withString:bestCommentTime] stringByReplacingOccurrencesOfString:@"#LIKES" withString:commentLikes] stringByReplacingOccurrencesOfString:@"#CONTENT" withString:commentContent];
                    
                    [sb appendString:bestCommentHtml];
                }
            }
            
            model.markup = [kBootstrapTemplate stringByReplacingOccurrencesOfString:@"#INSERT_HTML_CODE" withString:sb];

            [promise fulfillWithResult:model];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error getPageInfoWithModel %@: %@", model.newsId, error);
            [promise rejectWithError:error];
        }];
    }];

    return apiRequestTask;
}

@end
