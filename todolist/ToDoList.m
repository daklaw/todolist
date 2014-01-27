//
//  ToDoList.m
//  todolist
//
//  Created by David Law on 1/26/14.
//  Copyright (c) 2014 David Law. All rights reserved.
//

#import "ToDoList.h"

@implementation ToDoList

- (id)initWithNSMutableArray:(NSMutableArray *)array {
    if (self = [super init]) {
        self.list = array;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.list = [aDecoder decodeObjectForKey:@"list"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.list forKey:@"list"];
}
@end
