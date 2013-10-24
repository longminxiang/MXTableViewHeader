//
//  ViewController.m
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "ViewController.h"
#import "MXTableViewHeader.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableViewData;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setText:@"向下滑动刷新"];
    
    __weak ViewController *weakSelf = self;
    [self.tableView addTableViewHeader:headerLabel preLoadBlock:^(float trigPersent) {
        NSLog(@"%f",trigPersent);
        [headerLabel setTextColor:[UIColor colorWithRed:trigPersent green:0.5 blue:trigPersent alpha:1]];
        [headerLabel setText:@"向下滑动刷新"];
    } triggeredBlock:^{
        [headerLabel setText:@"释放刷新"];
    } loadingBlock:^{
        [headerLabel setText:@"正在刷新"];
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.tableView stopAnimation];
        });
    }];
    
    self.tableViewData = [NSMutableArray new];
    for (int i = 0; i < 5; i++) {
        [self.tableViewData addObject:[NSString stringWithFormat:@"%d",i]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"Indentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
    }
    NSString *string = self.tableViewData[indexPath.row];
    [cell.textLabel setText:string];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end