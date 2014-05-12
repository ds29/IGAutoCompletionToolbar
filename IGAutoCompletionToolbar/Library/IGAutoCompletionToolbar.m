//
//  IGAutoCompletionToolbar.m
//  IGAutoCompletionToolbar
//
//  Created by Chong Francis on 13年2月26日.
//  Copyright (c) 2013年 Ignition Soft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "IGAutoCompletionToolbar.h"
#import "IGAutoCompletionToolbarCell.h"
#import "IGAutoCompletionToolbarLayout.h"

#define MAX_LABEL_WIDTH 280.0

NSString* const IGAutoCompletionToolbarCellID = @"IGAutoCompletionToolbarCellID";

@implementation IGAutoCompletionToolbar

@synthesize textField = _textField;
@synthesize items = _items, filteredItems = _filteredItems, filter = _filter;

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[[IGAutoCompletionToolbarLayout alloc] init]];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.items = [NSArray array];
        self.filter = nil;

        self.allowsSelection = YES;
        self.allowsMultipleSelection = NO;

        [self registerClass:[IGAutoCompletionToolbarCell class]
 forCellWithReuseIdentifier:IGAutoCompletionToolbarCellID];

        self.dataSource = self;
        self.delegate = self;

        self.gradientLayer = [CAGradientLayer layer];
        UIColor * highColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
        UIColor * lowColor = [UIColor colorWithRed:0.322 green:0.361 blue:0.412 alpha:1];
        self.gradientLayer.frame = self.bounds;
        self.gradientLayer.colors = @[(id)[highColor CGColor], (id)[lowColor CGColor]];
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        [self.backgroundView.layer addSublayer:self.gradientLayer];

        _whiteBorder = [CALayer layer];
        _whiteBorder.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
        _whiteBorder.frame = CGRectMake(0, 1.0, self.backgroundView.frame.size.width, 1.0);
        [self.backgroundView.layer addSublayer:_whiteBorder];

        _blackBorder = [CALayer layer];
        _blackBorder.backgroundColor = [UIColor blackColor].CGColor;
        _blackBorder.frame = CGRectMake(0, 0.0, self.backgroundView.frame.size.width, 1.0);
        [self.backgroundView.layer addSublayer:_blackBorder];

        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

-(void) setTextField:(UITextField *)textField {
    if (_textField != textField) {
        if (_textField != NULL) {
            [_textField removeTarget:self action:@selector(autoCompletionToolbarTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        }

        if (textField != NULL) {
            [textField addTarget:self action:@selector(autoCompletionToolbarTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        }
        
        _textField = textField;
    }
}

-(void) autoCompletionToolbarTextDidChange:(id)sender {
    UITextField* textField = sender;
    self.filter = textField.text;
}

-(void) setFilter:(NSString *)filter {
    _filter = filter;
    [self reloadData];
}

-(void) setItems:(NSArray *)items {
    _items = items;
    [self reloadData];
}

-(void) reloadData {
    [self reloadFilteredItems];
    [super reloadData];
    [self.collectionViewLayout invalidateLayout];
}

-(void) layoutSubviews {
    [super layoutSubviews];

    self.gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _whiteBorder.frame = CGRectMake(0, 1.0, self.backgroundView.frame.size.width, 1.0);
    _blackBorder.frame = CGRectMake(0, 0.0, self.backgroundView.frame.size.width, 1.0);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0.0);
    CGContextStrokePath(context);

    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, 0.0, -2.0);
    CGContextAddLineToPoint(context, self.frame.size.width, -2.0);
    CGContextStrokePath(context);

}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.filteredItems count];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<NSObject> object = [self.filteredItems objectAtIndex:[indexPath row]];
    IGAutoCompletionToolbarCell* cell = [self dequeueReusableCellWithReuseIdentifier:IGAutoCompletionToolbarCellID
                                                                        forIndexPath:indexPath];
    if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(autoCompletionToolbar:setupCell:withObject:)]) {
        [self.toolbarDelegate autoCompletionToolbar:self setupCell:cell withObject:object];
    } else {
        if ([object isKindOfClass:[NSString class]]) {
            cell.textLabel.text = (NSString*) object;
        } else {
            cell.textLabel.text = [object description];
        }
        [cell setNeedsLayout];
    }
    return cell;
}

#pragma mark - IGAutoCompletionToolbarLayout

-(CGSize) collectionView:(UICollectionView*)collectionView sizeWithIndex:(NSInteger)index {
    id object = [self.filteredItems objectAtIndex:index];
    if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(autoCompletionToolbar:cellSizeWithObject:)]) {
        return [self.toolbarDelegate autoCompletionToolbar:self cellSizeWithObject:object];
    } else {
        NSString* title = object;
        CGSize size = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0]
                        constrainedToSize:CGSizeMake(MAX_LABEL_WIDTH, 32.0)];
        return CGSizeMake(size.width + 14.0, 32);
    }
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(autoCompletionToolbar:didSelectItemWithObject:)]) {
        id object = [self.filteredItems objectAtIndex:[indexPath row]];
        [self.toolbarDelegate autoCompletionToolbar:self didSelectItemWithObject:object];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - Private

- (void) reloadFilteredItems {
    NSMutableArray* newFilteredItems = [NSMutableArray array];
    [self.items enumerateObjectsUsingBlock:^(id<NSObject> obj, NSUInteger idx, BOOL *stop) {
        if (!self.filter || [self.filter isEqualToString:@""]) {
            [newFilteredItems addObject:obj];
            return;
        }

        if (self.toolbarDelegate && [self.toolbarDelegate respondsToSelector:@selector(autoCompletionToolbar:shouldAcceptObject:withFilter:)]) {
            if ([self.toolbarDelegate autoCompletionToolbar:self shouldAcceptObject:obj withFilter:self.filter]) {
                [newFilteredItems addObject:obj];
            }

        } else {
            NSString* content = nil;
            if ([obj isMemberOfClass:[NSString class]]) {
                content = (NSString*) obj;
            } else {
                content = [obj description];
            }

            if ([content rangeOfString:self.filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [newFilteredItems addObject:obj];
            }
        }
    }];
    
    _filteredItems = newFilteredItems;
}

@end
