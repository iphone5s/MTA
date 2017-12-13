//
//  MTA.h
//  MTA
//
//  Created by ezreal on 2017/12/13.
//  Copyright © 2017年 ezreal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTAConfig.h"

@interface MTA : NSObject

/**
 启动MTA
 
 @param appkey 从网页申请的appKey
 */
+ (void)startWithAppkey:(NSString *)appkey;

@end
