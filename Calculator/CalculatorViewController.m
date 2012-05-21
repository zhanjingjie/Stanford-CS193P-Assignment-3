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
	for (NSString *var in aSet) {//not sure if this can deal with the condition when aSet is nil
		NSNumber *valueInDictionary = [NSNumber numberWithDouble:0];
		if ([aDictionary objectForKey:var]) valueInDictionary = [aDictionary objectForKey:var];
		[displayed appendFormat:@"%@ = %@    ", var, valueInDictionary];	
	}
	return [displayed copy];
}


- (IBAction)variablePressed:(UIButton *)sender {
	self.display.text = [sender currentTitle];
	[self.brain pushOperand:self.display.text];
	NSSet *variableUsedSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
	self.displayVariableValues.text = [self displayedVariables:variableUsedSet variablesInDictionary:self.variableValues];
}


- (IBAction)testPressed:(UIButton *)sender {
	NSSet *variableUsedSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
	NSNumber *zero = [NSNumber numberWithDouble:0];
	NSNumber *five = [NSNumber numberWithDouble:5];
	NSNumber *nagetiveTwo = [NSNumber numberWithDouble:-2];
								  
	if ([[sender currentTitle] isEqualToString:@"Test1"]) {
		self.variableValues = nil;
	} else if ([[sender currentTitle] isEqualToString:@"Test2"]) {
		self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:zero, @"x", zero, @"y", zero, @"z", nil];
	} else if ([[sender currentTitle] isEqualToString:@"Test3"]) {
		self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:five, @"y", nagetiveTwo, @"z", nil];
	} else if ([[sender currentTitle] isEqualToString:@"Test4"]) {
		self.variableValues = [NSDictionary dictionaryWithObjectsAndKeys:zero, @"z", nil];
	}
	self.displayVariableValues.text = [self displayedVariables:variableUsedSet variablesInDictionary:self.variableValues];
}


- (IBAction)undoPressed {
	if (self.userIsInTheMiddleOfEnteringANumber) {
		
	} else {
		
	}
}

@end
