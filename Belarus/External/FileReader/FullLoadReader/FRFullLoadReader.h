//
// FRFullLoadReader.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FRFileReaderProtocol.h"

@interface FRFullLoadReader : NSObject <FRFileReaderProtocol>

- (instancetype)initWithFile:(NSString *)file;

@end