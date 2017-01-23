//
// PRBlockOperation.
//

#import <Foundation/Foundation.h>
#import "PRPromiseProtocol.h"
#import "PRTaskProtocol.h"
#import "PROperationProtocol.h"

@protocol PRPromiseProtocol;

typedef void (^FFTaskBlock)(id <PRPromiseProtocol> promise);
typedef void (^FFThenTaskBlock)(id prevResult, id <PRPromiseProtocol> promise);

@interface PRBlockOperation : NSObject <PROperationProtocol>

- (instancetype)initWithTaskBlock:(FFTaskBlock)taskBlock;
- (instancetype)initWithThenTaskBlock:(FFThenTaskBlock)taskBlock;

+ (id <PRTaskProtocol>)performOperationWithBlock:(FFTaskBlock)taskBlock;

@end