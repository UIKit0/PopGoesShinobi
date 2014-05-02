//
//  SCAnimatingDataSource.h
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>

@interface SCAnimatingDataSource : NSObject

- (instancetype)initWithChart:(ShinobiChart *)chart categories:(NSArray *)categories;

@property (nonatomic, assign) CGFloat springBounciness;
@property (nonatomic, assign) CGFloat springSpeed;

// To make the data source more generic
@property (nonatomic, assign) Class dataPointType;
@property (nonatomic, assign) Class seriesType;

- (void)animateToValues:(NSArray *)values;

@end
