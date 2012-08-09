//
//  CalculatorViewController.m
//  Calculator
//
//  Created by apple on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphingViewController.h"

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

// Prepare for the graphing view controller
// Set its program

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showGraph"]) {
		[segue.destinationViewController setProgram:self.brain.program];
	}
}





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
			id result = [CalculatorBrain runProgram:self.brain.program
									usingVariableValues:self.variableValues];
			[self updateCenter:[NSString stringWithFormat:@"%@", result] placeToUpdate:@"result"];
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
	if ([self.display.text doubleValue] || [self.display.text isEqualToString:@"0"]) 
		[self.brain pushOperand:self.display.text]; 	
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
	id result = [CalculatorBrain runProgram:self.brain.program
							 usingVariableValues:self.variableValues];
	[self updateCenter:[NSString stringWithFormat:@"%@", result] placeToUpdate:@"result"];	
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


/* Updating displayVariableValues.
   Don't need this method for graphing calculator.
 */
/*
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
*/

/* Updating display, displayEquations, displayVariableValues.*/
- (IBAction)undoPressed {
	if (self.userIsInTheMiddleOfEnteringANumber) {//Not sure what will happen if only one character is left
		[self updateCenter:[self.display.text substringToIndex:[self.display.text length] - 1] placeToUpdate:@"result"];
	} else {
		[self updateCenter:@"" placeToUpdate:@"result"];
	}	
}


- (IBAction)graphProgram 
{
	id graphingViewController = [self.splitViewController.viewControllers lastObject];
	if ([graphingViewController isKindOfClass:[GraphingViewController class]]) {
		((GraphingViewController *) graphingViewController).program = self.brain.program;
	}
}



- (void)viewDidUnload {
	[super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
	//return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
