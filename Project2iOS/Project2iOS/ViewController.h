// Elijah Freestone
// CPM 1410
// Week 2
// October 3rd, 2014

//
//  ViewController.h
//  Project2iOS
//
//  Created by Elijah Freestone on 10/3/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

-(IBAction)onLogOut:(id)sender;


@end

