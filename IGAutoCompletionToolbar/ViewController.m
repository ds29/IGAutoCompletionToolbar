//
//  ViewController.m
//  IGAutoCompletionToolbar
//
//  Created by Chong Francis on 13年2月26日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import "ViewController.h"
#import "IGAutoCompletionToolbarCell.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // customization
    [[IGAutoCompletionToolbarCell appearance] setTextColor:self.view.tintColor];
    [[IGAutoCompletionToolbarCell appearance] setHighlightedTextColor:self.view.tintColor];
    [[IGAutoCompletionToolbarCell appearance] setTextFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];

    self.toolbar = [[IGAutoCompletionToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    self.toolbar.shouldHideItemsWhenFilterIsEmpty = YES;
    self.toolbar.items = @[@"Apple", @"Banana", @"Blueberry", @"Grape", @"Pineapple", @"Orange", @"Pear"];
    self.toolbar.toolbarDelegate = self;

    self.textfield.inputAccessoryView = self.toolbar;
    self.toolbar.textField = self.textfield;
}

#pragma mark - IGAutoCompletionToolbarDelegate

-(NSMutableArray*)autoCompletionToolbar:(IGAutoCompletionToolbar *)toolbar objectsWithFilter:(NSString *)filter {
    return [[toolbar.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", filter]] mutableCopy];
}

- (void) autoCompletionToolbar:(IGAutoCompletionToolbar*)toolbar didSelectItemWithObject:(id)object {
    NSLog(@"tag selected - %@", object);
}

@end
