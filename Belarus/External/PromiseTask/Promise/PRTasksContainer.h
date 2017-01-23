//
// PRTasksContainer.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PRTaskProtocol;

@interface PRTasksContainer : NSObject

- (void)addTask:(id <PRTaskProtocol>)task;
- (void)cancelRunningTasks;

@property (nonatomic, assign) BOOL cancelsAllTaskOnDestroy;

@end