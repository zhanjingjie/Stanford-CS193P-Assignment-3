//
//  GraphingViewController.h
//  Calculator
//
//  Created by Jingjie Zhan on 7/14/12.
//  Copyright (c) 2012 University of California Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "splitViewBarButtonPresenter.h"

@interface GraphingViewController : UIViewController <UISplitViewControllerDelegate, splitViewBarButtonPresenter>
// This will be the model of the controller
// Every time a segue to this controller, set this model to be the program stack and also make the GraphingView redraw if the program stack is set to a different stack
// Make the model public
// Be expecially careful about the naming. Don't make them the same.
@property (nonatomic, strong) NSMutableArray *program;

@end
