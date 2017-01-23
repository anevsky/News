//
// PRTaskResultHandlingOperation.
//

#import "PRTaskResultHandlingOperation.h"
#import "PRTaskProtocol.h"
#import "PRPromiseProtocol.h"
#import "PRBlockOperation.h"

@interface PRTaskResultHandlingOperation ()

@property (nonatomic, strong) PRBlockOperation *internalOperation;

@end

@implementation PRTaskResultHandlingOperation
{

}

- (instancetype)initWithTask:(id <PRTaskProtocol>)task taskBlock:(void (^)(id result, id error, id <PRPromiseProtocol> promise))handlerTask
{
    self = [self init];
    if ( self ) {
        self.internalOperation = [[PRBlockOperation alloc] initWithTaskBlock:^(id <PRPromiseProtocol> promise) {
            [task onComplete:^(id result, id error) {
                handlerTask(result, error, promise);
            }];
        }];
    }

    return self;
}

- (id <PRTaskProtocol>)perform
{
    return [self.internalOperation perform];
}

@end