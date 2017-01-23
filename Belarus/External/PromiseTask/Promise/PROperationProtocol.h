//
// PROperationProtocol.
//

#import <Foundation/Foundation.h>

@protocol PRTaskProtocol;

@protocol PROperationProtocol <NSObject>

- (id <PRTaskProtocol>)perform;

@end