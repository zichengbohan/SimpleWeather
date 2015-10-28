//
//  WXClient.h
//  SimpleWeather
//
//  Created by xbm on 15/10/13.
//  Copyright © 2015年 xbm. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface WXClient : NSObject

- (RACSignal *)fetchJSONFromURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coodinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
