//
//  CalculatorBrain.h
//  Calculator
//
//  Created by apple on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

@property (readonly) id program;

- (void) pushOperand:(NSString *)operand;
- (double) performOperation:(NSString *)operation
		 usingVariableValues:(NSDictionary *)variableValues;
- (void) clearOperation;


+ (double)runProgram:(id)program
  usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (BOOL) isOperation:(NSString *)operation;

+ (NSString *)descriptionOfProgram:(id)program;


@end
