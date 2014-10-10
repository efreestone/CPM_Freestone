//
//  CustomCellTableViewCell.m
//  Project2iOS
//
//  Created by Elijah Freestone on 10/9/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

//Synthesize for getters/setters
@synthesize nameCellLabel, numberCellLabel;

- (void)awakeFromNib {
    // Initialization code
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

@end
