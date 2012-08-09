//
//  FavoritesTableViewController.h
//  Calculator
//
//  Created by Jingjie Zhan on 7/25/12.
//  Copyright (c) 2012 University of California Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesTableViewController;
@protocol favoritesTableViewControllerDelegate <NSObject>
@optional
- (void)favoritesTableViewController:(FavoritesTableViewController *)sender
						choseProgram:(id)program;
- (void)calculatorProgramsTableViewController:(FavoritesTableViewController *)sender
							   deletedProgram:(id)program;
@end

@interface FavoritesTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *programs; // The model for this controller, will be prepared when segue
@property (nonatomic, weak) id <favoritesTableViewControllerDelegate> delegate;
@end
