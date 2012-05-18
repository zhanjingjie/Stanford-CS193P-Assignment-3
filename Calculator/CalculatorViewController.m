//
//  CalculatorViewController.m
//  Calculator
//
//  Created by apple on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end




@implementation CalculatorViewController
@synthesize display = _display;
@synthesize displayEquation = _displayEquation;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

/* Getter method for the brain. Lazy evaluation.*/
- (CalculatorBrain *) brain
{
	if (!_brain)
		_brain = [[CalculatorBrain alloc] init];
	return _brain;
}

/* Updating the two display places when a digit is pressed.*/
- (IBAction)digitPressed:(UIButton *)sender {
	NSString *digit = [sender currentTitle];
	
	//Need to check if it is the decimal point, if it is, check for the correctness
	if ([digit isEqualToString:@"."] && [self.display.text rangeOfString:@"."].location != NSNotFound)
		if (self.userIsInTheMiddleOfEnteringANumber)
			return;
	if (self.userIsInTheMiddleOfEnteringANumber) {
		self.display.text = [self.display.text stringByAppendingString:digit];
		self.displayEquation.text = [self.displayEquation.text stringByAppendingFormat:@"%@", digit];
	} else {
		self.display.text = digit;
		self.userIsInTheMiddleOfEnteringANumber = YES;
		self.displayEquation.text = [self.displayEquation.text stringByAppendingFormat:@"%s%@", "  ", digit];
	}
}

/* When enter key is pressed, push the operand on the screen to the stack.*/
- (IBAction)enterPressed {
	[self.brain pushOperand:[self.display.text doubleValue]];
	self.userIsInTheMiddleOfEnteringANumber = NO;
}

/* Perform the operation and update the display and displayEquation.*/
- (IBAction)operationPressed:(UIButton *)sender {
	if (self.userIsInTheMiddleOfEnteringANumber) {
		[self enterPressed];
	}
	NSString *operation = [sender currentTitle];
	double result = [self.brain performOperation:operation];
	self.display.text = [NSString stringWithFormat:@"%g", result];
	self.displayEquation.text = [self.displayEquation.text stringByAppendingFormat:@"%s%@", "  ", operation];
}

/*If C is pressed, then two display and userIsInTheMiddleOfEnteringANumber should be reset initial state(done in controller)
And the stack in the brain should also be reset(done in model)*/
- (IBAction)clearPressed {
	[self.brain clearOperation];
	self.display.text = [NSString stringWithFormat:@"%d", 0];
	self.displayEquation.text = [NSString stringWithFormat:@"%s", ""];
	self.userIsInTheMiddleOfEnteringANumber = NO;
}

@end
