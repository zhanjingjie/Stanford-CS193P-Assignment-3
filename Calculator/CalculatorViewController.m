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
@property (nonatomic, strong) NSDictionary *variableValues;
@end




@implementation CalculatorViewController
@synthesize display = _display;
@synthesize displayEquation = _displayEquation;
@synthesize displayVariableValues = _displayVariableValues;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variableValues = _variableValues;//the dictionary to hold the value of variables.

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
	} else {
		self.display.text = digit;
		self.userIsInTheMiddleOfEnteringANumber = YES;
	}
}


- (IBAction)variablePressed:(UIButton *)sender {
	self.display.text = [sender currentTitle];
	[self.brain pushOperand:self.display.text];
}

/* When enter key is pressed, push the operand on the screen to the stack.*/
- (IBAction)enterPressed {
	if ([self.display.text doubleValue]) [self.brain pushOperand:self.display.text]; 	
	self.userIsInTheMiddleOfEnteringANumber = NO;
	self.displayEquation.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

/* Perform the operation and update the display and displayEquation.*/
- (IBAction)operationPressed:(UIButton *)sender {
	if (self.userIsInTheMiddleOfEnteringANumber) {
		[self enterPressed];
	}
	NSString *operation = [sender currentTitle];
	[self.brain pushOperand:operation];
	double result = [CalculatorBrain runProgram:self.brain.program
							 usingVariableValues:self.variableValues];//Add another argument here
	self.display.text = [NSString stringWithFormat:@"%g", result];
	self.displayEquation.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

/*If C is pressed, then two display and userIsInTheMiddleOfEnteringANumber should be reset initial state(done in controller)
And the stack in the brain should also be reset(done in model)*/
- (IBAction)clearPressed {
	[self.brain clearOperation];
	self.display.text = [NSString stringWithFormat:@"%d", 0];
	self.displayEquation.text = [NSString stringWithFormat:@"%s", ""];
	self.userIsInTheMiddleOfEnteringANumber = NO;
}


- (IBAction)testPressed:(UIButton *)sender {
	NSArray *variableNames = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
								  
	if ([[sender currentTitle] isEqualToString:@"Test1"]) {
		self.variableValues = nil;
		self.displayVariableValues.text = @"x = 0, y = 0, z = 0";
	} else if ([[sender currentTitle] isEqualToString:@"Test2"]) {
		/*NSArray *test2 = [NSArray arrayWithObjects:
						  [NSNumber numberWithDouble:1],
						  [NSNumber numberWithDouble:2], 
						  [NSNumber numberWithDouble:3], nil];
		self.variableValues = [self.variableValues initWithObjects:test2 forKeys:variableNames];*/
	}
}


@end
