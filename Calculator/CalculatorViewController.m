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


/* Maybe have problem dealing with nil value.
 * aSet, aDictionary can be nil. aSet cannot be empty. aDictionary cannot be empty too.
 * Every variable inside the aSet may not have the corresponding value in aDictionary.
 */
- (NSString *)displayedVariables:(NSSet *)aSet
		   variablesInDictionary:(NSDictionary *) aDictionary
{
	NSMutableString *displayed = [@"" mutableCopy];
	for (NSString *var in aSet) //not sure if this can deal with the condition when aSet is nil
		if ([aDictionary objectForKey:var]) [displayed appendFormat:@"%@ = %@    ", var, [aDictionary objectForKey:var]];	
	return [displayed copy];
}


- (IBAction)testPressed:(UIButton *)sender {
	NSArray *variableNames = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
	NSSet *variableUsedSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
	NSArray *testValues;
								  
	if ([[sender currentTitle] isEqualToString:@"Test1"]) {
		self.variableValues = nil;
	} else {
		if ([[sender currentTitle] isEqualToString:@"Test2"]) {
			testValues = [NSArray arrayWithObjects: [NSNumber numberWithDouble:1], [NSNumber numberWithDouble:2], [NSNumber numberWithDouble:3], nil];
		} else if ([[sender currentTitle] isEqualToString:@"Test3"]) {
			testValues = [NSArray arrayWithObjects: [NSNumber numberWithDouble:4], [NSNumber numberWithDouble:5], [NSNumber numberWithDouble:6], nil];
		} else if ([[sender currentTitle] isEqualToString:@"Test4"]) {
			testValues = [NSArray arrayWithObjects: [NSNumber numberWithDouble:7], [NSNumber numberWithDouble:8], [NSNumber numberWithDouble:9], nil];
		}
		self.variableValues = [NSDictionary dictionaryWithObjects:testValues forKeys:variableNames];
	}
	self.displayVariableValues.text = [self displayedVariables:variableUsedSet variablesInDictionary:self.variableValues];
}

@end
