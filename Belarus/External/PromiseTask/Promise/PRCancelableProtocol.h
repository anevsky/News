//
// PRCancelableProtocol.
//

#import <Foundation/Foundation.h>

@protocol PRCancelableProtocol <NSObject>

- (void)cancel;

@property (nonatomic, assign, readonly) BOOL isCanceled;

@end