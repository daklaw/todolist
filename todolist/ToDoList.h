//
//  ToDoList.h
//  todolist
//
//  Created by David Law on 1/26/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoList : NSObject

@property (nonatomic, strong) NSMutableArray *list;

- (id)initWithNSMutableArray:(NSMutableArray *)array;

@end
