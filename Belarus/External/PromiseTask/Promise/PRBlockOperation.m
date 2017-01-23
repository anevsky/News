//
// PRBlockOperation.
//

#import "AFNetworking.h"
#import "PRBlockOperation.h"
#import "PRPromiseProtocol.h"
#import "UIActivityIndicatorView+AFNetworking.h"

@interface PRCancellationToken : NSObject

- (void)onCancel:(FFOnTaskCanceled)cancelHandler;
- (void)cancel;

@property (nonatomic, assign, readonly) BOOL isCancelled;

@end

@interface PRBlockOperation () <PRPromiseProtocol, PRTaskProtocol>

@property (nonatomic, strong) NSMutableOrderedSet *onCompletionListeners;
@property (nonatomic, strong) NSMutableOrderedSet *onCancelListeners;

@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL fulfilled;

@property (nonatomic, copy) FFThenTaskBlock taskBlock;

@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) PRCancellationToken *cancellationToken;

@end

@implementation PRBlockOperation

- (instancetype)initWithTaskBlock:(FFTaskBlock)taskBlock
{
    self = [self init];

    if ( self ) {
        self.cancellationToken = [PRCancellationToken new];
        self.taskBlock = ^(id prevResult, id <PRPromiseProtocol> promise) {
            taskBlock(promise);
        };

        [self setup];
    }

    return self;
}

- (instancetype)initWithThenTaskBlock:(FFThenTaskBlock)taskBlock
{
    return [self initWithThenTaskBlock:taskBlock andCancellationToken:nil];
}

- (instancetype)initWithThenTaskBlock:(FFThenTaskBlock)taskBlock andCancellationToken:(PRCancellationToken *)cancellationToken
{
    self = [self init];

    if ( self ) {
        self.taskBlock = taskBlock;
        self.cancellationToken = cancellationToken ?: [PRCancellationToken new];

        [self setup];
    }

    return self;
}


- (void)setup
{
    
    self.onCompletionListeners = NSMutableOrderedSet.new;
    self.onCancelListeners = NSMutableOrderedSet.new;

    self.started = NO;
    self.canceled = NO;
    self.fulfilled = NO;


    __weak typeof(self) weakSelf = self;
    [self.cancellationToken onCancel:^{
        [weakSelf performCancellation];
    }];
}

+ (id <PRTaskProtocol>)performOperationWithBlock:(FFTaskBlock)taskBlock
{
    PRBlockOperation *operation = [[PRBlockOperation alloc] initWithTaskBlock:taskBlock];
    return [operation perform];
}


- (void)onComplete:(FFOnTaskComplete)completionListener
{
    if (!self.isCanceled) {
        if (self.isResolved) {
            completionListener(self.result, self.error);
        } else {
            [self.onCompletionListeners addObject:completionListener];
        }
    }
}

- (void)onCancel:(FFOnTaskCanceled)cancelHandler
{
    if (!self.isResolved) {
        if (self.isCanceled) {
            cancelHandler();
        } else {
            [self.onCancelListeners addObject:cancelHandler];
        }
    }
}

- (id <PRTaskProtocol>)performWithPrevResult:(id)result
{
    if ( self.canceled || self.fulfilled ) {
        return self;
    }

    if ( !self.started ) {
        self.started = YES;
        self.taskBlock(result, self);
    }

    return self;
}

- (id <PRTaskProtocol>)perform
{
    return [self performWithPrevResult:nil];
}

- (void)fulfillWithResult:(id)result
{
    [self resolveWithResult:result andError:nil];
}

- (void)rejectWithError:(id)error
{
    [self resolveWithResult:nil andError:error];
}

- (void)resolveWithResult:(id)result andError:(id)error
{
    if ( self.canceled || self.fulfilled ) {
        return;
    }

    self.fulfilled = YES;

    self.result = result;
    self.error = error;

    for ( FFOnTaskComplete onTaskComplete in self.onCompletionListeners )  {
        onTaskComplete(self.result, self.error);
    }

    [self.onCompletionListeners removeAllObjects];
    [self.onCancelListeners removeAllObjects];
    self.taskBlock = nil;
}

- (BOOL)isResolved
{
    return self.fulfilled;
}


- (void)cancel
{
    [self.cancellationToken cancel];
}

- (void)performCancellation
{
    if ( self.canceled || self.fulfilled ) {
        return;
    }

    self.canceled = YES;


    for ( FFOnTaskCanceled onTaskCanceled in self.onCancelListeners )  {
        onTaskCanceled();
    }

    [self.onCompletionListeners removeAllObjects];
    [self.onCancelListeners removeAllObjects];
    self.taskBlock = nil;
}

- (BOOL)isCanceled
{
    return self.canceled;
}

- (BOOL)isComplete
{
    return self.result != nil || self.error != nil;
}

#pragma mark then

- (id <PRTaskProtocol>)then:(FFThenBlock)thenBlock
{
    PRBlockOperation *operation = [[PRBlockOperation alloc] initWithThenTaskBlock:^(id prevResult, id <PRPromiseProtocol> promise) {
        thenBlock(prevResult, promise);
    } andCancellationToken:self.cancellationToken];

    [self onComplete:^(id result, id error) {

        if (error == nil)  {
            [operation performWithPrevResult:result];
        } else {
            [operation rejectWithError:error];
        }
    }];

    return operation;
}

- (id <PRTaskProtocol>)catch:(FFCatchBlock)catchBlock
{
    PRBlockOperation *operation = [[PRBlockOperation alloc] initWithThenTaskBlock:^(id error, id <PRPromiseProtocol> promise) {
        catchBlock(error, promise);
    } andCancellationToken:self.cancellationToken];

    [self onComplete:^(id result, id error) {

        if (error != nil)  {
            [operation performWithPrevResult:error];
        } else {
            [operation fulfillWithResult:result];
        }
    }];

    return operation;
}

- (void)fulfillWithTask:(id <PRTaskProtocol>)task
{
    [self onCancel:^{
        [task cancel];
    }];

    [task onCancel:^{
        [self cancel];
    }];

    [task onComplete:^(id result, id error) {
        [self resolveWithResult:result andError:error];
    }];
}

@end

@interface PRCancellationToken ()

@property (nonatomic, strong) NSMutableArray *cancellationHandlers;
@property (nonatomic, assign) BOOL isCancelled;

@end

@implementation PRCancellationToken

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cancellationHandlers = [NSMutableArray arrayWithCapacity:2];
        self.isCancelled = NO;
    }

    return self;
}


- (void)onCancel:(FFOnTaskCanceled)cancelHandler
{
    if (!self.isCancelled) {
        [self.cancellationHandlers addObject:cancelHandler];
    } else {
        cancelHandler();
    }
}

- (void)cancel
{
    if (!self.isCancelled) {
        self.isCancelled = YES;

        for (FFOnTaskCanceled canceled in self.cancellationHandlers) {
            canceled();
        }

        [self.cancellationHandlers removeAllObjects];
    }
}

@end
