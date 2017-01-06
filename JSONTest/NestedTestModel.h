//
//  NestedTestModel.h
//  JSONTest
//
//  Created by mac on 2017/1/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NestedTestModel : NSObject
@property (copy, nonatomic) NSString *nestedName;
@property (copy, nonatomic) NSString *nestedDetail;
@property (copy, nonatomic) NSString *nestedPostscript;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end
