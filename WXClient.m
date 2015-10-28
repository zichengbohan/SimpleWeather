//
//  WXClient.m
//  SimpleWeather
//
//  Created by xbm on 15/10/13.
//  Copyright © 2015年 xbm. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient ()

@property (nonatomic, strong) NSURLSession *seession;

@end

@implementation WXClient

- (id)init {
	if (self = [super init]) {
		NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
		_seession = [NSURLSession sessionWithConfiguration:config];
	}
	
	return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
	NSLog(@"Fetching: %@", url.absoluteString);
	
	return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		NSURLSessionDataTask *dataTask = [self.seession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
			if (!error) {
				NSError *jsonError = nil;
				id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&json];
				if (! jsonError) {
					[subscriber sendNext:json];
				} else {
					[subscriber sendError:jsonError];
				}
			} else {
				[subscriber sendError:error];
			}
			
			[subscriber sendCompleted];
			
			}];
		[dataTask resume];
		return [RACDisposable disposableWithBlock:^{
			[dataTask cancel];
		}];
		}] doError:^(NSError *error) {
			NSLog(@"Error:%@",error);
		}];
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coodinate {
	NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=64785f20a1b7d0ddd654fd380a04fd86", coodinate.latitude, coodinate.longitude];
	NSURL *url = [NSURL URLWithString:urlString];
	
	return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
		return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
	}];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
	NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&APPID=64785f20a1b7d0ddd654fd380a04fd86", coordinate.latitude, coordinate.longitude];
	NSURL *url = [NSURL URLWithString:urlString];
	
	return [[self fetchJSONFromURL:url] map:^id(NSDictionary *json) {
		RACSequence *list = [json[@"list"] rac_sequence];
		return [[list map:^id(NSDictionary *item) {
			return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
		}] array];
	}];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
	NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&APPID=64785f20a1b7d0ddd654fd380a04fd86", coordinate.latitude, coordinate.longitude];
	NSURL *url = [NSURL URLWithString:urlString];
	return [[self fetchJSONFromURL:url] map:^id(NSDictionary *json) {
		RACSequence *list = [json[@"list"] rac_sequence];
		
		return [[list map:^id(NSDictionary *item) {
			return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
		}] array];
	}];
	
}

@end
