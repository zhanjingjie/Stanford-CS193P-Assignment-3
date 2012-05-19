//
//  CalculatorBrain.m
//  Calculator
//
//  Created by apple on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <math.h>
#import "CalculatorBrain.h"


@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end


@implementation CalculatorBrain
@synthesize programStack = _programStack;

// Getter
///////////////////////////////////////////////

- (id)program
{
	return [self.programStack copy];
}


- (NSMutableArray *) programStack
{
	if (!_programStack) {
		_programStack = [[NSMutableArray alloc] init];
	}
	return _programStack;
}

///////////////////////////////////////////////


- (void) pushOperand:(double)operand 
{
	[self.programStack addObject:[NSNumber numberWithDouble:operand]];
}




- (void) clearOperation 
{
	[self.programStack removeAllObjects];
}


+ (BOOL)isOperation:(NSString *)operation 
{
	static NSSet *operationSet;
	if (!operationSet)
		operationSet = [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"sin", @"cos", @"tan", @"Pi", @"sqrt", nil];
	return [operationSet containsObject:operation];
}


/* This method should be shared no matter there is variable or not.
 */
+ (double) popOperandOffStack:(NSMutableArray *)stack
		  usingVariableValues:(NSDictionary *)variableValues
{
	double result = 0;
	
	id topOfStack = [stack lastObject];
	if (topOfStack) 
		[stack removeLastObject];
	
	if ([topOfStack isKindOfClass:[NSNumber class]]) {
		result = [topOfStack doubleValue];
	} else if ([topOfStack isKindOfClass:[NSString class]]) {
		NSString *operation = topOfStack;
		if ([operation isEqualToString:@"+"]) {
			result = 
			[self popOperandOffStack:stack usingVariableValues:variableValues] + 
			[self popOperandOffStack:stack usingVariableValues:variableValues];
		} else if ([@"*" isEqualToString:operation]) {
			result = 
			[self popOperandOffStack:stack usingVariableValues:variableValues] * 
			[self popOperandOffStack:stack usingVariableValues:variableValues];
		} else if ([operation isEqualToString:@"-"]) {
			double subtrahend = 
			[self popOperandOffStack:stack usingVariableValues:variableValues];
			result = [self popOperandOffStack:stack usingVariableValues:variableValues] - subtrahend;
		} else if ([operation isEqualToString:@"/"]) {
			double divisor = 
			[self popOperandOffStack:stack usingVariableValues:variableValues];
			if (divisor) 
				result = [self popOperandOffStack:stack usingVariableValues:variableValues] / divisor;
		} else if ([operation isEqualToString:@"sin"]) {//sin function
			result = sin([self popOperandOffStack:stack usingVariableValues:variableValues]);
		} else if ([operation isEqualToString:@"cos"]) {//cos function
			result = cos([self popOperandOffStack:stack usingVariableValues:variableValues]);
		} else if ([operation isEqualToString:@"tan"]) {//tan function
			result = tan([self popOperandOffStack:stack usingVariableValues:variableValues]);
		} else if ([operation isEqualToString:@"sqrt"]) {//sqrt function
			result = sqrt([self popOperandOffStack:stack usingVariableValues:variableValues]);
		} else if ([operation isEqualToString:@"Pi"]) {//Pi function
			result = M_PI;
		}
	} else {//Now it must be a variable
		NSString *variable = topOfStack;
		NSNumber *value = [variableValues objectForKey:variable];
		if (value)
			result = [value doubleValue];
	}
	return result;
}


+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;
{
	NSMutableArray *stack;
	if ([program isKindOfClass:[NSArray class]]) {//check if my program is still an array
		stack = [program mutableCopy];//statically typed
	}
	return [self popOperandOffStack:stack
				usingVariableValues:(NSDictionary *)variableValues];
}

- (double) performOperation:(NSString *)operation 
		usingVariableValues: (NSDictionary *) variableValues {
	[self.programStack addObject:operation];
	return [CalculatorBrain runProgram:self.program
				   usingVariableValues:variableValues];
}


+ (NSSet *)variablesUsedInProgram:(id)program 
{
	NSMutableSet *variableSet;
	for (id content in program) {
		if ([content isKindOfClass:[NSString class]] && ![CalculatorBrain isOperation:content]) {
			if (!variableSet) {
				[variableSet setByAddingObject:content];//Yea, lazy evaluation
			} else {
				[variableSet addObject:content];
			}
		}
	}
	return [variableSet copy];//use a copy of the variableSet
}




+ (NSString *)descriptionOfProgram:(id)program
{
	return @"Implement this in Assignment 2";
}






@end
