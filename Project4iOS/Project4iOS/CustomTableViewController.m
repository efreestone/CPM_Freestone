// Elijah Freestone
// CPM 1410
// Week 4
// October 17th, 2014

//
//  ViewController.m
//  Project4iOS
//
//  Created by Elijah Freestone on 10/17/14.
//  Copyright (c) 2014 Elijah Freestone. All rights reserved.
//

#import "CustomTableViewController.h"
#import "CustomPFLoginViewController.h"
#import "CustomPFSignUpViewController.h"
#import "AddNewItemViewController.h"
#import "CustomTableViewCell.h"
//Import Apple Reachability
#import "Reachability.h"

@interface CustomTableViewController () <CustomSwipeCellDelegate> {
    UILabel *noticeLabel;
    NSString *formattedPhoneNumber;
    NSString *parseClassName;
    NSIndexPath *itemIndexPath;
    NSUInteger itemIndexInteger;
}

@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;

@end

@implementation CustomTableViewController

- (void)viewDidLoad {
    //Register custom cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    //self.tableView.estimatedRowHeight = 89;
    self.tableView.rowHeight = 44;
    
    //Create list for cells being edited
    self.cellsCurrentlyEditing = [NSMutableSet new];
    
    float viewWidth = self.view.frame.size.width;
    //Create notice label to display if no items exist for the user.
    noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 30.0f, viewWidth, 50.0f)];
    noticeLabel.text = @"No contacts to display. Please select the plus button to add a contact.";
    noticeLabel.textAlignment = NSTextAlignmentCenter;
    noticeLabel.numberOfLines = 2;
    //noticeLabel.backgroundColor = [UIColor greenColor];
    noticeLabel.hidden = true;
    [self.view addSubview:noticeLabel];
    
    //Grab middle measurement and adjust to align better with custom cell
    float viewMiddle = (viewWidth/2) + 4.0f;
    //Create header for table view
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewWidth, 25.0f)];
    tableHeader.backgroundColor = [UIColor lightGrayColor];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, viewMiddle, 25.0f)];
    nameLabel.text = @"Name";
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewMiddle, 0.0f, viewMiddle, 25.0f)];
    numberLabel.text = @"Phone Number";
    [tableHeader addSubview:nameLabel];
    [tableHeader addSubview:numberLabel];
    [self.tableView setTableHeaderView:tableHeader];
    self.tableView.allowsSelection = NO;
    
    //Override to remove extra seperator lines after the last cell, no lines appear if no objects exist
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)]];
    
    //Create and add sign out button
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(onLogOut:)];
    self.navigationItem.leftBarButtonItem = logOutButton;
    
    //Create and add new item plus button
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addNewItem:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    //Set default ACL to be read/write of current user only
    PFACL *defaultACL = [PFACL ACL];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    if ([self.tableView respondsToSelector:@selector(separatorInset)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
} //viewDidLoad close

- (void)viewDidAppear:(BOOL)animated {
    //Check if user already logged in, present login view if not
    //[self isUserLoggedIn];
    [self checkConnection];
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
        CustomPFSignUpViewController *signUpViewController = [[CustomPFSignUpViewController alloc] init];
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
} //isUserLoggedIn close

//Log user out. Hooked/triggered by logout button
-(IBAction)onLogOut:(id)sender {
    [PFUser logOut];
    [self isUserLoggedIn];
    //Clear tableview of all objects
    [self clear];
}

//Push add item view controller. Hooked/triggered by plus button
-(IBAction)addNewItem:(id)sender {
    NSLog(@"plus clicked");
    AddNewItemViewController *addNewViewController = [[AddNewItemViewController alloc] init];
    [self.navigationController pushViewController:addNewViewController animated:true];
}

#pragma mark - PFQueryTableViewController

//Use initWithCoder instead of initWithStyle to use my own stroyboard.
//This was not working in project 2 because parseClassName wasn't being set properly
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        // The className to query on
        self.parseClassName = @"newItem";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // The title for this table in the Navigation Controller.
        self.title = @"My Contacts";
        
        // Whether the built-in pagination is enabled
        //self.paginationEnabled = NO;
        // The number of objects to show per page
        //self.objectsPerPage = 25;
    }
    return self;
}

//Set up cells and apply objects from Parse
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    //NSLog(@"cellForRow");
    static NSString *cellId = @"Cell";
    CustomTableViewCell *customCell = (CustomTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    //SwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (customCell == nil) {
        //Allocate custom cell
        customCell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    customCell.delegate = self;
    
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [customCell openCell];
    }
    
    if (self.objects.count == 0) {
        NSLog(@"Object Count = 0");
    }
    
    //Grab number from parse to format
    NSNumber *phoneNumber = [object objectForKey:@"Number"];
    //Pass NSNumber to formatting method.
    [self formatPhoneNumber:phoneNumber];
    // Configure the cell
    customCell.nameCellLabel.text = [NSString stringWithFormat:@"    %@", [object objectForKey:@"Name"]];
    customCell.numberCellLabel.text = [NSString stringWithFormat:@"%@", formattedPhoneNumber];
    
    return customCell;
} //cellForRowAtIndexPath close

//Custom method to reform phone number in (xxx)xxx-xxxx format.
-(void)formatPhoneNumber:(NSNumber *)phoneNumber {
    NSString *numberString = [phoneNumber stringValue];
    NSMutableString *mutableNumberString = [NSMutableString stringWithString:numberString];
    if (mutableNumberString.length == 10) {
        [mutableNumberString insertString:@"(" atIndex:0];
        [mutableNumberString insertString:@")" atIndex:4];
        [mutableNumberString insertString:@"-" atIndex:8];
    }
    
    //NSLog(@"Phone: %@", mutableNumberString);
    formattedPhoneNumber = mutableNumberString;
}

//Override query to set cache policy an change sort
- (PFQuery *)queryForTable {
    //Make sure parseClassName is set
    //This is why using my storyboard wasn't working in project 2.
    if (!self.parseClassName) {
        self.parseClassName = @"newItem";
    }
    PFQuery *newItemQuery = [PFQuery queryWithClassName:self.parseClassName];
    
    //Set cache policy to network only
    if ([self.objects count] == 0) {
        newItemQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    //Set sort
    [newItemQuery orderByAscending:@"createdAt"];
    return newItemQuery;
} //queryForTable close

//Override did load to hide/display notice label
-(void)objectsDidLoad:(NSError *)error {
    if (self.objects.count == 0) {
        //No objects for user, show notice label
        noticeLabel.hidden = false;
    } else {
        //Hide label if an object exists for the user
        noticeLabel.hidden = true;
    }
    [super objectsDidLoad:error];
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.objects.count;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
//    //[tableView setEditing:YES animated:YES];
//    itemIndexPath = indexPath;
//    itemIndexInteger = indexPath.row;
//    NSLog(@"index int: %lu", (unsigned long)itemIndexInteger);
//}

//Built in function to check editing style (-=delete, +=add)
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Grab object to delete and delete in background
        PFObject *objectToDelete = [self.objects objectAtIndex:indexPath.row];
        [objectToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //Reload objects for user
            [self loadObjects];
        }];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"Edit");
    }
} //commitEditingStyle close

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"All fields are required! Please fill out both fields and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    return NO; // Interrupt login process
} //logInViewController close

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login Failed! Please check your username and/or password and try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
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
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"All fields are required! Please fill out both fields and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    return informationComplete;
} //signUpViewController close

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

#pragma mark - Connection Management

//Custom method to check internet connection. Moves on to check login if exists
-(void)checkConnection {
    //Check connectivity before sending twitter request. Modified/refactored from Apple example
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currentNetworkStatus = [networkReachability currentReachabilityStatus];
    //If connection failed
    if (currentNetworkStatus == NotReachable) {
        NSLog(@"No Connection!");
        //Show no connection alert
        [self noConnectionAlert];
    } else {
        NSLog(@"Internet Connection Exists");
        [self isUserLoggedIn];
    }
} //checkConnection close

//Method to create and show alert view if there is no internet connectivity
-(void)noConnectionAlert {
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"No Connection!" message:@"There is no Internet Connection. Please turn on WiFi and tap Retry." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [connectionAlert show];
} //noConnectionAlert close

#pragma mark - CustomSwipeCellDelegate

- (void)deleteButtonActionForCell {
    //NSLog(@"In the delegate, Clicked delete for %lu", (unsigned long)itemIndexInteger);
    //Grab object to delete and delete in background
    PFObject *objectToDelete = [self.objects objectAtIndex:itemIndexInteger];
    NSLog(@"Name: %@", objectToDelete);
    [objectToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //Reload objects for user
        [self loadObjects];
    }];
}

- (void)editButtonTwoActionForCell {
    NSLog(@"In the delegate, Clicked edit for %lu", (unsigned long)itemIndexInteger);
}

//Get open cells
- (void)cellDidOpen:(UITableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
    //Pass index path of cell
    itemIndexInteger = currentEditingIndexPath.row;
}

- (void)cellDidClose:(UITableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

@end

