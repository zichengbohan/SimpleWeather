//
//  WXManager.h
//  SimpleWeather
//
//  Created by xbm on 15/10/13.
//  Copyright © 2015年 xbm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "WXCondition.h"

@interface WXManager : NSObject<CLLocationManagerDelegate>

+ (instancetype)shareManager;

@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

- (void)findCurrentLocation;

@end
