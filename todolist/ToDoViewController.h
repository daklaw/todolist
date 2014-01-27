//
//  ToDoViewController.h
//  todo
//
//  Created by David Law on 1/25/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoList.h"

@interface ToDoViewController : UITableViewController <UITextViewDelegate>

@property (nonatomic, strong) ToDoList *todolist;

@end
