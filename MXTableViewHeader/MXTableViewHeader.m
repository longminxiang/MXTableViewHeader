//
//  MXTableViewHeader.m
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "MXTableViewHeader.h"
#import <objc/runtime.h>

#define SlideSpeed 350.0f
#define HEADER_HEIGHT 70

#pragma mark === Extent getter and setter ===

@interface UITableView (MXTableViewHeaderPrivate)

@property (nonatomic, strong) UIView *mxHeaderView;
@property (nonatomic, copy) MXTableViewHeaderBlock stateBlock;
@property (nonatomic, assign) MXTableViewHeaderState state;
@property (nonatomic, assign) UIEdgeInsets originInsets;

@end

@implementation UITableView (MXTableViewHeaderPrivate)

static const char *mxHeaderViewKey = "mxHeaderView";
static const char *stateBlockKey = "stateBlock";
static const char *stateKey = "state";
static const char *originInsetsKey = "originInsets";

@dynamic stateBlock,mxHeaderView,state,originInsets;

- (MXTableViewHeaderState)state
{
    return [objc_getAssociatedObject(self, stateKey) integerValue];
}

- (void)setState:(MXTableViewHeaderState)state
{
    objc_setAssociatedObject(self, stateKey, [NSNumber numberWithInt:state], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIView *)mxHeaderView
{
    return objc_getAssociatedObject(self, mxHeaderViewKey);
}

- (void)setOriginInsets:(UIEdgeInsets)originInsets
{
    objc_setAssociatedObject(self, originInsetsKey, [NSValue valueWithUIEdgeInsets:originInsets], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIEdgeInsets)originInsets
{
    return [objc_getAssociatedObject(self, originInsetsKey) UIEdgeInsetsValue];
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

#pragma mark === UITableView Header Category ===

@implementation UITableView (MXTableViewHeader)

static int headerHeight;

- (void)addTableViewHeader:(UIView *)header stateBlock:(MXTableViewHeaderBlock)block
{
    self.state = MXTableViewHeaderStateNormal;
    self.originInsets = self.contentInset;
    self.mxHeaderView = header;
    headerHeight = HEADER_HEIGHT + self.originInsets.top;
    [self addSubview:self.mxHeaderView];
    self.stateBlock = block;
}

- (void)stopRefresh
{
    self.state = MXTableViewHeaderStateFinish;
    [UIView animateWithDuration:headerHeight / SlideSpeed delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setContentInset:self.originInsets];
    } completion:^(BOOL finished) {
    }];
    if (self.stateBlock) self.stateBlock(MXTableViewHeaderStateFinish,0);
}

- (void)startRefresh
{
    [self startAnimationWithDuration:headerHeight / SlideSpeed];
    self.state = MXTableViewHeaderStateLoading;
}

- (void)startAnimationWithDuration:(float)duration
{
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setContentOffset:CGPointMake(0, -headerHeight)];
        [self setContentInset:UIEdgeInsetsMake(headerHeight, 0.0f, 0.0f, 0.0f)];
    } completion:^(BOOL finished) {
        if (self.stateBlock) self.stateBlock(MXTableViewHeaderStateLoading,1);
    }];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if (!self.mxHeaderView) return;
    if (self.state == MXTableViewHeaderStateLoading) return;
    if (!self.dragging && self.state == MXTableViewHeaderStatePreload) {
        self.state = MXTableViewHeaderStateLoading;
        float duration = ABS(ABS(contentOffset.y) - headerHeight) / SlideSpeed;
        [self startAnimationWithDuration:duration];
    }
    if (contentOffset.y > -headerHeight && contentOffset.y <= 0 && self.state != MXTableViewHeaderStateLoading) {
        if (self.stateBlock) self.stateBlock(MXTableViewHeaderStateNormal,ABS(contentOffset.y / headerHeight));
        self.state = MXTableViewHeaderStateNormal;
    }
    if (contentOffset.y < -headerHeight && self.dragging) {
         if (self.stateBlock) self.stateBlock(MXTableViewHeaderStatePreload,1);
        self.state = MXTableViewHeaderStatePreload;
    }
}

@end
