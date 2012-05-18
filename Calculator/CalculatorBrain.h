//
//  CalculatorBrain.h
//  Calculator
//
//  Created by apple on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void) pushOperand:(double)operand;

/* Make it backward compatible.
 * Calls runProgram when it's an operation.
 */
- (double) performOperation:(NSString *)operation;

- (void) clearOperation;

/* An array with id types.
 * Can hold NSString type operation and NSNumber type operand.
 * It is the snapshot of the programStack.
 */
@property (readonly) id program;

/* runProgram's input is the whole input program, an array with id types.
 * output is the top of the stack.
 * If it is an operand, return it.
 * If it is an operation, evaluate it and then return it.
 * No need for pushing the result back into the stack, because you just need consume the stack continuously.
 */
+ (double)runProgram:(id)program;

/* input is the array of id types.
 * output is a string of human redable feature.
 * Implement it in homework.
 */
+ (NSString *)descriptionOfProgram:(id)program;


@end
