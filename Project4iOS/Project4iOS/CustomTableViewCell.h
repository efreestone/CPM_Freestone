// Elijah Freestone
// CPM 1410
// Week 4
// October 17th, 2014

//
//  CustomTableViewCell.h
//  Project4iOS
//
//  Created by Elijah Freestone on 10/17/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSwipeCellDelegate <NSObject>
- (void)deleteButtonActionForCell;
- (void)editButtonTwoActionForCell;
- (void)cellDidOpen:(UITableViewCell *)cell;
- (void)cellDidClose:(UITableViewCell *)cell;
@end

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *itemText;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIView *myContentView;

@property (strong, nonatomic) IBOutlet UILabel *nameCellLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberCellLabel;

@property (nonatomic, weak) id <CustomSwipeCellDelegate> delegate;
- (void)openCell;

//Properties for swipe
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewLeftConstraint;

@end
