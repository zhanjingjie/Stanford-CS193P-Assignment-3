//
//  GraphingView.m
//  Calculator
//
//  Created by Jingjie Zhan on 7/14/12.
//  Copyright (c) 2012 University of California Berkeley. All rights reserved.
//

#import "GraphingView.h"

@implementation GraphingView


@synthesize axisOrigin = _axisOrigin;
@synthesize scale = _scale;
@synthesize drawingMode = _drawingMode;
@synthesize dataSource = _dataSource;

#pragma mark - Self setup methods

- (void)setup
{
	self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
	[self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}


#pragma mark - Drawing methods


#define FONT_SIZE 13

- (void)drawDescription:(NSString *)description 
			 atPoint: (CGPoint)position
{
	if ([description length]) {
		UIFont *font = [UIFont systemFontOfSize:FONT_SIZE];
		CGRect textRect;
		textRect.size = [description sizeWithFont:font];
		textRect.origin.x = position.x;
		textRect.origin.y = position.y;
		
		[description drawInRect:textRect withFont:font];
	} else {
		NSLog(@"Error: drawing description is nil.");
	}
}



- (void)drawRect:(CGRect)rect
{	
	// Draw the x and y axis
	CGRect bounds = self.bounds;
	CGPoint axisOrigin = self.axisOrigin; // origin can be changed by tripple tapping gesture
	CGFloat scale = self.scale; // scale can be changed by pinching gesture
	[AxesDrawer drawAxesInRect:bounds originAtPoint:axisOrigin scale:scale];
	
	// Draw the program description
	CGPoint position = CGPointMake(20.0, 80.0);
	[self drawDescription:[self.dataSource descriptionOfProgram] atPoint:position];
	
	// Draw the graph
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextBeginPath(context);
	
	// Tried making the calculation in a separate thread, but it has very strange behavior
	
	if (self.drawingMode) {
		// This is the point based strategy
		for (float position = bounds.origin.x; position < bounds.origin.x + bounds.size.width; position+=0.1) {
			// it takes most time to get the xValue and yValue right
			float xValue =(position - axisOrigin.x) / scale;
			
			// This line is where most of the time was used for computing
			float yValue = axisOrigin.y - [self.dataSource yValueForX:xValue]*scale; 
			CGContextFillRect(context, CGRectMake(position, yValue, 1, 1));
		}
	} else {
		// This is the line based strategy, not looking good when graph discontinuous function
		float startingXValue = (0.0 - axisOrigin.x) / scale;
		float startingYValue = axisOrigin.y - [self.dataSource yValueForX:startingXValue]*scale;
		CGContextMoveToPoint(context, 0.0, startingYValue);
		
		for (float position = bounds.origin.x; position < bounds.origin.x + bounds.size.width; position+=10) {
			float xValue =(position - axisOrigin.x) / scale;
			float yValue = axisOrigin.y - [self.dataSource yValueForX:xValue]*scale;
			CGContextAddLineToPoint(context, position, yValue);
		}
	}
	
	CGContextStrokePath(context);
}


#pragma mark - Drawing Modes


- (BOOL)drawingMode
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"drawingMode"];
}

- (void)setDrawingMode:(BOOL)drawingMode
{
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
	[userDefault setBool:drawingMode forKey:@"drawingMode"];
	[userDefault synchronize];
	
	[self setNeedsDisplay];
	
}



#pragma mark - Pinch Gestures

- (CGFloat)scale 
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:@"scale"];
}

- (void)setScale:(CGFloat)scale
{
	if (scale != _scale) {
		_scale = scale;
		
		// save to user defaults
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setFloat:scale forKey:@"scale"];
		[userDefault synchronize];
		
		[self setNeedsDisplay];
	}
}


- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
	if ((gesture.state == UIGestureRecognizerStateChanged) ||
		(gesture.state == UIGestureRecognizerStateEnded)) {
		self.scale *= gesture.scale;
		gesture.scale = 1;
	}
}


#pragma mark - Tripple tap gesture

- (CGPoint)axisOrigin
{
	return CGPointFromString([[NSUserDefaults standardUserDefaults] objectForKey:@"axisOrigin"]);
}


- (void)setAxisOrigin:(CGPoint)axisOrigin
{
	if (!CGPointEqualToPoint(axisOrigin, _axisOrigin)) {
		_axisOrigin = axisOrigin;
		
		// save to user defaults
		NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
		[userDefault setObject:NSStringFromCGPoint(axisOrigin) forKey:@"axisOrigin"];
		[userDefault synchronize];
		
		[self setNeedsDisplay];
	}
}


// The x,y axis can move successfully, but the graph is not moving to the right place
- (void)trippleTap:(UITapGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.axisOrigin = [gesture locationInView:self];
	}
}


#pragma mark - Pan gesture

#define PAN_SCALING 10

- (void)pan:(UIPanGestureRecognizer *)gesture
{
	if ((gesture.state == UIGestureRecognizerStateChanged) ||
		(gesture.state == UIGestureRecognizerStateEnded)) {
		CGPoint translation = [gesture translationInView:self];
		
		CGFloat newX = self.axisOrigin.x + translation.x / PAN_SCALING;
		CGFloat newY = self.axisOrigin.y + translation.y / PAN_SCALING;
		self.axisOrigin = CGPointMake(newX, newY);
	}
}


@end
