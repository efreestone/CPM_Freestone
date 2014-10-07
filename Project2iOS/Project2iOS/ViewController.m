// Elijah Freestone
// CPM 1410
// Week 2
// October 3rd, 2014

//
//  ViewController.m
//  Project2iOS
//
//  Created by Elijah Freestone on 10/3/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
 
- (void)viewDidLoad {
//    //Test parse
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar";
//    [testObject saveInBackground];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    //Check if a user is signed in, present login view if not.
    if(![PFUser currentUser]) { 
        //Instantiate login view controller
        PFLogInViewController *loginViewController = [[PFLogInViewController alloc] init];
        [loginViewController setDelegate:self];
        
        //Instantiate sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        //Link sign up to be displayed from login
        [loginViewController setSignUpController:signUpViewController];
        
        //Present login view controller
        [self presentViewController:loginViewController animated:YES completion:NULL];
    } else {
        NSLog(@"User auto-logged in");
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
