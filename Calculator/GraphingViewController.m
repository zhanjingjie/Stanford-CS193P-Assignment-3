//
//  GraphingViewController.m
//  Calculator
//
//  Created by Jingjie Zhan on 7/14/12.
//  Copyright (c) 2012 University of California Berkeley. All rights reserved.
//

#import "GraphingViewController.h"
#import "GraphingView.h"
#import "CalculatorBrain.h"
#import "FavoritesTableViewController.h"

@interface GraphingViewController () <GraphingViewDataSource, favoritesTableViewControllerDelegate>

// Need an outlet to be the property in the controller
// To pass it the dataSource and also call it to redraw
@property (nonatomic, weak) IBOutlet GraphingView *graphingView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation GraphingViewController

@synthesize program = _program;
@synthesize graphingView = _graphingView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize popoverController;

#define FAVORITE_KEY @"GraphingViewController.favorites"

// Set itself as the delegate of the split view controller
- (void)awakeFromNib
{
	[super awakeFromNib];
	self.splitViewController.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Show favorite graph"]) {
		// this if statement added after lecture to prevent multiple popovers
        // appearing if the user keeps touching the Favorites button over and over
        // simply remove the last one we put up each time we segue to a new one
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = popoverSegue.popoverController; // might want to be popover's delegate and self.popoverController = nil on dismiss?
        }
		
		NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITE_KEY];
		[segue.destinationViewController setPrograms:programs];
		[segue.destinationViewController setDelegate:self];
	}
}

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

#pragma mark - favoritesTableViewControllerDelegate

- (void)favoritesTableViewController:(FavoritesTableViewController *)sender
						choseProgram:(id)program
{
	self.program = program;
}


- (void)calculatorProgramsTableViewController:(FavoritesTableViewController *)sender
                               deletedProgram:(id)program
{
    NSString *deletedProgramDescription = [CalculatorBrain descriptionOfProgram:program];
    NSMutableArray *favorites = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (id program in [defaults objectForKey:FAVORITE_KEY]) {
        if (![[CalculatorBrain descriptionOfProgram:program] isEqualToString:deletedProgramDescription]) {
            [favorites addObject:program];
        }
    }
    [defaults setObject:favorites forKey:FAVORITE_KEY];
    [defaults synchronize];
	// Update the table view controller's model
    sender.programs = favorites;
}


#pragma mark - Set the drawing mode

- (IBAction)setPrecision:(UISwitch *)sender {
	[self.graphingView setDrawingMode:sender.on];
}


#pragma mark - Add Favorite



- (IBAction)addToFavorite:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *favorites = [[defaults objectForKey:FAVORITE_KEY] mutableCopy];
	if (!favorites) favorites = [NSMutableArray array];
	[favorites addObject:self.program];
	[defaults setObject:favorites forKey:FAVORITE_KEY];
	[defaults synchronize];
}





#pragma mark - UISplitViewController delegate



// By using the protocol, it can work blindly with any detail view controller
// As long as that detailViewController has a property as a button
- (id <splitViewBarButtonPresenter>)splitViewBarButtonItemPresenter
{
	id detailVC = [self.splitViewController.viewControllers lastObject];
	if (![detailVC conformsToProtocol:@protocol(splitViewBarButtonPresenter)]) {
		detailVC = nil;
	}
	return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)aViewController 
			  inOrientation:(UIInterfaceOrientation)orientation
{
	return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}


- (void)splitViewController:(UISplitViewController *)svc 
	 willHideViewController:(UIViewController *)aViewController 
		  withBarButtonItem:(UIBarButtonItem *)barButtonItem 
	   forPopoverController:(UIPopoverController *)pc
{
	//barButtonItem.title = self.title;
	barButtonItem.title = @"Calculator";
	// Tell the detail view to put this button up
	[self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	// Tell the detail view to take the button away
	[self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}




#pragma mark - Setter methods

- (void)setProgram:(NSMutableArray *)program
{
	 _program = program;
	 [self.graphingView setNeedsDisplay];
}


- (void)setGraphingView:(GraphingView *)graphingView
{
	// Don't use self.graphingView = graphingView, it will be infinite loop
	_graphingView = graphingView;
	
	// Pinch gesture
	[self.graphingView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphingView action:@selector(pinch:)]];
	
	// Tripple tap gesture
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphingView action:@selector(trippleTap:)];
	tapRecognizer.numberOfTapsRequired = 3;
	tapRecognizer.numberOfTouchesRequired = 1;
	[self.graphingView addGestureRecognizer:tapRecognizer];
	
	// Pan gesture, handled by the controller
	[self.graphingView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphingView action:@selector(pan:)]];
	
	self.graphingView.dataSource = self;
}





#pragma mark - Data Source method

// This method will be called in a loop to request all y values to the corresponding x values
// Communication between the CalculatorBrain and the the GraphingViewController
- (float)yValueForX:(float)x
{
	float yFloat = 0;
	id y = [CalculatorBrain runProgram:self.program usingVariableValues:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:x] forKey:@"x"]];
	if ([y isKindOfClass:[NSNumber class]]) yFloat = [y floatValue];
	return yFloat;
}

- (NSString *)descriptionOfProgram
{
	return [CalculatorBrain descriptionOfProgram:self.program];
}


#pragma mark - View Controller Life Cycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}


- (void)viewDidUnload {
	[self setToolbar:nil];
	[super viewDidUnload];
}
@end
