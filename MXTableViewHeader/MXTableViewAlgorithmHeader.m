//
//  MXTableViewAlgorithmHeader.m
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-30.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "MXTableViewAlgorithmHeader.h"

@interface MXTableViewAlgorithmHeader : UIView

@property (nonatomic, strong) UIImageView *imageView;

- (void)startAnimation;
- (void)stopAnimation;
- (void)rotaWithFloat:(float)f;

@end

@implementation MXTableViewAlgorithmHeader

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320-38)/2, 11, 38, 38)];
        [self.imageView setImage:[UIImage imageNamed:@"11"]];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)rotaWithFloat:(float)f
{
    self.imageView.layer.transform = CATransform3DMakeRotation(-M_PI * f, 0, 0, 1.0);
}

- (void)startAnimation
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0, 0, 1.0)];
    animation.duration = 0.15;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    [self.imageView.layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation
{
    [self.imageView.layer removeAllAnimations];
}

@end

@implementation UITableView (MXTableViewAlgorithmHeader)

- (void)addAlgorithmHeaderWithBlock:(void (^)(void))block{
    CGSize size = CGSizeMake(320, 60);
    MXTableViewAlgorithmHeader *headerView = [[MXTableViewAlgorithmHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f - size.height, size.width, size.height)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [self addTableViewHeader:headerView stateBlock:^(MXTableViewHeaderState state, float dragPercent) {
        [headerView rotaWithFloat:dragPercent];
        switch (state) {
            case MXTableViewHeaderStateNormal:
                break;
            case MXTableViewHeaderStateFinish: {
                [headerView stopAnimation];
                break;
            }
            case MXTableViewHeaderStatePreload: {
                break;
            }
            case MXTableViewHeaderStateLoading: {
                [headerView startAnimation];
                if (block) block();
                break;
            }
            default:
                break;
        }
    }];
}

@end