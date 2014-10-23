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
#import "CustomPFLoginViewController.h"

@interface CustomTableViewCell ()
    

@end

static CGFloat const myBounceValue = 20.0f;

@implementation CustomTableViewCell

//Synthesize for getters/setters
@synthesize nameCellLabel, numberCellLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    //Set button background colors
    [self.deleteButton setBackgroundColor:[UIColor redColor]];
    [self.editButton setBackgroundColor:[UIColor greenColor]];
    //Set pan gesture recognizer and delegate
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

//Allow delegate to change cell state
- (void)openCell {
    [self setShowButtonsConstraints:NO notifyDelegateDidOpen:NO];
}

//Make sure cell is reclosed before being recycled
- (void)prepareCellForReuse {
    [super prepareForReuse];
    [self resetConstraintToZero:NO notifyDelegateDidClose:NO];
}

//Action for edit and delete buttons
- (IBAction)buttonClicked:(id)sender {
    if (sender == self.deleteButton) {
        //Notify the delegate. This fires methods to delete the item selected.
        [self.delegate deleteButtonActionForCell];
        [self resetConstraintToZero:YES notifyDelegateDidClose:YES];
    } else if (sender == self.editButton) {
        [self.delegate editButtonTwoActionForCell];
    } else {
        NSLog(@"Clicked unknown button!");
    }
} 

//Calculate slide distance of top view based on total widths of buttons
- (CGFloat)totalWidthOfButtons {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.editButton.frame);
}

//Snap cell closed with bounce
- (void)resetConstraintToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing {
    //Notify delegate
    if (endEditing) {
        [self.delegate cellDidClose:self];
    }
    //Check if cell is closed
    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    //Animate cell bounce closed
    self.contentViewRightConstraint.constant = -myBounceValue;
    self.contentViewLeftConstraint.constant = myBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //Snap cell closed
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        //Resetcontraints to clear animations
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

//Snap cell open with bounce
- (void)setShowButtonsConstraints:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    //Notify delegate.
    if (notifyDelegate) {
        [self.delegate cellDidOpen:self];
    }
    
    //If trying to slide left but cell already open, reset constant to catch point
    if (self.startingRightLayoutConstraintConstant == [self totalWidthOfButtons] &&
        self.contentViewRightConstraint.constant == [self totalWidthOfButtons]) {
        return;
    }
    //Animate bounce of cell past and back to catch point
    self.contentViewLeftConstraint.constant = -[self totalWidthOfButtons] - myBounceValue;
    self.contentViewRightConstraint.constant = [self totalWidthOfButtons] + myBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //Snap cell to catch point
        self.contentViewLeftConstraint.constant = -[self totalWidthOfButtons];
        self.contentViewRightConstraint.constant = [self totalWidthOfButtons];
        
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
                    CGFloat constant = MIN(-deltaX, [self totalWidthOfButtons]);
                    //Open cell to catch point calculated in buttonTotalWidth
                    if (constant == [self totalWidthOfButtons]) {
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
                    CGFloat constant = MIN(adjustment, [self totalWidthOfButtons]);
                    //Cell is open to the catch point
                    if (constant == [self totalWidthOfButtons]) {
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
            //Check if cell is open or closed
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was opening, slide rest of the way if half way through delete
                CGFloat halfOfDelete = CGRectGetWidth(self.deleteButton.frame) / 2;
                if (self.contentViewRightConstraint.constant >= halfOfDelete) {
                    //Open cell all the way to catch point
                    [self setShowButtonsConstraints:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing, slide rest of way if half way through edit
                CGFloat deletePlusHalfOfEdit = CGRectGetWidth(self.deleteButton.frame) + (CGRectGetWidth(self.editButton.frame) / 2);
                if (self.contentViewRightConstraint.constant >= deletePlusHalfOfEdit) {
                    //Re-open all the way
                    [self setShowButtonsConstraints:YES notifyDelegateDidOpen:YES];
                } else {
                    //Snap cell closed
                    [self resetConstraintToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.startingRightLayoutConstraintConstant == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setShowButtonsConstraints:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
} //panContentCell close

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

#pragma mark - UIGestureRecognizerDelegate

//Fix potential scroll gesture interferance issues while using pan gesture recognizer
//Tells the gesture recognizers that they can both work at the same time. Also from raywenderlich.com tut
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
