// Elijah Freestone
// CPM 1410
// Week 4
// October 17th, 2014

//
//  AddNewItemViewController.m
//  Project4iOS
//
//  Created by Elijah Freestone on 10/17/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "AddNewItemViewController.h"

@interface AddNewItemViewController ()

@end

@implementation AddNewItemViewController {
    NSString *nameEntered;
    NSString *numberEntered;
}

//Synthesize for getters/setters
@synthesize nameTextField, numberTextField;

- (void)viewDidLoad {
    //Create and add done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(saveNewItem:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
//    [numberTextField addTarget:self action:@selector(textFieldDidChange:changeCharInRange:replaceString:) forControlEvents:UIControlEventValueChanged];
    
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
        NSString *pureNumbers = [[numberEntered componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        //Cast number string to integer
        NSInteger numberEnteredInt = [pureNumbers integerValue];
        
        PFObject *newItem = [PFObject objectWithClassName:@"newItem"];
        newItem[@"Name"] = nameEntered;
        newItem[@"Number"] = [NSNumber numberWithInteger:numberEnteredInt];
        [newItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"New item saved.");
                //Dismiss add item view
                [self.navigationController popViewControllerAnimated:true];
            } else {
                NSLog(@"%@", error);
                //Error alert
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occured trying to save. Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        }];
    } else {
        NSLog(@"Fields blank");
        //Alert the user of missing fields
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"All fields are required! Please fill out both fields and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    
}

- (IBAction)formatPhoneNumberAsEntered:(id)sender {
    numberEntered = numberTextField.text;
    if (numberEntered.length != 0) {
        //Create mutable string with digit chat set to be manipulated and displayed as number entered
        NSMutableString *formattedNumber = [NSMutableString stringWithString:[[numberTextField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""]];
        
        //Check for zero or one as first number entered
        if (formattedNumber.length == 1 && [formattedNumber hasPrefix:@"0"]) {
            NSLog(@"Zero");
        }
        if (formattedNumber.length == 1 && [formattedNumber hasPrefix:@"1"]) {
            NSLog(@"One");
        }
        
        //Formatting in (xxx)xxx-xxxx with no space after )
        if (formattedNumber.length > 1) {
            [formattedNumber insertString:@"(" atIndex:0];
        }
        if (formattedNumber.length > 4)
            //Change to index 5 and add space after ) for (xxx) xxx-xxxx
            [formattedNumber insertString:@")" atIndex:4];
        
        if (formattedNumber.length > 8)
            //Change to index 9 for (xxx) xxx-xxxx
            [formattedNumber insertString:@"-" atIndex:8];
        
        //Stop number input at 10 digits
        if (formattedNumber.length > 13) {
            formattedNumber = [NSMutableString stringWithString:[formattedNumber substringToIndex:13]];
            //numberEntered = text;
            NSLog(@"Number over 10 digits");
        }
        
        numberTextField.text = formattedNumber;
    }
}

@end

