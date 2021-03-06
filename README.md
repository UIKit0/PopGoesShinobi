# PopCharts
## Animating ShinobiCharts using Facebook's pop

PopCharts (a.k.a. PopGoesShinobi) demonstrates how the pop animation framework
can be used to animate a chart between datasets

![Animating Column Chart](img/popCharts_animating_column.gif)

### Building the project

You'll either need to have ShinobiCharts installed on you mac, or you'll have
to pull the framework into the PopGoesShinobi project. You can download a free
trial of ShinobiCharts from the
[website](http://www.shinobicontrols.com/ios/shinobicharts/price-plans/shinobicharts-premium/shinobicharts-free-trial-form).

If you're using the trial then you need to update the following line in
__SCViewController.m__ to include the license key you've been sent by email:

    self.chart.licenseKey = @"";

The pop library is available as a CocoaPod, and this repo has a Podfile which
will include it as appropriate. Make sure that you've got CocoaPods installed
and then run the following command from the repo directory:

    pod install

If you need additional help with CocoaPods, including how to get started with
installing it, then check out the fantastic help at
[guides.cocoapods.org](http://guides.cocoapods.org/).

### Contributing

We'd love to see your contributions to this project - please go ahead and fork
it and send us a pull request when you're done! Or if you have a new project you
think we should include here, email info@shinobicontrols.com to tell us about it.

### License

The [Apache License, Version 2.0](license) applies to everything in this
repository, and will apply to any user contributions.

### Comments & Feedback

If you have any comments or feedback then you should pester me on twitter - I'm
[@iwantmyrealname](https://twitter.com/iwantmyrealname).

sam
