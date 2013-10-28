//
//  MXTableViewSVHeader.m
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-28.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "MXTableViewSVHeader.h"

#define TEXT_COLOR	 [UIColor whiteColor]

@interface SVPullToRefreshArrow : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end

@interface MXTableViewSVHeader : UIView

@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) SVPullToRefreshArrow *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSDate *updateTime;

@end

@implementation MXTableViewSVHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		self.lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		self.lastUpdatedLabel.textColor = TEXT_COLOR;
		self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		self.lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.lastUpdatedLabel];
		
		self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		self.statusLabel.textColor = TEXT_COLOR;
		self.statusLabel.backgroundColor = [UIColor clearColor];
		self.statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:self.statusLabel];
		
		self.arrowImage = [SVPullToRefreshArrow new];
        [self.arrowImage setBackgroundColor:[UIColor clearColor]];
		self.arrowImage.frame = CGRectMake(25.0f, frame.size.height - 55.0f, 30.0f, 50.0f);
        [self.arrowImage setArrowColor:TEXT_COLOR];
        [self addSubview:self.arrowImage];
		
		self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.activityView.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:self.activityView];
		
        self.updateTime = [NSDate date];
    }
    return self;
}

- (void)setUpdateTime:(NSDate *)updateTime
{
    _updateTime = updateTime;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    _lastUpdatedLabel.text = [NSString stringWithFormat:@"最近一次更新: %@", [formatter stringFromDate:_updateTime]];
}

@end

#pragma mark - SVPullToRefreshArrow

@implementation SVPullToRefreshArrow
@synthesize arrowColor;

- (UIColor *)arrowColor {
	if (arrowColor) return arrowColor;
	return [UIColor blackColor]; // default Color
}

- (void)rotate:(float)degrees{
    [UIView animateWithDuration:0.18 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
    } completion:NULL];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	// the rects above the arrow
	CGContextAddRect(c, CGRectMake(5, 0, 12, 4)); // to-do: use dynamic points
	CGContextAddRect(c, CGRectMake(5, 6, 12, 4)); // currently fixed size: 22 x 48pt
	CGContextAddRect(c, CGRectMake(5, 12, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 18, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 24, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 30, 12, 4));
	
	// the arrow
	CGContextMoveToPoint(c, 0, 34);
	CGContextAddLineToPoint(c, 11, 48);
	CGContextAddLineToPoint(c, 22, 34);
	CGContextAddLineToPoint(c, 0, 34);
	CGContextClosePath(c);
	
	CGContextSaveGState(c);
	CGContextClip(c);
	
	// Gradient Declaration
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat alphaGradientLocations[] = {0, 0.8f};
    
	CGGradientRef alphaGradient = nil;
    if([[[UIDevice currentDevice] systemVersion]floatValue] >= 5){
        NSArray* alphaGradientColors = [NSArray arrayWithObjects:
                                        (id)[self.arrowColor colorWithAlphaComponent:0].CGColor,
                                        (id)[self.arrowColor colorWithAlphaComponent:1].CGColor,
                                        nil];
        alphaGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)alphaGradientColors, alphaGradientLocations);
    }else{
        const CGFloat * components = CGColorGetComponents([self.arrowColor CGColor]);
        size_t numComponents = CGColorGetNumberOfComponents([self.arrowColor CGColor]);
        CGFloat colors[8];
        switch(numComponents){
            case 2:{
                colors[0] = colors[4] = components[0];
                colors[1] = colors[5] = components[0];
                colors[2] = colors[6] = components[0];
                break;
            }
            case 4:{
                colors[0] = colors[4] = components[0];
                colors[1] = colors[5] = components[1];
                colors[2] = colors[6] = components[2];
                break;
            }
        }
        colors[3] = 0;
        colors[7] = 1;
        alphaGradient = CGGradientCreateWithColorComponents(colorSpace,colors,alphaGradientLocations,2);
    }
	
	
	CGContextDrawLinearGradient(c, alphaGradient, CGPointZero, CGPointMake(0, rect.size.height), 0);
    
	CGContextRestoreGState(c);
	
	CGGradientRelease(alphaGradient);
	CGColorSpaceRelease(colorSpace);
}

@end

@implementation UITableView (MXTableViewSVHeader)

- (void)addSVTableViewHeaderWithBlock:(void (^)(void))block
{
    CGSize size = self.frame.size;
    MXTableViewSVHeader *headerView = [[MXTableViewSVHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f - size.height, size.width, size.height)];
    [self addTableViewHeader:headerView stateBlock:^(MXTableViewHeaderState state, float dragPercent) {
        switch (state) {
            case MXTableViewHeaderStateNormal:
            case MXTableViewHeaderStateFinish: {
                [headerView.statusLabel setText:@"向下滑动刷新"];
                [headerView.activityView stopAnimating];
                [headerView.arrowImage rotate:0];
                headerView.arrowImage.hidden = NO;
                if (state == MXTableViewHeaderStateFinish) {
                    headerView.arrowImage.hidden = YES;
                    [headerView setUpdateTime:[NSDate date]];
                }
                break;
            }
            case MXTableViewHeaderStatePreload: {
                [headerView.statusLabel setText:@"释放刷新"];
                [headerView.arrowImage rotate:M_PI];
                break;
            }
            case MXTableViewHeaderStateLoading: {
                [headerView.statusLabel setText:@"正在刷新"];
                [headerView.activityView startAnimating];
                [headerView.arrowImage rotate:M_PI];
                headerView.arrowImage.hidden = YES;
                if (block) block();
                break;
            }
            default:
                break;
        }
    }];
}

@end