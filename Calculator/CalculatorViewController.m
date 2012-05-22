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



/* place from top to bottom: equation, result, variable.*/
- (void)updateCenter:(NSString *)displayText
	   placeToUpdate: (NSString *) place
{
	if ([place isEqualToString:@"equation"]) {
		self.displayEquation.text = displayText;
	} else if ([place isEqualToString:@"result"]) {
		self.display.text = displayText;
		
		if ([self.display.text isEqualToString:@""]) {
			self.userIsInTheMiddleOfEnteringANumber = NO;
			[self.brain popOneStack];
			
			[self updateCenter:@"" placeToUpdate:@"variable"];
			[self updateCenter:[CalculatorBrain descriptionOfProgram:self.brain.program] placeToUpdate:@"equation"];
			double result = [CalculatorBrain runProgram:self.brain.program
									usingVariableValues:self.variableValues];
			[self updateCenter:[NSString stringWithFormat:@"%g", result] placeToUpdate:@"result"];
		}
	} else if ([place isEqualToString:@"variable"]) {// Variable will always update itself
		NSSet *variableUsedSet = [CalculatorBrain variablesUsedInProgram:self.brain.program];
		self.displayVariableValues.text = [self displayedVariables:variableUsedSet variablesInDictionary:self.variableValues];
	}
}


/* Updating display.*/
- (IBAction)digitPressed:(UIButton *)sender {
	NSString *digit = [sender currentTitle];
	
	if ([digit isEqualToString:@"."] && [self.display.text rangeOfString:@"."].location != NSNotFound)
		if (self.userIsInTheMiddleOfEnteringANumber)
			return;
	if (self.userIsInTheMiddleOfEnteringANumber) {
		[self updateCenter:[self.display.text stringByAppendingString:digit] placeToUpdate:@"result"];	
	} else {
		[self updateCenter:digit placeToUpdate:@"result"];	
		self.userIsInTheMiddleOfEnteringANumber = YES;
	}
}


/* Updating displayEquation.*/
- (IBAction)enterPressed {
	if ([self.display.text doubleValue]) [self.brain pushOperand:self.display.text]; 	
	self.userIsInTheMiddleOfEnteringANumber = NO;
	[self updateCenter:[CalculatorBrain descriptionOfProgram:self.brain.program] placeToUpdate:@"equation"];	
}

/* Updating display and displayEquation.*/
- (IBAction)operationPressed:(UIButton *)sender {
	if (self.userIsInTheMiddleOfEnteringANumber) {
		[self enterPressed];
	}
	NSString *operation = [sender currentTitle];
	[self.brain pushOperand:operation];
	double result = [CalculatorBrain runProgram:self.brain.program
							 usingVariableValues:self.variableValues];
	[self updateCenter:[NSString stringWithFormat:@"%g", result] placeToUpdate:@"result"];	
	[self updateCenter:[CalculatorBrain descriptionOfProgram:self.brain.program] placeToUpdate:@"equation"];
}


/* Updating display, displayEquation, displayVariableValues.
 * Also updating fields userIsInTheMiddleOfEnteringANumber, and variableValues.
 */
- (IBAction)clearPressed {
	[self.brain clearOperation];
	[self updateCenter:@"" placeToUpdate:@"equation"];
	[self updateCenter:@"0" placeToUpdate:@"result"];
	[self updateCenter:@"" placeToUpdate:@"variable"];
	self.variableValues = nil;
	self.userIsInTheMiddleOfEnteringANumber = NO;
}





/* Updating display and displayVariableValues.*/
- (IBAction)variablePressed:(UIButton *)sender {
	[self updateCenter:[sender currentTitle] placeToUpdate:@"result"];
	[self.brain pushOperand:self.display.text];
	[self updateCenter:@"" placeToUpdate:@"variable"];
}


/* Updating displayVariableValues.*/
- (IBAction)testPressed:(UIButton *)sender {
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
	[self updateCenter:@"" placeToUpdate:@"variable"];
}

/* Updating display, displayEquations, displayVariableValues.*/
- (IBAction)undoPressed {
	if (self.userIsInTheMiddleOfEnteringANumber) {//Not sure what will happen if only one character is left
		[self updateCenter:[self.display.text substringToIndex:[self.display.text length] - 1] placeToUpdate:@"result"];
	} else {
		[self updateCenter:@"" placeToUpdate:@"result"];
	}
	
	// Delete last digit in display, if in the middle of entering a number
	// If display is deleted till nil, then it must not be in the middle of entering a number (update field)
	// Handle this in updateCenter, if it's going to be nil, then call itself (like a recursion)
	
	// Delete top thing on the stack, if not in the middle of entering a number
	// Call model to delete the top thing on stack (in update center)
	// Then call descriptionOfProgram, runProgram
	// And also need to update the variable field, because maybe you deleted a variable
	// Call itself to update variable field
}

@end
