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
@property (nonatomic, assign) CGFloat springBounciness;
@property (nonatomic, assign) CGFloat springSpeed;

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
    
    self.yearlyData = @[@[@120, @140, @50,  @120],
                        @[@10,  @60,  @110, @40],
                        @[@150, @120, @160, @100]];
    
    self.springSpeed = 12.0;
    self.springBounciness = 4.0;
    
    // Render the first chart
    self.chartTypeSegmented.selectedSegmentIndex = 0;
    [self handleChartTypeSelected:self.chartTypeSegmented];
    
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
    self.springSpeed = self.speedSlider.value;
    self.springBounciness = self.bounceSlider.value;
}
- (IBAction)handleChartTypeSelected:(id)sender {
    if(self.chartTypeSegmented.selectedSegmentIndex == 0) {
        self.datasource.seriesType = [SChartPieSeries class];
        self.datasource.dataPointType = [SChartRadialDataPoint class];
        [self setSlidersAsHidden:YES];
    } else {
        self.datasource.seriesType = [SChartColumnSeries class];
        self.datasource.dataPointType = [SChartDataPoint class];
        [self setSlidersAsHidden:NO];
    }
    [self updateAnimationCreationBlock];
    [self.chart reloadData];
    [self.chart redrawChart];
}

- (void)updateAnimationCreationBlock
{
    if(self.chartTypeSegmented.selectedSegmentIndex == 0) {
        self.datasource.animationCreationBlock = ^POPPropertyAnimation*(void) {
            POPBasicAnimation *anim = [POPBasicAnimation easeInEaseOutAnimation];
            return anim;
        };
    } else {
        // We capture a weak version of ourself, which means that we can get hold of updates to anim properties
        __weak typeof(self) weakSelf = self;
        self.datasource.animationCreationBlock = ^POPPropertyAnimation*(void) {
            POPSpringAnimation *anim = [POPSpringAnimation animation];
            anim.springBounciness = weakSelf.springBounciness;
            anim.springSpeed = weakSelf.springSpeed;
            return anim;
        };
    }
}

- (void)setSlidersAsHidden:(BOOL)hidden
{
    [self.animationControls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setHidden:hidden];
    }];
}
@end
