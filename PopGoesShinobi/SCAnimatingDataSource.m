//
//  SCAnimatingDataSource.m
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import "SCAnimatingDataSource.h"

@interface SCAnimatingDataSource () <SChartDatasource>

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *datapoints;
@property (nonatomic, weak) ShinobiChart *chart;

@end

@implementation SCAnimatingDataSource

- (instancetype)initWithChart:(ShinobiChart *)chart categories:(NSArray *)categories
{
    self = [super init];
    if(self) {
        self.categories = categories;
        self.chart = chart;
        self.chart.datasource = self;
        NSMutableArray *zeroFillValues = [NSMutableArray arrayWithCapacity:[self.categories count]];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [zeroFillValues addObject:@0];
        }];
        [self animateToValues:zeroFillValues];
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
    NSMutableArray *newDatapoints = [NSMutableArray new];
    [self.categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SChartDataPoint *dp = [SChartDataPoint new];
        dp.xValue = obj;
        dp.yValue = values[idx];
        [newDatapoints addObject:dp];
    }];
    self.datapoints = [newDatapoints copy];
    [self.chart reloadData];
    [self.chart redrawChart];
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
