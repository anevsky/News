//
// PRGroupTask.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PRTaskProtocol.h"

@interface PRGroupTask : NSObject <PRTaskProtocol>

- (instancetype)initWithTasks:(NSArray *)tasks;
- (instancetype)initWithTasksMap:(NSDictionary *)tasksMap;


@end