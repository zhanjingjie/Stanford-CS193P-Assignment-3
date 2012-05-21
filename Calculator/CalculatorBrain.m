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


- (void) pushOperand:(NSString *)operand 
{
	if (![operand doubleValue]) {
		[self.programStack addObject:operand];//Then it must be a variable
	} else {
		[self.programStack addObject:[NSNumber numberWithDouble:[operand doubleValue]]];
	}
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
	
	for (int index = 0; index < [stack count]; index++) {
		id operand = [stack objectAtIndex:index];
		if ((![operand isKindOfClass:[NSNumber class]]) && (![CalculatorBrain isOperation:operand])) {
			NSNumber *value = [NSNumber numberWithDouble:0];
			if ([variableValues objectForKey:(NSString *)operand]) {//you have to cast the operand the same type as the key.
				value = [variableValues objectForKey:operand];
			}
			[stack replaceObjectAtIndex:index withObject:value];
		}
	}
	return [self popOperandOffStack:stack];
}


+ (NSSet *)variablesUsedInProgram:(id)program 
{
	NSMutableSet *variableSet;
	for (id content in program) {
		if ([content isKindOfClass:[NSString class]] && (![CalculatorBrain isOperation:content])) {
			if (!variableSet) {
				variableSet = [NSMutableSet setWithObject:content];
			} else {
				[variableSet addObject:content];
			}
		}
	}
	return [variableSet copy];//if variableSet is nil, I suppose this will also return nil
}


+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack 
{
	NSString *description = @"0";
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


+ (NSString *)descriptionOfProgram:(id)program
{
	NSMutableArray *stack;
	NSMutableString *descriptions;
	if ([program isKindOfClass:[NSArray class]]) {		
		stack = [program mutableCopy];
	}
	
	while ([stack count]) {
		if (!descriptions) {
			descriptions = [[self descriptionOfTopOfStack:stack] mutableCopy];
		} else {
			[descriptions appendString:[self descriptionOfTopOfStack:stack]];
		}
		if ([stack count]) [descriptions appendString:@", "];
	}
	return [descriptions copy];
}






@end
