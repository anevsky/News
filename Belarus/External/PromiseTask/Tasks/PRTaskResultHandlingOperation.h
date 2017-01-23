//
// PRTaskResultHandlingOperation.
//

#import <Foundation/Foundation.h>
#import "PROperationProtocol.h"

@protocol PRTaskProtocol;
@protocol PRPromiseProtocol;

@interface PRTaskResultHandlingOperation : NSObject <PROperationProtocol>

- (instancetype)initWithTask:(id <PRTaskProtocol>)task taskBlock:(void (^)(id result, id error, id <PRPromiseProtocol> promise))handlerTask;


@end