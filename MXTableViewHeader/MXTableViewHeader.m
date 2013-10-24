//
//  MXTableViewHeader.m
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "MXTableViewHeader.h"
#import <objc/runtime.h>

@implementation MXTableViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

@implementation UITableView (MXTableViewHeader)

@dynamic headerLock;

#define HeaderHeight 70.0f
#define SlideSpeed 240.0f

static bool _trigLock;
static const char *headerLockKey = "headerLock";
static void (^_preLoadBlock)(float trigPersent);
static void (^_triggeredBlock)(void);
static void (^_loadingBlock)(void);

- (void)setHeaderLock:(BOOL)headerLock
{
    objc_setAssociatedObject(self, headerLockKey, [NSNumber numberWithBool:headerLock], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)headerLock
{
    return [objc_getAssociatedObject(self, headerLockKey) boolValue];
}

- (void)addTableViewHeader:(UIView *)header preLoadBlock:(void (^)(float trigPersent))preLoadBlock triggeredBlock:(void (^)(void))triggeredBlock loadingBlock:(void (^)(void))loadingBlock
{
    self.headerLock = NO;
    _trigLock = NO;
    _preLoadBlock = preLoadBlock;
    _triggeredBlock = triggeredBlock;
    _loadingBlock = loadingBlock;
    [self addSubview:header];
}

- (void)stopAnimation
{
    _trigLock = NO;
    self.headerLock = NO;
    [UIView animateWithDuration:HeaderHeight / SlideSpeed delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self setContentInset:UIEdgeInsetsZero];
    } completion:^(BOOL finished) {
        if (_preLoadBlock) _preLoadBlock(0);
    }];
}

- (void)startAnimation
{
    self.headerLock = NO;
    [UIView animateWithDuration:HeaderHeight / SlideSpeed animations:^{
        [self setContentInset:UIEdgeInsetsMake(HeaderHeight, 0.0f, 0.0f, 0.0f)];
    }];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    if (self.headerLock) return;
    if (contentOffset.y > -60 && contentOffset.y < 0) {
        if (_preLoadBlock) _preLoadBlock(ABS(contentOffset.y / HeaderHeight));
    }
    else if (contentOffset.y <= -HeaderHeight) {
        if (self.dragging && !_trigLock) {
            if (_triggeredBlock) _triggeredBlock();
            _trigLock = YES;
        }
    }
    if (!self.dragging && _trigLock) {
        self.headerLock = YES;
//        [self setContentOffset:contentOffset];
        float duration = ABS(ABS(contentOffset.y) - HeaderHeight) / SlideSpeed;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self setContentInset:UIEdgeInsetsMake(HeaderHeight, 0.0f, 0.0f, 0.0f)];
        } completion:^(BOOL finished) {
            if (_loadingBlock) _loadingBlock();
        }];
    }
}

@end