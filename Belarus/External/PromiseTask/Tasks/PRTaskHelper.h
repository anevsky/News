//
// PRTaskProtocol.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PRTaskProtocol;

@interface PRTaskHelper : NSObject

// will wrap task, so task result task cancellation will not result in task cancellation
+ (id <PRTaskProtocol>)wrapTask:(id <PRTaskProtocol>)task;

// will create pass through task with default cancellation behavior
+ (id <PRTaskProtocol>)createAuxiliaryTaskTaskForTask:(id <PRTaskProtocol>)task;

@end