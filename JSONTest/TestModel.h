//
//  TestModel.h
//  JSONTest
//
//  Created by mac on 2017/1/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NestedTestModel.h"

@interface TestModel : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *detail;
@property (copy, nonatomic) NSString *postscript;
@property (strong, nonatomic) NestedTestModel *nestedModel;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end
