// Elijah Freestone
// CPM 1410
// Week 4
// October 17th, 2014

//
//  CustomTableViewCell.m
//  Project4iOS
//
//  Created by Elijah Freestone on 10/17/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "CustomTableViewCell.h"

static CGFloat const myBounceValue = 20.0f;

@implementation CustomTableViewCell

//Synthesize for getters/setters
@synthesize nameCellLabel, numberCellLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    //[self.deleteButton setBackgroundColor:[UIColor redColor]];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panContentCell:)];
    self.panRecognizer.delegate = self;
    [self.myContentView addGestureRecognizer:self.panRecognizer];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(id)sender {
    if (sender == self.deleteButton) {
        [self.delegate deleteButtonActionForItemText:self.itemText];
    } else if (sender == self.editButton) {
        [self.delegate editButtonTwoActionForItemText:self.itemText];
    } else {
        NSLog(@"Clicked unknown button!");
    }
}

//Calculate slide distance of top view based on total widths of buttons
- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.editButton.frame);
}

//Snap cell closed
- (void)resetConstraintToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing {
    //TODO: Build.
}

//Snap cell open
- (void)setShowButtonsConstraints:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    //TODO: Notify delegate.
    //If trying to slide left but cell already open, reset constant to catch point
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    //Animate bounce of cell past and back to catch point
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - myBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + myBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //Snap cell to catch point
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            //Reset contraints to clear animations
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

//Set up pan gesture recognizer
//this code is based on the raywenderlich.com swipeable cell tutorial
- (void)panContentCell:(UIPanGestureRecognizer *)panRecognizer {
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            //Set start point
            self.panStartPoint = [panRecognizer translationInView:self.myContentView];
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            //Get current position
            CGPoint currentPoint = [panRecognizer translationInView:self.myContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            //Panning left
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
            }
            //If zero, the view is closed
            if (self.startingRightLayoutConstraintConstant == 0) {
                //The cell was closed and is now opening
                if (!panningLeft) {
                    //If swipe is canceled or swiped back right, close cell again
                    CGFloat constant = MAX(-deltaX, 0);
                    //If zero, the cell is closed
                    if (constant == 0) {
                        [self resetConstraintToZero:YES notifyDelegateDidClose:NO];
                    } else { //set right constant
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    //Panning right to left, opening cell
                    CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]);
                    //Open cell to catch point calculated in buttonTotalWidth
                    if (constant == [self buttonTotalWidth]) {
                        [self setShowButtonsConstraints:YES notifyDelegateDidOpen:NO];
                    } else { //set right constant if not opened to catch point
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            } else {
                //The cell was at least partially open. Check how far
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - deltaX;
                if (!panningLeft) {
                    //Make sure constant is positive
                    CGFloat constant = MAX(adjustment, 0);
                    //The cell is closed
                    if (constant == 0) {
                        [self resetConstraintToZero:YES notifyDelegateDidClose:NO];
                    } else { //set constant to right constraint
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    //Panning right to left
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]);
                    //Cell is open to the catch point
                    if (constant == [self buttonTotalWidth]) {
                        [self setShowButtonsConstraints:YES notifyDelegateDidOpen:NO];
                    } else { //not fully open, set constant
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            //Set left constraint to negative of right
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"Pan Ended");
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Pan Cancelled");
            break;
        default:
            break;
    }
}

//Create animation for snapping of cell opening, also based on raywenderlich tutorial
- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}



@end
