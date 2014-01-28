//
//  ToDoViewController.m
//  todo
//
//  Created by David Law on 1/25/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "ToDoViewController.h"
#import "EditableCell.h"
#import "ToDoList.h"

@interface ToDoViewController ()


//@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSInteger *counter;

- (void) onAddButton;
- (void) onEditButton;
- (void) onDoneButton;
- (void) onCancelButton;
- (void) unsetEditButton;
- (void) saveDataToDisk;
- (void) loadDataFromDisk;
- (NSString *) getDataPath;

@end

@implementation ToDoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"To-Do List";
    
    UINib *customNib = [UINib nibWithNibName:@"EditableCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"EditableCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
    
    // Look if data file exists.  If it does, load data from there, else initialize a fresh To Do List
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getDataPath]]) {
        [self loadDataFromDisk];
    }
    else {
        self.todolist = [[ToDoList alloc] initWithNSMutableArray:[NSMutableArray new]];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.todolist.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // static NSString *CellIdentifier = @"Cell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    static NSString *CellIdentifier = @"EditableCell";
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.itemTextView.text = self.todolist.list[indexPath.row];
    cell.itemTextView.delegate = self;
    cell.itemTextView.tag = indexPath.row;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If ADDROW exists and we're rendering the first row, make it becomeFirstResponder
    if ([defaults boolForKey:@"ADDROW"] && indexPath.row == 0) {
        [cell.itemTextView becomeFirstResponder];

    }
    // Configure the cell...
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.todolist.list removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self saveDataToDisk];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // Called when textView begins editing
    
    // Establish new navigation buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:textView.tag forKey:@"ROWEDITED"];
    [defaults synchronize];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"CANCELEDIT"]) {
        if ([textView.text length] > 0) {
            [self.todolist.list replaceObjectAtIndex:[defaults integerForKey:@"ROWEDITED"] withObject:textView.text];
        }
        else if (textView.tag == 0 && [defaults boolForKey:@"ADDROW"]){
            [self.todolist.list removeObjectAtIndex:[defaults integerForKey:@"ROWEDITED"]];
        }
    }
    
    // Clean up all the NSUserDefault flags
    [defaults removeObjectForKey:@"CANCELEDIT"];
    [defaults removeObjectForKey:@"ADDROW"];
    [defaults removeObjectForKey:@"ROWEDITED"];
    [defaults synchronize];
    
    // Reestablish the old navigation items
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
    
    // Reload data and save to disk
    [self.tableView reloadData];
    [self saveDataToDisk];
}

- (void) onDoneButton {
    [self.tableView endEditing:YES];
}



- (void) onCancelButton {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:YES forKey:@"CANCELEDIT"];
    [self.tableView endEditing:YES];
}

- (void) onAddButton {
    [self.todolist.list insertObject:@"" atIndex:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Set the ADDROW boolean to indicate that we are currently adding a row
    [defaults setBool:YES forKey:@"ADDROW"];
    [defaults synchronize];
    
    [self.tableView reloadData];
}

- (void) onEditButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(unsetEditButton)];
    [self.tableView setEditing:YES animated:YES];
}

- (void) unsetEditButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
    [self.tableView setEditing:NO animated:YES];
}

- (void) saveDataToDisk {
    // Save our ToDoList NSMutableArray via NSKeyedArchiver
    NSString *path = [self getDataPath];
    
    [NSKeyedArchiver archiveRootObject:self.todolist toFile:path];
}

- (void) loadDataFromDisk {
    // Load Data saved from the last time saveDataToDisk was called
    self.todolist = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getDataPath]];
}

- (NSString *) getDataPath {
    // Method returns the path of our data file (which will store our ToDoList)
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:@"data.archive"];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
