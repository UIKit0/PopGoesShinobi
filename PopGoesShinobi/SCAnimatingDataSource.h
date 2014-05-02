//
//  SCAnimatingDataSource.h
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiChart.h>
#import <POP/POP.h>

@interface SCAnimatingDataSource : NSObject

- (instancetype)initWithChart:(ShinobiChart *)chart categories:(NSArray *)categories;

// To make the data source more generic
@property (nonatomic, assign) Class dataPointType;
@property (nonatomic, assign) Class seriesType;
@property (nonatomic, copy) POPPropertyAnimation* (^animationCreationBlock)(void);

- (void)animateToValues:(NSArray *)values;

@end
