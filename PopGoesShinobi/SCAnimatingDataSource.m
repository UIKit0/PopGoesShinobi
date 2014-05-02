//
//  SCAnimatingDataSource.m
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import "SCAnimatingDataSource.h"
#import <POP/POP.h>

@interface SCAnimatingDataSource () <SChartDatasource, SChartDelegate>

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *datapoints;
@property (nonatomic, weak) ShinobiChart *chart;
@property (nonatomic, strong) POPAnimatableProperty *animateableValuesProperty;

@end

@implementation SCAnimatingDataSource

- (instancetype)initWithChart:(ShinobiChart *)chart categories:(NSArray *)categories
{
    self = [super init];
    if(self) {
        self.categories = categories;
        self.chart = chart;
        self.chart.datasource = self;
        self.chart.delegate = self;
        // Default values
        self.springBounciness = 4.0;
        self.springSpeed = 12.0;
        
        // We'll expect a cartesian chart by default
        self.seriesType = [SChartColumnSeries class];
        self.dataPointType = [SChartDataPoint class];
        
        [self initialiseDataPoints];
        
        self.animateableValuesProperty = [POPAnimatableProperty propertyWithName:@"com.shinobicontrols.popgoesshinobi.animatingdatasource" initializer:^(POPMutableAnimatableProperty *prop) {
            // read value
            prop.readBlock = ^(SChartDataPoint *dp, CGFloat values[]) {
                values[0] = [dp.yValue floatValue];
            };
            // write value
            prop.writeBlock = ^(SChartDataPoint *dp, const CGFloat values[]) {
                dp.yValue = @(MAX(values[0], 0));
                [self.chart reloadData];
                [self.chart redrawChart];
            };
            // dynamics threshold
            prop.threshold = 0.01;
        }];
    }
    return self;
}

- (void)animateToValues:(NSArray *)values
{
    if([values count] != [self.categories count]) {
        NSException *ex = [NSException exceptionWithName:NSInvalidArgumentException
                                                  reason:@"The values array must be of the same size as the categories"
                                                userInfo:nil];
        @throw ex;
    }
    
    [self.datapoints enumerateObjectsUsingBlock:^(SChartDataPoint *dp, NSUInteger idx, BOOL *stop) {
        POPSpringAnimation *anim = [POPSpringAnimation animation];
        anim.property = self.animateableValuesProperty;
        anim.fromValue = dp.yValue;
        anim.toValue = values[idx];
        anim.springBounciness = self.springBounciness;
        anim.springSpeed = self.springSpeed;
        
        [dp pop_addAnimation:anim forKey:@"ValueChangeAnimation"];
    }];
}

#pragma mark - Non-public methods
- (void)initialiseDataPoints
{
    NSMutableArray *newDatapoints = [NSMutableArray new];
    [self.categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SChartDataPoint *dp = [self.dataPointType new];
        dp.xValue = obj;
        dp.yValue = @1;
        [newDatapoints addObject:dp];
    }];
    self.datapoints = [newDatapoints copy];
}

#pragma mark - SChartDataSource methods
- (NSInteger)numberOfSeriesInSChart:(ShinobiChart *)chart
{
    return 1;
}

- (SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(NSInteger)index
{
    return [self.seriesType new];
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    return [self.datapoints count];
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    return self.datapoints[dataIndex];
}

#pragma mark - SChartDelegate methods
- (void)sChart:(ShinobiChart *)chart alterLabel:(UILabel *)label forDatapoint:(SChartRadialDataPoint *)datapoint atSliceIndex:(NSInteger)index inRadialSeries:(SChartRadialSeries *)series
{
    label.text = datapoint.name;
}

@end
