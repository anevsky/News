//
//  HTMLParser.h
//  StackOverflow
//
//  Created by Ben Reeves on 09/03/2010.
//  Copyright 2010 Ben Reeves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/HTMLparser.h>
#import "BNHTMLNode.h"

@class BNHTMLNode;

@interface BNHTMLParser : NSObject 
{
	@public
	htmlDocPtr _doc;
}

-(id)initWithContentsOfURL:(NSURL*)url error:(NSError**)error;
-(id)initWithData:(NSData*)data error:(NSError**)error;
-(id)initWithString:(NSString*)string error:(NSError**)error;

//Returns the doc tag
-(BNHTMLNode*)doc;

//Returns the body tag
-(BNHTMLNode*)body;

//Returns the html tag
-(BNHTMLNode*)html;

//Returns the head tag
- (BNHTMLNode*)head;

@end
