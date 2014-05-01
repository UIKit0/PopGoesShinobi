//
//  SCViewController.h
//  PopGoesShinobi
//
//  Created by Sam Davies on 01/05/2014.
//  Copyright (c) 2014 Shinobi Controls. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShinobiCharts/ShinobiChart.h>

@interface SCViewController : UIViewController

@property (weak, nonatomic) IBOutlet ShinobiChart *chart;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yearSelectorSegmented;
- (IBAction)handleYearSelected:(id)sender;

@end
