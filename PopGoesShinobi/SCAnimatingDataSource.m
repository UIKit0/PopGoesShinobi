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
        
        // Default values
        self.springBounciness = 4.0;
        self.springSpeed = 12.0;
        
        // We'll expect a cartesian chart by default
        self.seriesCreatorBlock = ^SChartSeries*() {
            return [SChartColumnSeries new];
        };
        
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
        SChartDataPoint *dp = [SChartDataPoint new];
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
    return self.seriesCreatorBlock();
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
