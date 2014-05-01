//
//  SCAnimatingDataSource.m
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import "SCAnimatingDataSource.h"
#import <POP/POP.h>

@interface SCAnimatingDataSource () <SChartDatasource>

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
        [self initialiseDataPoints];
        
        self.animateableValuesProperty = [POPAnimatableProperty propertyWithName:@"com.shinobicontrols.popgoesshinobi.animatingdatasource" initializer:^(POPMutableAnimatableProperty *prop) {
            // read value
            prop.readBlock = ^(SChartDataPoint *dp, CGFloat values[]) {
                values[0] = [dp.yValue floatValue];
            };
            // write value
            prop.writeBlock = ^(SChartDataPoint *dp, const CGFloat values[]) {
                dp.yValue = @(values[0]);
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
        anim.springBounciness = 10;
        anim.springSpeed = 3;
        
        [dp pop_addAnimation:anim forKey:@"ValueChangeAnimation"];
    }];
}

#pragma mark - Non-public methods
- (void)initialiseDataPoints
{
    NSMutableArray *newDatapoints = [NSMutableArray new];
    [self.categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SChartDataPoint *dp = [SChartDataPoint new];
        dp.xValue = obj;
        dp.yValue = @0;
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
    return [SChartColumnSeries new];
}

- (NSInteger)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(NSInteger)seriesIndex
{
    return [self.datapoints count];
}

- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex forSeriesAtIndex:(NSInteger)seriesIndex
{
    return self.datapoints[dataIndex];
}

@end
