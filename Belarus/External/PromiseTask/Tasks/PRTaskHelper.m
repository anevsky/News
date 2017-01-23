//
// PRTaskHelper.
//

#import "PRTaskHelper.h"
#import "PRTaskProtocol.h"
#import "PRBlockOperation.h"

@interface PRTaskHelper ()

@end

@implementation PRTaskHelper 

+ (id <PRTaskProtocol>)wrapTask:(id <PRTaskProtocol>)task
{
    id <PRTaskProtocol> wrappedTask = [PRBlockOperation performOperationWithBlock:^(id <PRPromiseProtocol> promise) {
        [task onComplete:^(id result, id error) {
            [promise resolveWithResult:result andError:error];
        }];
    }];

    [task onCancel:^{
        [wrappedTask cancel];
    }];

    return wrappedTask;
}

+ (id <PRTaskProtocol>)createAuxiliaryTaskTaskForTask:(id <PRTaskProtocol>)task
{
    id <PRTaskProtocol> auxiliaryTask = [self wrapTask:task];
    [auxiliaryTask onCancel:^{
        [task cancel];
    }];

    return auxiliaryTask;
}

@end