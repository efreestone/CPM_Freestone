// Elijah Freestone
// CPM 1410
// Week 4
// October 17th, 2014

//
//  ViewController.h
//  Project4iOS
//
//  Created by Elijah Freestone on 10/17/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CustomTableViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

-(IBAction)onLogOut:(id)sender;


@end

