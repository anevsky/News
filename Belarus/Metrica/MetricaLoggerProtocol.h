//
//  MetricaLoggerProtocol.h
//
//  Created by  Alex Nevsky on 21.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MetricaLoggerProtocol <NSObject>

+ (void)reportToMetricaEvent:(NSString *)name withParams:(NSDictionary *)params;
+ (void)reportToMetricaDeviceEventWithParams:(NSDictionary *)params;

@end
