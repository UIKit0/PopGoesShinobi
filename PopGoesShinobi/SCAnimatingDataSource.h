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

- (void)animateToValues:(NSArray *)values;

@end
