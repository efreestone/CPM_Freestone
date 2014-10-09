// Elijah Freestone
// CPM 1410
// Week 2
// October 9th, 2014

//
//  AddNewItemViewController.m
//  Project2iOS
//
//  Created by Elijah Freestone on 10/9/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "AddNewItemViewController.h"

@interface AddNewItemViewController ()

@end

@implementation AddNewItemViewController {
    NSString *nameEntered;
    NSString *numberEntered;
}

@synthesize nameTextField, numberTextField;

- (void)viewDidLoad {
    //Create and add done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(saveNewItem:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Save new item to Parse and dismiss view
-(IBAction)saveNewItem:(id)sender {
    //NSLog(@"Done button clicke");
    nameEntered = nameTextField.text;
    numberEntered = numberTextField.text;
    
    if (![nameEntered isEqualToString:@""] && ![numberEntered isEqualToString:@""]) {
//        NSLog(@"Name: %@", nameEntered);
//        NSLog(@"Number: %@", numberEntered);
        NSInteger numberEnteredInt = [numberEntered integerValue];
        
        PFObject *newItem = [PFObject objectWithClassName:@"newItem"];
        newItem[@"Name"] = nameEntered;
        newItem[@"Number"] = [NSNumber numberWithInteger:numberEnteredInt];
        [newItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"New item saved.");
                [self.navigationController popViewControllerAnimated:true];
            } else {
                NSLog(@"%@", error);
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        }];
    } else {
        NSLog(@"Fields blank");
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"All fields are required! Please fill out both fields and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
