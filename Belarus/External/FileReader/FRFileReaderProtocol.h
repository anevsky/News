//
// FRFileReaderProtocol.
//

#import <Foundation/Foundation.h>

@protocol FRFileReaderProtocol <NSObject>

- (NSString*)readLine;
- (void)skipLine;
- (void)skipLines:(NSUInteger)numberOfLines;

@property (nonatomic, assign, readonly) BOOL isDone;
@property (nonatomic, assign, readonly) BOOL hasMore;


@end