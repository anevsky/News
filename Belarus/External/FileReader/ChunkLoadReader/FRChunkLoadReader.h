//
// FRChunkLoadReader.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FRFileReaderProtocol.h"

@interface FRChunkLoadReader : NSObject <FRFileReaderProtocol>

- (id)initWithFilePath:(NSString*)filePath;

- (NSString*)readLine;
- (void)skipLine;
- (void)skipLines:(NSUInteger)numberOfLines;

@property (nonatomic, assign, readonly) BOOL isDone;
@property (nonatomic, assign, readonly) BOOL hasMore;

@end