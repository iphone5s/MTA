//
//  MTA.m
//  MTA
//
//  Created by ezreal on 2017/12/13.
//  Copyright © 2017年 ezreal. All rights reserved.
//

#import "MTA.h"
#import <GCDAsyncSocket.h>
#import "MTAHelper.h"

#import "MTAConfig.h"

@interface MTAConfig ()

@property (nonatomic, strong) NSString *appkey;

@end

static id _instance;

@interface MTA()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *m_socket;
    NSString *m_strAppKey;
    NSString *m_strSI;//每次启动随机产生，用于统计启动次数
}
@end

@implementation MTA

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
        m_socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        [m_socket connectToHost:@"pingma.qq.com" onPort:80 error:nil];
    }
    return self;
}

+(void)startWithAppkey:(NSString *)appkey{
    
    [MTAConfig sharedInstance].appkey = appkey;
    [MTA sharedInstance];
}

-(void)sendData
{
    NSData *resultData = [MTAHelper getPacketData];
    [m_socket writeData:resultData withTimeout:10 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self sendData];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [m_socket readDataWithTimeout:10 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    
}
@end
