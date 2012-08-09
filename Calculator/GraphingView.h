//
//  GraphingView.h
//  Calculator
//
//  Created by Jingjie Zhan on 7/14/12.
//  Copyright (c) 2012 University of California Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AxesDrawer.h"

@protocol GraphingViewDataSource
// Need to y value for each x value on the x axis
- (float)yValueForX:(float)x;
- (NSString *)descriptionOfProgram;
@end



@interface GraphingView : UIView

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)trippleTap: (UITapGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint axisOrigin;
@property (nonatomic) BOOL drawingMode;
@property (nonatomic, weak) IBOutlet id <GraphingViewDataSource> dataSource;
@end
