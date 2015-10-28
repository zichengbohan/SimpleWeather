//
//  WXCondition.h
//  SimpleWeather
//
//  Created by xbm on 15/10/13.
//  Copyright © 2015年 xbm. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface WXCondition : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSNumber *humidity;

@property (nonatomic, strong) NSNumber *temperature;

@property (nonatomic, strong) NSNumber *tempHigh;

@property (nonatomic, strong) NSNumber *tempLow;

@property (nonatomic, copy) NSString *locationName;

@property (nonatomic, strong) NSDate *sunrise;

@property (nonatomic, strong) NSDate *sunset;

@property (nonatomic, copy) NSString *conditionDescription;

@property (nonatomic, copy) NSString *condition;

@property (nonatomic, strong) NSNumber *windBearing;

@property (nonatomic, strong) NSNumber *windSpeed;

@property (nonatomic, strong) NSString *icon;

- (NSString *)imageName;

@end
