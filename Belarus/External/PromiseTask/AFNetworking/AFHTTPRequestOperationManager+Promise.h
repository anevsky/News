//
// AFHTTPRequestOperationManager (Promise).
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@protocol PRTaskProtocol;

@interface AFHTTPRequestOperationManager (Promise)

- (id <PRTaskProtocol>)requestWithMethod:(NSString *)method
                                         path:(NSString *)path
                                   parameters:(id)parameters;

- (AFHTTPRequestOperation *)sendDataWithMethod:(NSString *)URLString
                                          path:(NSString *)path
                                    parameters:(id)parameters
                     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
