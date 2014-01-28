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

- (void) onAddButton;
- (void) onEditButton;
- (void) onDoneButton;
- (void) onCancelButton;
- (void) unsetEditButton;
- (void) saveDataToDisk;
- (void) loadDataFromDisk;
- (NSString *) getDataPath;
- (void)scrollToCursorForTextView: (UITextView*)textView;
- (BOOL)rectVisible: (CGRect)rect;

@end

@implementation ToDoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.todolist.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // check here, if it is one of the cells, that needs to be resized
    // to the size of the contained UITextView

    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditableCell"];
    UITextView *textView = cell.itemTextView;
    textView.text = self.todolist.list[indexPath.row];
    textView.tag = indexPath.row;
    
    CGRect expectedFrame = [textView.text boundingRectWithSize:CGSizeMake(250, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                            textView.font, NSFontAttributeName,
                                                                            nil]
                                                                   context:nil];
    return expectedFrame.size.height + 15.0;
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

- (void)textViewDidChange:(UITextView *)textView {
    [self.todolist.list replaceObjectAtIndex:textView.tag withObject:textView.text];
    [self.tableView beginUpdates]; // This will cause an animated update of
    [self.tableView endUpdates];   // the height of your UITableViewCell
    
    // If the UITextView is not automatically resized (e.g. through autolayout
    // constraints), resize it here
    
    [self scrollToCursorForTextView:textView]; // OPTIONAL: Follow cursor
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return !self.tableView.editing;
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    // Called when textView begins editing
    
    // Establish new navigation buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:textView.tag forKey:@"ROWEDITED"];
    [defaults synchronize];
    [self scrollToCursorForTextView:textView];
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
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView setEditing:YES animated:YES];
}

- (void) unsetEditButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onEditButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButton)];
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

- (void)scrollToCursorForTextView: (UITextView*)textView {
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

@end
