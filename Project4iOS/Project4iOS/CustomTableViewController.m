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
    NSString *noConnectionMessage;
    NSString *editDeleteAlertMessage;
    NSTimer *pollTimer;
    CustomTableViewCell *customCell;
}

@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;

@end

@implementation CustomTableViewController

- (void)viewDidLoad {
    //Register custom cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    //self.tableView.estimatedRowHeight = 89;
    //Set tableview height to stop autolayout from resizing cells. Also stops ambiguous constraints warning
    self.tableView.rowHeight = 44;
    
    noConnectionMessage = @"No network connection. Only contacts saved on your device will be available to view.";
    editDeleteAlertMessage = @"Contacts can not be added, edited, or deleted without a network connection.";
    
    //Create list for cells being edited
    self.cellsCurrentlyEditing = [NSMutableArray new];
    
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
    //Stop highlighting of selected rows. Doesn't work from storyboard in this case for some reason
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
    
    self.title = @"My Contacts";
    
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
    if (![self checkConnection]) {
        [self noConnectionAlert:noConnectionMessage];
    }
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
        //Start poll timer set to 20 sec
        [[NSRunLoop mainRunLoop] addTimer:self.createTimer forMode:NSRunLoopCommonModes];
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
    if ([self checkConnection]) {
        AddNewItemViewController *addNewViewController = [[AddNewItemViewController alloc] init];
        [self.navigationController pushViewController:addNewViewController animated:true];
    } else {
        //Show no connection alert
        [self noConnectionAlert:editDeleteAlertMessage];
    }
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
    }
    return self;
}

//Set up cells and apply objects from Parse
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    //NSLog(@"cellForRow");
    static NSString *cellId = @"Cell";
    customCell = (CustomTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
    
    //SwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (customCell == nil) {
        //Allocate custom cell
        customCell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    customCell.delegate = self;
    
//    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
//        [customCell openCell];
//        NSLog(@"Contains indexPath");
//    }
    
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
        newItemQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
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
    if (![self checkConnection]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"A network connection is required to sign in or create an account. Please check your network connection and try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        [PFUser logOut];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Login Failed! Please check your username and/or password and try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dismissed the logInViewController");
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    if (![self checkConnection]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"A network connection is required to sign in or create an account. Please check your network connection and try again", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        [PFUser logOut];
    } else {
        // loop through all of the submitted data
        for (id key in info) {
            NSString *field = [info objectForKey:key];
            if (!field || !field.length) { // check completion
                informationComplete = NO;
                break;
            }
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
-(BOOL)checkConnection { 
    BOOL connectionExists;
    //Check connectivity before sending twitter request. Modified/refactored from Apple example
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus currentNetworkStatus = [networkReachability currentReachabilityStatus];
    //If connection failed
    if (currentNetworkStatus == NotReachable) {
        connectionExists = NO;
        NSLog(@"No Connection!");
    } else {
        connectionExists = YES;
        NSLog(@"Internet Connection Exists");
        //Check user if connection exists. Eventually triggers query
        [self isUserLoggedIn];
    }
    return connectionExists;
} //checkConnection close

//Create timer to poll Parse every 20 sec
-(NSTimer *)createTimer {
    if (!pollTimer) {
        pollTimer = [NSTimer timerWithTimeInterval:20.0 target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
    }
    return pollTimer;
}

//Call queryParse with poll timer
-(void)onTimerTick:(NSTimer*)timer {
    if ([self checkConnection]) {
        [self queryForTable];
    }
    
    NSLog(@"Start Poll Timer");
}

//Method to create and show alert view if there is no internet connectivity
-(void)noConnectionAlert:(NSString *)alertMessage {
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"No Connection!" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //Show alert
    [connectionAlert show];
} //noConnectionAlert close

#pragma mark - CustomSwipeCellDelegate

//Delete object from parse. Fired from delete button under swipeable cell
- (void)deleteButtonActionForCell {
    if ([self checkConnection]) {
        //NSLog(@"In the delegate, Clicked delete for %lu", (unsigned long)itemIndexInteger);
        //Grab object to delete and delete in background
        PFObject *objectToDelete = [self.objects objectAtIndex:itemIndexInteger];
        NSLog(@"Name: %@", objectToDelete);
        [objectToDelete deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //Reload objects for user
            [self loadObjects];
        }];
    } else {
        //Show no connection alert
        [self noConnectionAlert:editDeleteAlertMessage];
    }
}

//Edit object. Fired from edit button under swipeable cell
- (void)editButtonTwoActionForCell {
    if ([self checkConnection]) {
        //NSLog(@"In the delegate, Clicked edit for %lu", (unsigned long)itemIndexInteger);
        PFObject *objectToEdit = [self.objects objectAtIndex:itemIndexInteger];
        AddNewItemViewController *addNewViewController = [[AddNewItemViewController alloc] init];
        
        addNewViewController.passedName = [NSString stringWithFormat:@"%@", [objectToEdit objectForKey:@"Name"]];
        addNewViewController.passedNumber = [NSString stringWithFormat:@"%@", [objectToEdit objectForKey:@"Number"]];
        addNewViewController.objectID = [NSString stringWithFormat:@"%@", objectToEdit.objectId];
        [self.navigationController pushViewController:addNewViewController animated:true];
    } else {
        //Show no connection alert
        [self noConnectionAlert:editDeleteAlertMessage];
    }
}

//Get open cells
- (void)cellDidOpen:(CustomTableViewCell *)cell {
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Current Index: %@", currentEditingIndexPath);
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
    //Pass index path of cell
    itemIndexInteger = currentEditingIndexPath.row;
    
    //Check if more than 1 cell is open, close first opened if more than 1
    //open a cell and open another, the first is closed automatically
    if (self.cellsCurrentlyEditing.count >= 2) {
        //NSLog(@"intPath: %ld", (long)intPath);
        NSIndexPath *firstCellIndex = [self.cellsCurrentlyEditing firstObject];
        //NSLog(@"firstCellIndex: %@", firstCellIndex);
        CustomTableViewCell *firstCellOpen = (CustomTableViewCell *)[self.tableView cellForRowAtIndexPath:firstCellIndex];
        [firstCellOpen resetConstraintToZero:YES notifyDelegateDidClose:NO];
        [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:firstCellOpen]];
        firstCellOpen = nil;
        firstCellIndex = nil;
    }
    
}

- (void)cellDidClose:(CustomTableViewCell *)cell {
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

@end

