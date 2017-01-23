//
// PRPromiseProtocol.
//

#import <Foundation/Foundation.h>
#import "PRCancelableProtocol.h"

@protocol PRPromiseProtocol;

typedef void (^FFOnTaskComplete)(id result, id error);
typedef void (^FFOnTaskCanceled)();

typedef void (^FFThenBlock)(id result, id <PRPromiseProtocol> promise);
typedef void (^FFCatchBlock)(id error, id <PRPromiseProtocol> promise);

@protocol PRTaskProtocol <NSObject, PRCancelableProtocol>

- (void)onComplete:(FFOnTaskComplete)completionHandler;
- (void)onCancel:(FFOnTaskCanceled)cancelHandler;

- (id <PRTaskProtocol>)then:(FFThenBlock)thenBlock;
- (id <PRTaskProtocol>)catch:(FFCatchBlock)catchBlock;

@property (nonatomic, assign, readonly) BOOL isComplete;

@end