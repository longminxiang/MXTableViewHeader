//
//  MXTableViewEGOHeader.m
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-25.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "MXTableViewEGOHeader.h"

#define FLIP_ANIMATION_DURATION 0.18f
#define TEXT_COLOR	 [UIColor whiteColor]

@interface MXTableViewEGOHeader : UIView

@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CALayer *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) NSDate *updateTime;

@end

@implementation MXTableViewEGOHeader

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
		
		self.arrowImage = [CALayer layer];
		self.arrowImage.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		self.arrowImage.contentsGravity = kCAGravityResizeAspect;
		self.arrowImage.contents = (id)[UIImage imageNamed:@"whiteArrow.png"].CGImage;
		[[self layer] addSublayer:self.arrowImage];
		
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

@implementation UITableView (MXTableViewEGOHeader)

- (void)addEGOTableViewHeaderWithBlock:(void (^)(void))block
{
    CGSize size = self.frame.size;
    MXTableViewEGOHeader *headerView = [[MXTableViewEGOHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f - size.height, size.width, size.height)];
    [self addTableViewHeader:headerView stateBlock:^(MXTableViewHeaderState state, float dragPercent) {
        switch (state) {
            case MXTableViewHeaderStateNormal:
            case MXTableViewHeaderStateFinish: {
                [headerView.statusLabel setText:@"向下滑动刷新"];
                [headerView.activityView stopAnimating];
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                headerView.arrowImage.hidden = NO;
                headerView.arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
                if (state == MXTableViewHeaderStateFinish) {
                    headerView.arrowImage.hidden = YES;
                    [headerView setUpdateTime:[NSDate date]];
                }
                break;
            }
            case MXTableViewHeaderStatePreload: {
                [headerView.statusLabel setText:@"释放刷新"];
                [CATransaction begin];
                [CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
                headerView.arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
                break;
            }
            case MXTableViewHeaderStateLoading: {
                [headerView.statusLabel setText:@"正在刷新"];
                [headerView.activityView startAnimating];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                headerView.arrowImage.hidden = YES;
                [CATransaction commit];
                if (block) block();
                break;
            }
            default:
                break;
        }
    }];
}

@end