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

#import "CustomTableViewController.h"
#import "CustomPFLoginViewController.h"

@interface CustomTableViewController ()

@end

@implementation CustomTableViewController
 
- (void)viewDidLoad {
//    //Test parse
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"foo"] = @"bar";
//    [testObject saveInBackground];
    
    //Create and add sign out button
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(onLogOut:)];
    self.navigationItem.leftBarButtonItem = signOutButton;
    
    //Create and add new item plus button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addNewItem:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    //Check if user already logged in, present login view if not
    [self isUserLoggedIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Check if a user is signed in, present login view if not.
-(void)isUserLoggedIn {
    if(![PFUser currentUser]) {
        //Instantiate view controllers for login and signup
        CustomPFLoginViewController *loginViewController = [[CustomPFLoginViewController alloc] init];
        [loginViewController setDelegate:self];
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        
        //Link sign up to be displayed from login
        [loginViewController setSignUpController:signUpViewController];
        
        //Present login view controller
        [self presentViewController:loginViewController animated:YES completion:NULL];
    } else {
        NSLog(@"User auto-logged in");
        //Reload objects from parse
        [self loadObjects];
    } 
}

//Log user out. Hooked/triggered by logout button
-(IBAction)onLogOut:(id)sender {
    [PFUser logOut];
    [self isUserLoggedIn];
    //Clear tableview of all objects
    [self clear];
}

-(IBAction)addNewItem:(id)sender {
    NSLog(@"plus clicked");
}

#pragma mark - PFQueryTableViewController

//Init tableview and set params
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        // The className to query on
        self.parseClassName = @"newItem";
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        // The title for this table in the Navigation Controller.
        self.title = @"My Contacts";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
//        //Whether the built-in pagination is enabled
//        self.paginationEnabled = YES;
//        //The number of objects to show per page
//        self.objectsPerPage = 5;
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)aCoder
//{
//    self = [super initWithCoder:aCoder];
//    if (self) {
//        NSLog(@"Self!!");
//        // The className to query on
//        //self.parseClassName = @"newItem";
//        self.parseClassName = @"newItem";
//        
//        // The key of the PFObject to display in the label of the default cell style
//        self.textKey = @"text";
//        
//        // Whether the built-in pull-to-refresh is enabled
//        self.pullToRefreshEnabled = YES;
//        
//        // Whether the built-in pagination is enabled
//        self.paginationEnabled = NO;
//    }
//    return self;
//}

//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell
    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@", [object objectForKey:@"Name"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Phone Number: %@", [object objectForKey:@"Number"]];
    return cell;
}

//Override query to display notice if no items found for the user
- (PFQuery *)queryForTable {
    PFQuery *newItemQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    //Set cache policy to network only
    if ([self.objects count] == 0) {
        newItemQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    //NSLog(@"Query = %ld", (long)query.countObjects);
    [newItemQuery orderByAscending:@"createdAt"];
    return newItemQuery;
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"All fields are required! Please fill out both fields and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

@end
