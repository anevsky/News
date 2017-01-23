//
// AFHTTPRequestOperationManager (Promise).
//

#import <AFNetworking/AFHTTPRequestOperation.h>
#import "AFHTTPRequestOperationManager+Promise.h"
#import "PRBlockOperation.h"
#import "PRPromiseProtocol.h"
#import "AFHTTPRequestOperationManager.h"

@implementation AFHTTPRequestOperationManager (Promise)

- (id <PRTaskProtocol>)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(id)parameters
{
    __weak __block AFHTTPRequestOperation *requestOperation = nil;
    PRBlockOperation *operation = [[PRBlockOperation alloc] initWithTaskBlock:^(id <PRPromiseProtocol> promise)
    {
        void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [promise resolveWithResult:operation andError:nil];
        };

        void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [promise resolveWithResult:operation andError:error];
        };

        if ( [method isEqualToString:@"POST"] ) {
            requestOperation = [self POST:path parameters:parameters success:success failure:failure];
        }
        else if ( [method isEqualToString:@"GET"] ) {
            requestOperation = [self GET:path parameters:parameters success:success failure:failure];
        }
        else if ( [method isEqualToString:@"PUT"] ) {
            requestOperation = [self PUT:path parameters:parameters success:success failure:failure];
        }
        else if ( [method isEqualToString:@"HEAD"] ) {
            requestOperation = [self HEAD:path parameters:parameters success:^(AFHTTPRequestOperation *operation){
                [promise resolveWithResult:operation andError:nil];
            }  failure:failure];

        }
        else {
            NSLog(@"AFHTTPRequestOperationManager (Promise) Error : unsupported method %@", method);
        }

    }];

    id <PRTaskProtocol> upcomingResult = [operation perform];
    [upcomingResult onCancel:^{
        if (requestOperation != nil) {
            [requestOperation cancel];
        }
    }];

    return upcomingResult;
}

- (AFHTTPRequestOperation *)sendDataWithMethod:(NSString *)method
                                          path:(NSString *)path
                                    parameters:(id)parameters
                     constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:method URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self.operationQueue addOperation:operation];

    return operation;
}

@end
