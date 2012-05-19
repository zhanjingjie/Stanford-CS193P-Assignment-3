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
@synthesize operationSet = _operationSet;

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

+ (NSSet *) operationSet
{
	if (!_operationSet) {
		_operationSet = [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"sin", @"cos", @"tan", @"Pi", @"sqrt", nil];
	}
	return _operationSet;
	
}
///////////////////////////////////////////////


- (void) pushOperand:(double)operand {
	[self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (double) performOperation:(NSString *)operation {
	
	[self.programStack addObject:operation];
	return [CalculatorBrain runProgram:self.program];
}


- (void) clearOperation {
	[self.programStack removeAllObjects];
}


+ (double) popOperandOffStack:(NSMutableArray *)stack
{
	double result = 0;
	
	id topOfStack = [stack lastObject];
	if (topOfStack) 
		[stack removeLastObject];
	
	if ([topOfStack isKindOfClass:[NSNumber class]]) {
		result = [topOfStack doubleValue];
	} 
	
	else if ([topOfStack isKindOfClass:[NSString class]]) {
		NSString *operation = topOfStack;
		
		if ([operation isEqualToString:@"+"]) {
			result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
		} else if ([@"*" isEqualToString:operation]) {
			result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
		} else if ([operation isEqualToString:@"-"]) {
			double subtrahend = [self popOperandOffStack:stack];
			result = [self popOperandOffStack:stack] - subtrahend;
		} else if ([operation isEqualToString:@"/"]) {
			double divisor = [self popOperandOffStack:stack];
			if (divisor) 
				result = [self popOperandOffStack:stack] / divisor;
		} else if ([operation isEqualToString:@"sin"]) {//sin function
			result = sin([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"cos"]) {//cos function
			result = cos([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"tan"]) {//tan function
			result = tan([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"sqrt"]) {//sqrt function
			result = sqrt([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"Pi"]) {//Pi function
			//[self pushOperand:M_PI];
			result = M_PI;
		}
	}
	return result;
}


+ (double)runProgram:(id)program
{
	NSMutableArray *stack;
	if ([program isKindOfClass:[NSArray class]]) {//check if my program is still an array
		stack = [program mutableCopy];//statically typed
	}
	return [self popOperandOffStack:stack];//This should also be a class method.
}


+ (NSSet *)variablesUsedInProgram:(id)program 
{
	NSMutableSet *variableSet;
	for (id content in program) {
		if ([content isKindOfClass:[NSString class]] && ![self.operationSet member:content]) {
			if (!variableSet) {
				[variableSet setByAddingObject:content];//Yea, lazy evaluation
			} else {
				[variableSet addObject:content];
			}
		}
	}
	return variableSet;
}




+ (NSString *)descriptionOfProgram:(id)program
{
	return @"Implement this in Assignment 2";
}






@end
