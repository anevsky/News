//
//  MetricaLogger.m
//
//  Created by  Alex Nevsky on 21.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "MetricaLogger.h"
#import <YandexMobileMetrica/YandexMobileMetrica.h>
#import <UIKit/UIDevice.h>

@implementation MetricaLogger

static NSString *currentDeviceName;

+ (void)reportToMetricaEvent:(NSString *)name withParams:(NSDictionary *)params
{
    [YMMYandexMetrica reportEvent:name parameters:params onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

+ (void)reportToMetricaDeviceEventWithParams:(NSDictionary *)params
{
    if (currentDeviceName == nil) {
        currentDeviceName = [[UIDevice currentDevice] name];
    }

    [YMMYandexMetrica reportEvent:currentDeviceName parameters:params onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

@end
