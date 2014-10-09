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

@implementation AddNewItemViewController

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
    NSLog(@"Done button clicke");
    [self.navigationController popViewControllerAnimated:true];
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
