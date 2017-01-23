//
// PRTasksContainer.
//

#import "PRTasksContainer.h"
#import "PRTaskProtocol.h"

@interface PRTasksContainer ()

@property (nonatomic, strong) NSMutableSet *runningTasks;

@end

@implementation PRTasksContainer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cancelsAllTaskOnDestroy = YES;
        self.runningTasks = [NSMutableSet setWithCapacity:10];
    }

    return self;
}

- (void)addTask:(id <PRTaskProtocol>)task
{
    [self.runningTasks addObject:task];
    __weak typeof(task) weakTask = task;
    __weak PRTasksContainer *weakSelf = self;
    [task onCancel:^{
        if (weakSelf != nil) {
            [weakSelf.runningTasks removeObject:weakTask];
        }
    }];

    [task onComplete:^(id result, id error) {
        if (weakSelf != nil) {
            [weakSelf.runningTasks removeObject:weakTask];
        }
    }];
}

- (void)cancelRunningTasks
{
    NSSet *tasksToCancel = [self.runningTasks copy];
    for (id <PRTaskProtocol> task in tasksToCancel) {
        [task cancel];
    }
}

- (void)dealloc
{
    if (self.cancelsAllTaskOnDestroy) {
        [self cancelRunningTasks];
    }
}

@end