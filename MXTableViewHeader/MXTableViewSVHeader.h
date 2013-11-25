//
//  MXTableViewSVHeader.h
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-28.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXTableViewHeader.h"

@interface UITableView (MXTableViewSVHeader)

- (void)addSVTableViewHeaderWithBlock:(void (^)(void))block;

@end
