//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by xbm on 15/10/13.
//  Copyright © 2015年 xbm. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
	
	paths[@"tempHigh"] = @"temp.max";
	paths[@"tempLow"] = @"temp.min";
	
	return paths;
}

@end
