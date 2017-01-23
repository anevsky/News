//
// PRInstantTask.
//

#import <Foundation/Foundation.h>
#import "PRTaskProtocol.h"

@interface PRInstantTask : NSObject <PRTaskProtocol>

- (instancetype)initWithResult:(id)result;
- (instancetype)initWithError:(id)error;

@end