// Elijah Freestone
// CPM 1410
// Week 2
// October 9th, 2014

//
//  CustomPFSignUpViewController.m
//  Project2iOS
//
//  Created by Elijah Freestone on 10/9/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "CustomPFSignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomPFSignUpViewController ()

@end

@implementation CustomPFSignUpViewController

@synthesize fieldsBackground;

- (void)viewDidLoad {
    //Check device type and set background accordingly
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginBackground-568h.png"]]];
        //NSLog(@"is iPhone");
        [self.signUpView setLogo:nil];
    } else {
        [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginBackground~iPad.png"]]];
        [self.signUpView setLogo:nil];
    }
    
    // Add login field background
    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SignUpFieldBG.png"]];
    [self.signUpView insertSubview:fieldsBackground atIndex:1];
    // Remove text shadow
    CALayer *layer = self.signUpView.usernameField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.passwordField.layer;
    layer.shadowOpacity = 0.0f;
    layer = self.signUpView.emailField.layer;
    layer.shadowOpacity = 0.0f; 
    
    // Set field text color
    [self.signUpView.usernameField setTextColor:[UIColor colorWithRed:0.361 green:0.29 blue:0.337 alpha:1]]; /*#5c4a56*/
    [self.signUpView.passwordField setTextColor:[UIColor colorWithRed:0.361 green:0.29 blue:0.337 alpha:1]]; /*#5c4a56*/
    [self.signUpView.emailField setTextColor:[UIColor colorWithRed:0.361 green:0.29 blue:0.337 alpha:1]]; /*#5c4a56*/
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//Set frames for overide items (login field, etc)
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Check device type
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // Set frame for elements in iPhone
        [self.signUpView.usernameField setFrame:CGRectMake(35.0f, 105.0f, 250.0f, 50.0f)];
        [self.signUpView.passwordField setFrame:CGRectMake(35.0f, 150.0f, 250.0f, 50.0f)];
        [self.signUpView.emailField setFrame:CGRectMake(35.0f, 197.0f, 250.0f, 50.0f)];
        [self.fieldsBackground setFrame:CGRectMake(35.0f, 100.0f, 250.0f, 150.0f)];
        [self.signUpView.signUpButton setFrame:CGRectMake(35.0f, 300.0f, 250.0f, 40.0f)];
    } else {
        //Set frame for iPad elements
        [self.signUpView.usernameField setFrame:CGRectMake(260.0f, 412.0f, 250.0f, 50.0f)];
        [self.signUpView.passwordField setFrame:CGRectMake(260.0f, 460.0f, 250.0f, 50.0f)];
        [self.signUpView.emailField setFrame:CGRectMake(260.0f, 508.0f, 250.0f, 50.0f)];
        [self.fieldsBackground setFrame:CGRectMake(258.0f, 410.0f, 250.0f, 150.0f)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
