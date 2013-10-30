//
//  ViewController.m
//  MXTableViewHeaderDemo
//
//  Created by longminxiang on 13-10-24.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#import "ViewController.h"
#import "MXTableViewSVHeader.h"
#import "MXTableViewAlgorithmHeader.h"

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
    CGRect rect = self.view.frame;
    rect.size.height -= 64;
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:rect];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    
    self.tableViewData = [NSMutableArray new];
    [self.tableViewData addObject:@"MXTableViewSVHeader"];
    [self.tableViewData addObject:@"MXTableViewAlgorithmHeader"];
    
    __weak ViewController *weakSelf = self;
    
    if ([self.title isEqualToString:@"MXTableViewSVHeader"]) {
        
        [self.tableView addSVTableViewHeaderWithBlock:^{
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf.tableView stopRefresh];
            });
        }];
        [self.tableView startRefresh];
    }
    else if ([self.title isEqualToString:@"MXTableViewAlgorithmHeader"]) {
        [self.tableView addAlgorithmHeaderWithBlock:^{
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf.tableView stopRefresh];
            });
        }];
        [self.tableView startRefresh];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *vc = [ViewController new];
    [vc setTitle:self.tableViewData[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
