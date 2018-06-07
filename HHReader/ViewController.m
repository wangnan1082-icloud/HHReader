//
//  ViewController.m
//  HHReader
//
//  Created by 王楠 on 2018/4/25.
//  Copyright © 2018年 王楠. All rights reserved.
//

#import "ViewController.h"
#import "HHReadPageViewController.h"

#import "WifiUploadBookViewController.h"

NSString *const listCellId = @"listCellId";
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL hideNav;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *dataArray;
@end

@implementation ViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBooks];
    [self addRightNavButton];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
}

- (void)addRightNavButton {
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 100, 40);
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn setTitle:@"WiFi传书" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightNavBtnCLick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)rightNavBtnCLick:(UIButton *)sender {
    hideNav = NO;
    WifiUploadBookViewController *wifiUploadVC = [[WifiUploadBookViewController alloc] init];
    [self.navigationController pushViewController:wifiUploadVC animated:YES];
}

- (void)addBooks {
    _dataArray = [NSMutableArray arrayWithArray:[self getFile]];
    NSURL *fileURL1 = [[NSBundle mainBundle] URLForResource:@"盗墓笔记第1卷 七星鲁王 "withExtension:@"txt"];
    NSURL *fileURL2 = [[NSBundle mainBundle] URLForResource:@"全职高手-精校"withExtension:@"txt"];
    [_dataArray addObject:fileURL1];
    [_dataArray addObject:fileURL2];
}

- (void)viewWillAppear:(BOOL)animated  {
    if (self.dataArray && self.dataArray.count > 0) {
        [_dataArray removeAllObjects];
        [self addBooks];
    }
    hideNav = YES;
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:hideNav];
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellId forIndexPath:indexPath];
    NSURL *temp = _dataArray[indexPath.row];
    cell.textLabel.text = temp.lastPathComponent;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    hideNav = YES;
    //  全职高手-精校
    HHReadPageViewController *pageVC = [[HHReadPageViewController alloc] init];
    NSURL *fileURL = self.dataArray[indexPath.row];
    pageVC.resourceURL = fileURL;
    [self.navigationController pushViewController:pageVC animated:YES];
}

#pragma mark -  获取本地文件

- (NSArray *)getFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    // 所查找文件夹的路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *temp = [NSString stringWithFormat:@"HHReader"];
    NSString *home = [docPath stringByAppendingPathComponent:temp];
    
    // 目录迭代器
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:home];
    // 快速枚举
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:42];
    for (NSString *filename in direnum) {
        // 添加找到的txt文件
        if ([filename.pathExtension isEqualToString:@"txt"]) {
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", home, filename]];
            [files addObject:url];
        }
    }
//    NSLog(@"count:   %lu",[files count]);
    // 快速枚举，输出结果
    for (NSString *filename in files) {
        NSLog(@"filenameURL:   %@",filename);
    }
    return files.copy;
}

#pragma mark - Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:listCellId];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
