//
//  ViewController.m
//  JSONTest
//
//  Created by mac on 2017/1/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 加载本地 json 数据，正常应是请求服务器
    [self loadData];
}

- (void)loadData {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"test.json" ofType:nil];
    // 2. 解析数据
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:jsonPath] options:NSJSONReadingMutableContainers error:nil];
    // 3. 转换，只要属性定义好，直接调用初始化方法即可
    TestModel *model = [[TestModel alloc]initWithDict:jsonDict];
    // 4. 打印验证
    NSLog(@"name - %@, detail - %@, postscript - %@, nestedName - %@, nestedDetail - %@, nestedPostscript - %@, ", model.name, model.detail, model.postscript, model.nestedModel.nestedName, model.nestedModel.nestedDetail, model.nestedModel.nestedPostscript);
}
@end
