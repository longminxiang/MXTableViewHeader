//
//  MXTableViewHeader.m
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "MXTableViewHeader.h"
#import <objc/runtime.h>

@interface UITableView (MXTableViewHeaderPrivate)

@property (nonatomic, assign) BOOL trigLock;
@property (nonatomic, assign) BOOL loadingLock;
@property (nonatomic, strong) UIView *mxHeaderView;
@property (nonatomic, copy) MXTableViewHeaderBlock stateBlock;

@end

@implementation UITableView (MXTableViewHeaderPrivate)

static const char *trigLockKey = "trigLock";
static const char *loadingLockKey = "loadingLock";
static const char *mxHeaderViewKey = "mxHeaderView";
static const char *stateBlockKey = "stateBlock";

@dynamic trigLock,loadingLock,stateBlock,mxHeaderView;

- (BOOL)trigLock
{
    return [objc_getAssociatedObject(self, trigLockKey) boolValue];
}

- (void)setTrigLock:(BOOL)trigLock
{
    objc_setAssociatedObject(self, trigLockKey, [NSNumber numberWithBool:trigLock], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)loadingLock
{
    return [objc_getAssociatedObject(self, loadingLockKey) boolValue];
}

- (void)setLoadingLock:(BOOL)loadingLock
{
    objc_setAssociatedObject(self, loadingLockKey, [NSNumber numberWithBool:loadingLock], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)mxHeaderView
{
    return objc_getAssociatedObject(self, mxHeaderViewKey);
}

- (void)setMxHeaderView:(UIView *)mxHeaderView
{
    objc_setAssociatedObject(self, mxHeaderViewKey, mxHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MXTableViewHeaderBlock)stateBlock
{
    return objc_getAssociatedObject(self, stateBlockKey);
}

- (void)setStateBlock:(MXTableViewHeaderBlock)stateBlock
{
    objc_setAssociatedObject(self, stateBlockKey, stateBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UITableView (MXTableViewHeader)

#define SlideSpeed 240.0f
#define headerHeight 60

- (void)addTableViewHeader:(UIView *)header stateBlock:(MXTableViewHeaderBlock)block
{
    self.loadingLock = NO;
    self.trigLock = NO;
    self.stateBlock = block;
    self.mxHeaderView = header;
    [self addSubview:self.mxHeaderView];
}

- (void)stopRefresh
{
    self.loadingLock = NO;
    self.trigLock = NO;
    [UIView animateWithDuration:headerHeight / SlideSpeed delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setContentInset:UIEdgeInsetsZero];
    } completion:^(BOOL finished) {
    }];
    if (self.stateBlock) self.stateBlock(MXTableViewHeaderStateFinish,0);
}

- (void)startRefresh
{
    [self startAnimationWithDuration:headerHeight / SlideSpeed];
}

- (void)startAnimationWithDuration:(float)duration
{
    self.loadingLock = NO;
    self.trigLock = NO;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setContentInset:UIEdgeInsetsMake(headerHeight, 0.0f, 0.0f, 0.0f)];
    } completion:^(BOOL finished) {
        if (self.stateBlock) self.stateBlock(MXTableViewHeaderStateLoading,1);
    }];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if (self.loadingLock) return;
    if (contentOffset.y > -headerHeight && contentOffset.y <= 0) {
        if (self.stateBlock) self.stateBlock(MXTableViewHeaderStateNormal,ABS(contentOffset.y / headerHeight));
        self.trigLock = NO;
    }
    if (contentOffset.y < -headerHeight && self.dragging && !self.trigLock) {
         if (self.stateBlock) self.stateBlock(MXTableViewHeaderStatePreload,1);
        self.trigLock = YES;
    }
    if (!self.dragging && self.trigLock) {
        self.loadingLock = YES;
        float duration = ABS(ABS(contentOffset.y) - headerHeight) / SlideSpeed;
        [self startAnimationWithDuration:duration];
    }
}

@end
