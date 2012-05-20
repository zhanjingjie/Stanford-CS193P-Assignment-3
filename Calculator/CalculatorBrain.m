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
@property (nonatomic) NSUInteger *operationCount;
@end


@implementation CalculatorBrain
@synthesize programStack = _programStack;
@synthesize operationCount = _operationCount;

// Getter
///////////////////////////////////////////////

- (id)program
{
	return [self.programStack copy]; //it's just a copy, so nothing will change the programStack, only the clearOperation
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



+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
	static NSSet *twoOperationSet;
	if (!twoOperationSet) twoOperationSet = [NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
	return [twoOperationSet containsObject:operation];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
	static NSSet *oneOperationSet;
	if (!oneOperationSet) oneOperationSet = [NSSet setWithObjects:@"sin", @"cos", @"tan", @"sqrt", nil];
	return [oneOperationSet containsObject:operation];
}

+ (BOOL)isNoOperandOperation:(NSString *)operation
{
	return [operation isEqualToString:@"Pi"];
}

+ (BOOL)isOperation:(NSString *)operation 
{
	return [self isTwoOperandOperation:operation]
	|| [self isOneOperandOperation:operation]
	|| [self isNoOperandOperation:operation];
}




/* No change in this method.
 */
+ (double) popOperandOffStack:(NSMutableArray *)stack
{
	double result = 0;
	
	id topOfStack = [stack lastObject];
	if (topOfStack) [stack removeLastObject];
	
	if ([topOfStack isKindOfClass:[NSNumber class]]) {
		result = [topOfStack doubleValue];
	} else if ([topOfStack isKindOfClass:[NSString class]]) {
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
			if (divisor) result = [self popOperandOffStack:stack] / divisor;
		} else if ([operation isEqualToString:@"sin"]) {//sin function
			result = sin([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"cos"]) {//cos function
			result = cos([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"tan"]) {//tan function
			result = tan([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"sqrt"]) {//sqrt function
			result = sqrt([self popOperandOffStack:stack]);
		} else if ([operation isEqualToString:@"Pi"]) {//Pi function
			result = M_PI;
		}
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
	
	NSUInteger index = 0;
	for (id operand in stack) {
		if (![operand isKindOfClass:[NSNumber class]] && ![CalculatorBrain isOperation:operand])
			[stack replaceObjectAtIndex:index withObject:[variableValues objectForKey:operand]];
		index++;
	}
	return [self popOperandOffStack:stack];
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


+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack 
{
	NSString *description;
	id topOfStack = [stack lastObject];
	if (topOfStack) [stack removeLastObject];
	if ([topOfStack isKindOfClass:[NSNumber class]]) {
		description = [topOfStack stringValue];
	} else if ([topOfStack isKindOfClass:[NSString class]]) {
		NSString *operationOrVar = topOfStack;
		if (![self isOperation:operationOrVar] || [self isNoOperandOperation:operationOrVar]) {
			description = operationOrVar;
		} else if ([self isOneOperandOperation:operationOrVar]) {
			description = [NSString stringWithFormat:@"%@(%@)",operationOrVar, [self descriptionOfTopOfStack:stack]];
		} else if ([self isTwoOperandOperation:operationOrVar]) {
			NSString *secondOperand = [self descriptionOfTopOfStack:stack];
			description = [NSString stringWithFormat:@"(%@ %@ %@)", [self descriptionOfTopOfStack:stack], operationOrVar, secondOperand];
		}
	}
	return description;
}


//Add the commas here
+ (NSString *)descriptionOfProgram:(id)program
{
	NSMutableArray *stack;
	NSString *description;
	if ([program isKindOfClass:[NSArray class]]) {//check if my program is still an array
		stack = [program mutableCopy];//statically typed
	}
	
	for ( ; stack; [description stringByAppendingString:@", "]) {
		if (!description) {
			description = [self descriptionOfTopOfStack:stack];
		} else {
			[description stringByAppendingString:[self descriptionOfTopOfStack:stack]];
		}
	}
	return description;
}






@end
