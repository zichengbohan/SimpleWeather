//
//  ViewController.m
//  SimpleWeather
//
//  Created by xbm on 15/10/10.
//  Copyright © 2015年 xbm. All rights reserved.
//

#import "ViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WXManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation ViewController

- (id)init {
	if (self = [super init]) {
		_hourlyFormatter = [[NSDateFormatter alloc] init];
		_hourlyFormatter.dateFormat = @"h a";
		
		_dailyFormatter = [[NSDateFormatter alloc] init];
		_dailyFormatter.dateFormat= @"EEE";
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_hourlyFormatter = [[NSDateFormatter alloc] init];
	_hourlyFormatter.dateFormat = @"a h时";
	
	_dailyFormatter = [[NSDateFormatter alloc] init];
	_dailyFormatter.dateFormat= @"EEE";
	
	self.screenHeight = [UIScreen mainScreen].bounds.size.height;
	
	UIImage *backgroundImage = [UIImage imageNamed:@"bg"];
	
	self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
	self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
	[self.view addSubview:self.backgroundImageView];
	
	
	self.blurredImageView = [[UIImageView alloc] init];
	self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.blurredImageView.alpha = 0;
	[self.blurredImageView setImageToBlur:backgroundImage blurRadius:10 completionBlock:nil];
	[self.view addSubview:self.blurredImageView];
	
	self.tableView = [[UITableView alloc] init];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
	self.tableView.pagingEnabled = YES;
	[self.view addSubview:self.tableView];
	
	CGRect headerFrame = [UIScreen mainScreen].bounds;
	
	CGFloat inset = 20;
	
	CGFloat temperatureHeight = 110;
	CGFloat hiloHeight = 40;
	CGFloat iconHeight = 30;
	
	CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height-hiloHeight, headerFrame.size.width- (2 * inset), hiloHeight);
	
	CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height- (temperatureHeight + hiloHeight), headerFrame.size.width - (2 * inset), temperatureHeight);
	
	CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
	
	CGRect conditonFrame = iconFrame;
	conditonFrame.size.width = self.view.bounds.size.width - ((2 * inset) + 10);
	conditonFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
	
	UIView *header = [[UIView alloc] initWithFrame:headerFrame];
	header.backgroundColor = [UIColor clearColor];
	self.tableView.tableHeaderView = header;
	
	UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
	temperatureLabel.backgroundColor = [UIColor clearColor];
	temperatureLabel.textColor = [UIColor whiteColor];
	temperatureLabel.text = @"0°";
	temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
	[header addSubview:temperatureLabel];
	
	UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
	hiloLabel.backgroundColor = [UIColor clearColor];
	hiloLabel.textColor = [UIColor whiteColor];
	hiloLabel.text = @"0° / 0°";
	hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
	[header addSubview:hiloLabel];
	
	UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
	cityLabel.backgroundColor = [UIColor clearColor];
	cityLabel.textColor = [UIColor whiteColor];
	cityLabel.text = @"Loading...";
	cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
	cityLabel.textAlignment = NSTextAlignmentCenter;
	[header addSubview:cityLabel];
	
	UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditonFrame];
	conditionsLabel.backgroundColor = [UIColor clearColor];
	conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
	conditionsLabel.textColor = [UIColor whiteColor];
	conditionsLabel.text = @"Clear";
	[header addSubview:conditionsLabel];
	
	UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
	iconView.image = [UIImage imageNamed:@"weather-clear"];
	iconView.contentMode = UIViewContentModeScaleAspectFit;
	iconView.backgroundColor = [UIColor clearColor];
	[header addSubview:iconView];
	
	[[RACObserve([WXManager shareManager], currentCondition)
	 deliverOn:RACScheduler.mainThreadScheduler]
	 subscribeNext:^(WXCondition *newCondition) {
		 //5（F-32）/9
		 temperatureLabel.text = [NSString stringWithFormat:@"%.0f", newCondition.temperature.floatValue ];
		 conditionsLabel.text = [newCondition.condition capitalizedString];
		 cityLabel.text = [newCondition.locationName capitalizedString];
		 
		 iconView.image = [UIImage imageNamed:[newCondition imageName]];
	 }];
	
	RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
													RACObserve([WXManager shareManager], currentCondition.tempHigh),
													RACObserve([WXManager shareManager], currentCondition.tempLow)
													]
													reduce:^id(NSNumber *hi, NSNumber *low){
														return [NSString stringWithFormat:@"%.0f℃/%.0f℃", hi.floatValue, low.floatValue];
													}]
													deliverOn:RACScheduler.mainThreadScheduler];
	[[RACObserve([WXManager shareManager], hourlyForecast)
	 deliverOn:RACScheduler.mainThreadScheduler]
	subscribeNext:^(NSArray *newForcast) {
		[self.tableView reloadData];
	}];
	[[RACObserve([WXManager shareManager], dailyForecast)
	 deliverOn:RACScheduler.mainThreadScheduler]
	subscribeNext:^(id x) {
		[self.tableView reloadData];
	}];
	
	[[WXManager shareManager] findCurrentLocation];
	
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	CGRect bounds = self.view.bounds;
	
	self.backgroundImageView.frame = bounds;
	self.blurredImageView.frame = bounds;
	self.tableView.frame = bounds;
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
}

#pragma mark - UItableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return MIN([[WXManager shareManager].hourlyForecast count], 6) + 1;
	}
	//TODO: return count of forecast
	return MIN([WXManager shareManager].dailyForecast.count, 6) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"CellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.textColor = [UIColor whiteColor];
	
	//TODO: setup the cell
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			[self configureHeaderCell:cell title:@"时报"];
		} else {
			WXCondition *weather = [WXManager shareManager].hourlyForecast[indexPath.row];
			[self configureHourlyCell:cell weather:weather];
		}
	} else if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			[self configureHeaderCell:cell title:@"每日天气"];
		} else {
			WXCondition *weather = [WXManager shareManager].dailyForecast[indexPath.row];
			[self configureDailyCell:cell weather:weather];
		}
	}
	
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
	return self.screenHeight / (CGFloat)cellCount;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat height = scrollView.bounds.size.height;
	CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
	
	CGFloat percent = MIN(position / height, 1.0);
	
	self.blurredImageView.alpha = percent;
}


- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
	cell.textLabel.text = title;
	cell.detailTextLabel.text = @"";
	cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
	cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
	NSString *date =[self.hourlyFormatter stringFromDate:weather.date];
	cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", weather.temperature.floatValue];
	cell.imageView.image = [UIImage imageNamed:weather.imageName];
	cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
	cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
	cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f / %.0f", weather.tempHigh.floatValue , weather.tempLow
															 .floatValue];
	cell.imageView.image = [UIImage imageNamed:weather.imageName];
	cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
