//
// PRInstantTask.
//

#import "PRInstantTask.h"
#import "PRBlockOperation.h"

@interface PRInstantTask ()

@property (nonatomic, strong) id result;
@property (nonatomic, strong) id error;

@end

@implementation PRInstantTask

- (instancetype)initWithResult:(id)result
{
    self = [self init];

    if ( self ) {
        self.result = result;
    }

    return self;
}

- (instancetype)initWithError:(id)error
{
    self = [self init];

    if ( self ) {
        self.error = error;
    }

    return self;
}

- (void)onComplete:(FFOnTaskComplete)completionHandler
{
    completionHandler(self.result, self.error);
}

- (void)onCancel:(FFOnTaskCanceled)cancelHandler
{

}

- (void)cancel
{

}

- (BOOL)isCanceled
{
    return NO;
}

- (BOOL)isComplete
{
    return YES;
}

- (id <PRTaskProtocol>)then:(FFThenBlock)thenBlock
{
    PRBlockOperation *operation = [[PRBlockOperation alloc] initWithTaskBlock:^(id <PRPromiseProtocol> promise) {
        [promise resolveWithResult:self.result andError:self.error];
    }];

    id <PRTaskProtocol> ownTask = [operation perform];

    return [ownTask then:thenBlock];
}

- (id <PRTaskProtocol>)catch:(FFCatchBlock)catchBlock
{
    PRBlockOperation *operation = [[PRBlockOperation alloc] initWithTaskBlock:^(id <PRPromiseProtocol> promise) {
        [promise resolveWithResult:self.result andError:self.error];
    }];

    id <PRTaskProtocol> ownTask = [operation perform];

    return [ownTask catch:catchBlock];
}

@end