//
//  MXTableViewHeader.h
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    MXTableViewHeaderStateNormal = 0,
    MXTableViewHeaderStatePreload,
    MXTableViewHeaderStateLoading,
    MXTableViewHeaderStateFinish
} MXTableViewHeaderState;

@interface UITableView (MXTableViewHeader)

typedef void (^MXTableViewHeaderBlock)(MXTableViewHeaderState state, float dragPercent);

- (void)addTableViewHeader:(UIView *)header stateBlock:(MXTableViewHeaderBlock)block;

- (void)stopRefresh;
- (void)startRefresh;

@end
