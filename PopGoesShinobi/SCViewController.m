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
@property (nonatomic, strong) NSArray *yearlyData;

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
    self.datasource.seriesType = [SChartPieSeries class];
    self.datasource.dataPointType = [SChartRadialDataPoint class];
    
    SChartAxis *xAxis = [SChartCategoryAxis new];
    self.chart.xAxis = xAxis;
    SChartAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:[[SChartNumberRange alloc] initWithMinimum:@0 andMaximum:@200]];
    yAxis.title = @"Sales";
    self.chart.yAxis = yAxis;
    
    self.yearlyData = @[@[@120, @140, @50,  @120],
                        @[@10,  @60,  @110, @40],
                        @[@150, @120, @160, @200]];
    
    // Render the first year available
    self.yearSelectorSegmented.selectedSegmentIndex = 0;
    [self handleYearSelected:self.yearSelectorSegmented];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - UI Handlers
- (IBAction)handleYearSelected:(id)sender {
    NSArray *values = self.yearlyData[self.yearSelectorSegmented.selectedSegmentIndex];
    [self.datasource animateToValues:values];
}

- (IBAction)handleSliderValueChanged:(id)sender {
    self.datasource.springSpeed = self.speedSlider.value;
    self.datasource.springBounciness = self.bounceSlider.value;
}
@end
