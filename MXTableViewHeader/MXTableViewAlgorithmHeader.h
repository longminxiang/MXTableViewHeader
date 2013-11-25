//
//  MXTableViewAlgorithmHeader.h
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-30.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXTableViewHeader.h"

@interface UITableView (MXTableViewAlgorithmHeader)

- (void)addAlgorithmHeaderWithBlock:(void (^)(void))block;

@end
