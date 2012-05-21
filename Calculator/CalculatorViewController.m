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
@synthesize variableValues = _variableValues;


- (CalculatorBrain *) brain
{
	if (!_brain)
		_brain = [[CalculatorBrain alloc] init];
	return _brain;
}


/* Updating display.*/
- (IBAction)digitPressed:(UIButton *)sender {
	NSString *digit = [sender currentTitle];
	
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


/* Updating displayEquation.*/
- (IBAction)enterPressed {
	if ([self.display.text doubleValue]) [self.brain pushOperand:self.display.text]; 	
	self.userIsInTheMiddleOfEnteringANumber = NO;
	self.displayEquation.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

/* Updating display and displayEquation.*/
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


/* Updating display, displayEquation, displayVariableValues.
 * Also updating fields userIsInTheMiddleOfEnteringANumber, and variableValues.
 */
- (IBAction)clearPressed {
	[self.brain clearOperation];
	self.display.text = [NSString stringWithFormat:@"%d", 0];
	self.displayEquation.text = [NSString stringWithFormat:@"%s", ""];
	self.displayVariableValues.text = [NSString stringWithFormat:@"%s", ""];
	self.variableValues = nil;
	self.userIsInTheMiddleOfEnteringANumber = NO;
}



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


/* Updating display and displayVariableValues.*/
- (IBAction)variablePressed:(UIButton *)sender {
	self.display.text = [sender currentTitle];
	[self.brain pushOperand:self.display.text];
	NSSet *variableUsedSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
	self.displayVariableValues.text = [self displayedVariables:variableUsedSet variablesInDictionary:self.variableValues];
}


/* Updating displayVariableValues.*/
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

/* Updating display, displayEquations, displayVariableValues.*/
- (IBAction)undoPressed {
	if (self.userIsInTheMiddleOfEnteringANumber) {
		
	} else {
		
	}
}

@end
