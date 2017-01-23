//
// PRPromiseProtocol.
//

#import <Foundation/Foundation.h>

@protocol PRTaskProtocol;

@protocol PRPromiseProtocol <NSObject>

- (void)fulfillWithResult:(id)result;
- (void)fulfillWithTask:(id<PRTaskProtocol>)task;

- (void)rejectWithError:(id)error;

- (void)resolveWithResult:(id)result andError:(id)error;

@property (nonatomic, assign, readonly) BOOL isResolved;

@end