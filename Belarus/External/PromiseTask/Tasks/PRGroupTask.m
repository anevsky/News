//
// PRGroupTask.
//

#import "PRGroupTask.h"
#import "PRBlockOperation.h"
#import "PRTaskHelper.h"

@interface PRGroupTask ()

@property (nonatomic, assign) BOOL resultAsList;

@property (nonatomic, strong) NSDictionary *tasksMap;
@property (nonatomic, strong) NSMutableOrderedSet *completionHandlers;
@property (nonatomic, strong) NSMutableOrderedSet *cancelHandlers;
@property (nonatomic, strong) NSMutableDictionary *tasksResultMap;

@property (nonatomic, strong) id result;
@property (nonatomic, strong) id error;

@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) BOOL isCanceled;

@end

@implementation PRGroupTask
{

}

- (instancetype)initWithTasks:(NSArray *)tasks
{
    self = [self init];
    if ( self ) {
        self.tasksMap = [self tasksListToTasksMap:tasks];
        self.resultAsList = YES;

        [self setup];
    }

    return self;
}

- (instancetype)initWithTasksMap:(NSDictionary *)tasksMap
{
    self = [self init];
    if ( self ) {
        self.tasksMap = tasksMap;

        [self setup];
    }

    return self;
}

- (NSDictionary *)tasksListToTasksMap:(NSArray *)tasksList
{
    NSMutableDictionary *tasksMap = [NSMutableDictionary dictionaryWithCapacity:tasksList.count];
    for (NSUInteger i = 0; i < tasksList.count; i++) {
        tasksMap[@(i)] = tasksList[i];
    }

    return tasksMap;
}

- (void)setup
{
    self.tasksResultMap = [NSMutableDictionary dictionaryWithCapacity:self.tasksList.count];
    self.result = nil;

    self.isCanceled = NO;
    self.isComplete = NO;

    self.completionHandlers = [NSMutableOrderedSet orderedSetWithCapacity:2];
    self.cancelHandlers = [NSMutableOrderedSet orderedSetWithCapacity:2];

    for (id <NSObject, NSCopying> key in self.tasksMap ) {
        id <PRTaskProtocol> task = self.tasksMap[key];
        [task onComplete:^(id result, id error) {
            result = result != nil ? result : NSNull.null;

            if (error != nil) {
                self.error = error;
                self.result = nil;

                [self finish];
            } else {
                self.tasksResultMap[key] = result ?: NSNull.null;

                if (self.tasksResultMap.count == self.tasksList.count) {
                    [self finish];
                }
            }

        }];

        [task onCancel:^{
            [self cancel];
        }];
    }
}

- (void)onComplete:(FFOnTaskComplete)completionHandler
{
    if ( !self.isComplete && !self.isCanceled ) {
        [self.completionHandlers addObject:completionHandler];
    } else if (self.isComplete && !self.isCanceled){
        completionHandler(self.result, self.error);
    }
}

- (void)onCancel:(FFOnTaskCanceled)cancelHandler
{
    if ( !self.isComplete && !self.isCanceled ) {
        [self.cancelHandlers addObject:cancelHandler];
    } else if (self.isCanceled){
        cancelHandler();
    }
}

- (void)finish
{
    if (self.isComplete || self.isCanceled) {
        return;
    }

    if (self.error == nil) {
        self.result = [self buildResultFromResultsMap:self.tasksResultMap];
    }

    [self.completionHandlers enumerateObjectsUsingBlock:^(FFOnTaskComplete handler, NSUInteger idx, BOOL *stop) {
        handler(self.result, self.error);
    }];

    self.tasksMap = nil;
    self.tasksResultMap = nil;

    [self.completionHandlers removeAllObjects];
    [self.cancelHandlers removeAllObjects];
}

- (id)buildResultFromResultsMap:(NSDictionary *)resultsMap
{
    id result = nil;
    if (self.resultAsList) {
        NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:resultsMap.count];

        NSArray *keys = [resultsMap.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *first, NSNumber *second) {
            return [first compare:second];
        }];

        for ( NSString *key in keys ) {
            id value = resultsMap[key];
            [resultList addObject:value];
        }

        result = resultList;
    } else {
        result = resultsMap;
    }

    return result;
}

- (void)cancel
{
    if (self.isCanceled || self.isComplete) {
        return;
    }

    self.isCanceled = YES;

    for (id <PRTaskProtocol> task in self.tasksList ) {
        [task cancel];
    }

    for (FFOnTaskCanceled handler in self.cancelHandlers) {
        handler();
    }

    [self.completionHandlers removeAllObjects];
    [self.cancelHandlers removeAllObjects];

}

- (NSArray *)tasksList
{
    return self.tasksMap.allValues;
}


- (id <PRTaskProtocol>)then:(FFThenBlock)thenBlock
{
    id <PRTaskProtocol> auxiliaryTask = [self createAuxiliaryTask];
    return [auxiliaryTask then:thenBlock];
}

- (id <PRTaskProtocol>)catch:(FFCatchBlock)catchBlock
{
    id <PRTaskProtocol> auxiliaryTask = [self createAuxiliaryTask];
    return [auxiliaryTask catch:catchBlock];
}

- (id <PRTaskProtocol>)createAuxiliaryTask
{
    return [PRTaskHelper createAuxiliaryTaskTaskForTask:self];
}


@end