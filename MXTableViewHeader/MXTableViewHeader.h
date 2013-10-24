//
//  MXTableViewHeader.h
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXTableViewHeader : UIView

@end

@interface UITableView (MXTableViewHeader)

@property (nonatomic, assign) BOOL headerLock;

- (void)addTableViewHeader:(UIView *)header preLoadBlock:(void (^)(float trigPersent))preLoadBlock triggeredBlock:(void (^)(void))triggeredBlock loadingBlock:(void (^)(void))loadingBlock;

- (void)stopAnimation;
- (void)startAnimation;

@end