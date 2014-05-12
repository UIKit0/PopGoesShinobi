# Animating ShinobiCharts with Facebook's Pop Library

## Introduction

One of the things in the app design toolkit which can really enhance the user
experience is animation. Used carefully animations can enhance usability, convey
information and delight your users. ShinobiCharts currently support entry and
exit animations - that is when a chart is drawn for the first time or is
redrawn, the data points will animate into position. However, it's not
currently possible to animate from one data set to another.

Facebook has recently been open-sourcing a lot of the frameworks they created
to create the Paper app. There is a lot of good stuff there - I encourage you
to take a look through their github profile
[github.com/facebook](https://github.com/facebook). One of the more recent
additions was [pop](https://github.com/facebook/pop) - an extensible animation
engine for iOS and OSX. Unlike CoreAnimation or UIKit Dynamics, it's possible
to use pop to animate anything you like - via the use of custom animatable
properties.

I decided that it would be interesting to try and use pop to animate between
data values on a ShinobiChart. Not only was the process pretty painless - the
end result is really quite impressive. In this post I'm going to outline the
technique, so you too can animate between datasets. I'll assume that you are
familiar with ShinobiCharts, including the concepts associated with the
different chart types and the data source protocol. If you are unsure about
this you should go and take a look at the excellent
[user guide](http://www.shinobicontrols.com/docs/ShinobiControls/ShinobiCharts/2.6.0/Premium/Normal/user_guide.html) -
it's full of info to take you from a novice to a ninja in no time.

## Datasource design

I want to animate some quarterly sales figures between different years:

|    | 2012 | 2013 | 2014 |
|----|------|------|------|
| Q1 | 120  | 10   | 150  |
| Q2 | 140  | 60   | 120  |
| Q3 | 50   | 110  | 160  |
| Q4 | 120  | 40   | 100  |

The important point here is that the number of data points remains constant (4)
- we're only going to consider the case when data points change value - not
appear and disappear, although that is a potential extension. The data is
categorical (with names `Q1`, `Q2`, `Q3`, `Q4`), and these categories remain
constant as the data changes. Therefore we'll create a data source in which
you have to provide the category names up-front, and then you can provide new
values to which to animate the data points to. The interface looks like this:

    @interface SCAnimatingDataSource : NSObject

    - (instancetype)initWithChart:(ShinobiChart *)chart categories:(NSArray *)categories;

    // To make the data source more generic
    @property (nonatomic, copy) SChartSeries* (^seriesCreatorBlock)(void);

    - (void)animateToValues:(NSArray *)values;

    @end

In addition to the constructor and the value animation method, there is also a
block property which will allow the same datasource to be used for different
chart types. This block will be used to generate the correct `SChartSeries`
object for the current chart e.g. pie or column chart.

For now, let's ignore the animation - and ensure that the datasource will
update the values on the chart when they are passed to the `animateToValues:`
method.

Add a class extension to store some private properties:

    @interface SCAnimatingDataSource () <SChartDatasource>

    @property (nonatomic, strong) NSArray *categories;
    @property (nonatomic, strong) NSArray *datapoints;
    @property (nonatomic, weak) ShinobiChart *chart;

    @end

The constructor is pretty simple:

    - (instancetype)initWithChart:(ShinobiChart *)chart categories:(NSArray *)categories
    {
        self = [super init];
        if(self) {
            self.categories = categories;
            self.chart = chart;
            self.chart.datasource = self;

            // We'll expect a cartesian chart by default
            self.seriesCreatorBlock = ^SChartSeries*() {
                return [SChartColumnSeries new];
            };

            [self initialiseDataPoints];
        }
        return self;
    }

Notice here that we're setting the chart's datasource to ourself, saving off
the arguments and setting some defaults. The `initialiseDataPoints` method is
a utility method which creates the required data points and provides them with
some initial data:

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

Since this class is adopting the `SChartDatasource` protocol there are 4 required
methods to implement:

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

    - (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(NSInteger)dataIndex
                                                   forSeriesAtIndex:(NSInteger)seriesIndex
    {
        return self.datapoints[dataIndex];
    }

This is all pretty standard for a ShinobiChart data source - notice that we're
using the `seriesCreatorBlock()` to create the `SChartSeries` object we need,
and that we're just returning the `SChartDataPoint` objects from the `datapoints`
array.

The last piece of the puzzle with this data source is the `animateToValues:`
method. When we created the data source we created the correct number of data
points and implemented all the required methods, but we haven't actually provided
and plot data. Create the following method implementation:

    - (void)animateToValues:(NSArray *)values
    {
        if([values count] != [self.categories count]) {
            NSException *ex = [NSException exceptionWithName:NSInvalidArgumentException
                                                      reason:@"The values array must be of the same size as the categories"
                                                    userInfo:nil];
            @throw ex;
        }

        [self.datapoints enumerateObjectsUsingBlock:^(SChartDataPoint *dp, NSUInteger idx, BOOL *stop) {
            sp.yValue = values[idx];
        }];

        [self.chart reloadData];
        [self.chart redrawChart];
    }

Firstly we're checking that we have been provided the correct number of values.
We expect the argument to be an `NSArray` containing `NSNumber` objects. Since
we decided before that this datasource will not allow the number of data points
to change then if the sizes differ we're throwing an exception.

Then we go through the data point array and update their `yValue` property so
that it represents the provided value.

Finally, since we've replaced the data, the chart reloads its data with `reloadData`
and redraws `redrawChart`.

That completes the first pass at the (non-)animating data source - we should
probably work out how to use it.


## Using the datasource

We're not going to go into great detail in how to set up your view controller to
display a chart. If you download the __PopGoesShinobi__ project you'll see that
there is a storyboard which contains a `ShinobiChart`, and a couple of segmented
controls (one to select the year, the other the chart type). We'll only take a
look at the salient parts of __SCViewController.m__ - take a look at the sample
project if you wish to find out more.

    - (void)viewDidLoad
    {
        [super viewDidLoad];
    	// Do any additional setup after loading the view, typically from a nib.

        self.chart.licenseKey = @"<Trial Key Here>";

        // 1.
        NSArray *categories = @[@"Q1", @"Q2", @"Q3", @"Q4"];
        self.yearlyData = @[@[@120, @140, @50,  @120],
                            @[@10,  @60,  @110, @40],
                            @[@150, @120, @160, @100]];

        // 2.
        self.datasource = [[SCAnimatingDataSource alloc] initWithChart:self.chart
                                                            categories:categories];

        // 3.
        SChartAxis *xAxis = [SChartCategoryAxis new];
        self.chart.xAxis = xAxis;
        SChartAxis *yAxis = [[SChartNumberAxis alloc] initWithRange:[[SChartNumberRange alloc] initWithMinimum:@0 andMaximum:@200]];
        yAxis.title = @"Sales";
        self.chart.yAxis = yAxis;

        // 4.
        // Render the first year available
        self.yearSelectorSegmented.selectedSegmentIndex = 0;
        [self handleYearSelected:self.yearSelectorSegmented];

        // 5.
        // Render the first chart
        self.chartTypeSegmented.selectedSegmentIndex = 0;
        [self handleChartTypeSelected:self.chartTypeSegmented];
    }

1. The data to be displayed: a list of category names and the data for each year.
2. Create the data source object - passing in the categories and the chart.
3. Create the axes - we need a category axis and a number axis. Assign them to
the chart.
4. Setup the year selector segment control, and call the handler method to ensure
the datasource has been provided the relevant data.
5. Setup the chart type selector, and call the handler to ensure setup is complete.

There are 2 methods here which need a little more explanation - namely the handlers
for the segmented control changes. Firstly the year selector:

    - (IBAction)handleYearSelected:(id)sender {
        NSArray *values = self.yearlyData[self.yearSelectorSegmented.selectedSegmentIndex];
        [self.datasource animateToValues:values];
    }

This method is really simple - firstly it grabs the correct data from the pre-filled
array store, and then asks the data source to animate to the new values.

The chart type selector is a little more complicated, but not much so:

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

Changing a chart type is as simple as updating the block which is used to create
the series. A pie series requires a bit of additional setup to prevent the
data labels from showing, whereas the column series is just a vanilla object.
Once the datasource has been updated then we `reloadData` and `redrawChart` to
see the effects in practice.

If you run the app up now, then you'll see a pretty cool app, which allows you
to jump between different years of data, and display that data on 2 differnt
chart types. However, you'll notice that when you change year, the data points
just snap to their new value. This blog post was sold as being about animating
this change, and we've not touched on that at all yet. Let's get to it.


## Creating a custom animation property with POP

One of the great things about pop (there are many) is that it is a general purpose
animation engine - you can pretty much animate anything. For example, you could
"animate" audio volume, or, as we're doing here, the value of a shinobi chart
data point.

There are lot of standard things which you can animate - such as the bounds of
a `UView` or a `CALayer`, and these are catered for in the API. However, to
animate a non-standard property, we have to create a `POPAnimateableProperty`,
which will contain within it the knowledge of how to read the current value of
the thing being animated, and how to write back to it as the animation engine
runs.

Pop is easily installed as a CocoaPod - for instructions checkout the getting
started section on [github.com/facebook/pop](https://github.com/facebook/pop).
There isn't much code required to add the animation to the datasource - we need
a custom property to animate, and then to create and apply the animation itself.

Since we're going to need to use the animation property repeatedly, create a
new property in the class extension:

    @property (nonatomic, strong) POPAnimatableProperty *animateableValuesProperty;

And then create it in the constructor:

    self.animateableValuesProperty = [POPAnimatableProperty propertyWithName:@"com.shinobicontrols.popgoesshinobi.animatingdatasource"
                                                                 initializer:^(POPMutableAnimatableProperty *prop) {
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

During an animation, the engine will send the current in-flight value to the
`POPAnimateableProperty`, and this will apply this to the underlying object as
appropriate. In order to do this there are 2 blocks - a `readBlock`, which
translates from the object being animated into the animation engine, and a
`writeBlock` which does the converse.

In our chart we are going to animate the `yValue` of the data points - so the
read block involves extracting the `yValue` of the datapoint and placing it in
the provided float array.

The `writeBlock` will do the converse - setting the `yValue` property on the
data point to the value provided by the engine. Here we're clipping it to be
positive so as not to upset pie charts. Once we've set the value, the chart needs
to reload its data and redraw itself.

> This point highlights a limitation with this approach. Since every tick of the
animation engine will result in a redraw of the chart, it's not very efficient.
It means that this approach is great for small datasets, but will struggle with
large amounts of data.

The only other bit of code we need to change is the implementation of the
`animateToValues:` method:

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

Instead of hard resetting the values as we did before, we now animate from the
current value to the new value. The syntax of pop is very similar to CoreAnimation.
We create an animation object - here a `POPSpringAnimation`, and set the property
to the custom property we created. We want to animate from the current value
(`dp.yValue`) to the value sent as an argument, and there are a couple of
properties to configure the behavior of the spring animation.

Finally we use the new method added via pop category to `NSObject` to add the
animation to the datapoint. Specifying the key like this means that if the
method is called before the animation is complete then the animation will
gracefully switch to the new value.

If you run the app up now and switch between years then you'll see that the
data points animate nicely between values. Pretty cool for about 20 lines of
animation code!

The sample project includes some `UISlider` controls to enable tuning of the
spring bounciness and speed properties in the animation. You can play with these
to see the effect on the animation.


## Conclusion
