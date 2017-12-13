//
//  MTAConfig.h
//  MTA
//
//  Created by ezreal on 2017/12/13.
//  Copyright © 2017年 ezreal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTAConfig : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *channel;

@end
