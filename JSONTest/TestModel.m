
//
//  TestModel.m
//  JSONTest
//
//  Created by mac on 2017/1/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"nested"]) {
        self.nestedModel = [[NestedTestModel alloc]initWithDict:value];
    } else {
        [super setValue:value forKey:key];
    }
}

@end
