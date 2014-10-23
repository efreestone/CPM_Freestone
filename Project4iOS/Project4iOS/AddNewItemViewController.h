// Elijah Freestone
// CPM 1410
// Week 4
// October 17th, 2014

//
//  AddNewItemViewController.h
//  Project4iOS
//
//  Created by Elijah Freestone on 10/17/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <Parse/Parse.h>

@interface AddNewItemViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *numberTextField;
@property (strong, nonatomic) NSString *objectID;
@property (strong, nonatomic) NSString *passedName;
@property (strong, nonatomic) NSString *passedNumber;

@end
