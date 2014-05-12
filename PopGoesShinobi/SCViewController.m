/*
 *  Copyright 2014 Scott Logic Ltd
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

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
    
    SChartAxis *xAxis = [SChartCategoryAxis new];
    self.chart.xAxis = xAxis;
    SChartAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:[[SChartNumberRange alloc] initWithMinimum:@0 andMaximum:@200]];
    yAxis.title = @"Sales";
    self.chart.yAxis = yAxis;
    
    self.chart.legend.placement = SChartLegendPlacementInsidePlotArea;
    self.chart.legend.position = SChartLegendPositionMiddleRight;
    
    self.yearlyData = @[@[@120, @140, @50,  @120],
                        @[@10,  @60,  @110, @40],
                        @[@150, @120, @160, @100]];
    
    // Render the first year available
    self.yearSelectorSegmented.selectedSegmentIndex = 0;
    [self handleYearSelected:self.yearSelectorSegmented];
    // Render the first chart
    self.chartTypeSegmented.selectedSegmentIndex = 0;
    [self handleChartTypeSelected:self.chartTypeSegmented];
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
- (IBAction)handleChartTypeSelected:(id)sender {
    if(self.chartTypeSegmented.selectedSegmentIndex == 0) {
        self.datasource.seriesCreatorBlock = ^SChartSeries*() {
            SChartPieSeries *pieSeries = [SChartPieSeries new];
            pieSeries.style.showLabels = NO;
            return pieSeries;
        };
        self.chart.legend.hidden = NO;
    } else {
        self.datasource.seriesCreatorBlock = ^SChartSeries*() {
            return [SChartColumnSeries new];
        };
        self.chart.legend.hidden = YES;
    }
    [self.chart reloadData];
    [self.chart redrawChart];
}
@end
