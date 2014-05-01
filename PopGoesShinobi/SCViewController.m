//
//  SCViewController.m
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import "SCViewController.h"
#import "SCAnimatingDataSource.h"

@interface SCViewController ()

@property (nonatomic, strong) SCAnimatingDataSource *datasource;

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.chart.licenseKey = @"";
    
    NSArray *categories = @[@"Q1", @"Q2", @"Q3", @"Q4"];
    self.datasource = [[SCAnimatingDataSource alloc] initWithChart:self.chart
                                                        categories:categories];
    
    SChartAxis *xAxis = [SChartCategoryAxis new];
    xAxis.title = @"Quarter";
    self.chart.xAxis = xAxis;
    SChartAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:[[SChartNumberRange alloc] initWithMinimum:@0 andMaximum:@200]];
    yAxis.title = @"Sales";
    self.chart.yAxis = yAxis;
    
    NSArray *values = @[@120, @140, @100, @180];
    [self.datasource animateToValues:values];
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
