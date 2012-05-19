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

- (void) pushOperand:(double)operand;
- (double) performOperation:(NSString *)operation;
- (void) clearOperation;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
  usingVriableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

+ (NSString *)descriptionOfProgram:(id)program;


@end
