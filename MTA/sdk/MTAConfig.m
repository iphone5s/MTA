//
//  MTAConfig.m
//  MTA
//
//  Created by ezreal on 2017/12/13.
//  Copyright © 2017年 ezreal. All rights reserved.
//

#import "MTAConfig.h"

static id _instance;

@interface MTAConfig ()

@property (nonatomic, strong) NSString *appkey;

@property (nonatomic, strong) NSNumber *numberSI;

@end

@implementation MTAConfig

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _numberSI = [NSNumber numberWithInteger:(1000000000 +  (arc4random() % 1000000001))];
    }
    return self;
}

-(NSNumber *)numberSI{
    return _numberSI;
}
@end
