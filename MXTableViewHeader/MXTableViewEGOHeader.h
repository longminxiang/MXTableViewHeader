//
//  MXTableViewEGOHeader.h
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-25.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXTableViewHeader.h"

@interface UITableView (MXTableViewEGOHeader)

- (void)addEGOTableViewHeaderWithBlock:(void (^)(void))block;

@end