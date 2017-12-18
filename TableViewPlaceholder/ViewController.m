//
//  ViewController.m
//  TableViewPlaceholder
//
//  Created by TengShuQiang on 2017/12/4.
//  Copyright © 2017年 TTeng. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+AddForPlaceholder.h"

//弱引用
#define kWeak(self) @autoreleasepool{} __weak typeof(self) self##Weak = self;
//强引用
#define kStrong(self) @autoreleasepool{} __strong typeof(self##Weak) self = self##Weak;

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *data;

@end

@implementation ViewController

- (void)dealloc {
    NSLog(@"......");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
    
    kWeak(self);
    self.tableView.defaultNoDataText = @"这是一行提示的文字呀";
    self.tableView.defaultNoDataViewDidClickBlock = ^(UIView *view) {
        kStrong(self);
        self.data = @[@"删除数据，显示默认提示",@"删除数据，显示自定义提示"];
        [self.tableView reloadData];
    };
    self.tableView.backgroundView = [UIView new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)onDeviceOrientationChange:(NSNotification *)noti {
    
    CGFloat width , height;
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    self.tableView.frame = CGRectMake(0, 0, width, height);
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            _data = @[];
            tableView.customNoDataView = nil;
            [tableView reloadData];
            break;
        case 1:
            _data = @[];
            tableView.customNoDataView = [self customNoticeView];
            [tableView reloadData];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIButton *)customNoticeView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"点击刷新" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reloadTableViewData) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)reloadTableViewData {
    _data = @[@"删除数据，显示默认提示",@"删除数据，显示自定义提示"];
    [self.tableView reloadData];
}

#pragma mark -
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _tableView;
}


@end
