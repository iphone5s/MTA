//
//  MTAHelper.m
//  MTADemo
//
//  Created by ezreal on 2017/9/19.
//  Copyright © 2017年 ezreal. All rights reserved.
//

#import "MTAHelper.h"
#import <GZIP.h>
#import <GBDeviceInfo.h>
#import "MTAConfig.h"

#define swap_int(_a, _b) int _t = _a; _a = _b; _b = _t;

@interface MTAConfig ()

@property (nonatomic, strong) NSString *appkey;

@property (nonatomic, strong) NSNumber *numberSI;

@end

NSString *getHardwareUUID()
{
    kern_return_t kr;
    CFMutableDictionaryRef matchDict;
    io_iterator_t iterator;
    io_registry_entry_t entry;
    
    matchDict = IOServiceMatching("IOPlatformExpertDevice");
    kr = IOServiceGetMatchingServices(kIOMasterPortDefault, matchDict, &iterator);
    
    NSDictionary *resultInfo = nil;
    
    NSString *strUUID = nil;
    
    while ((entry = IOIteratorNext(iterator)) != 0)
    {
        CFMutableDictionaryRef properties=NULL;
        kr = IORegistryEntryCreateCFProperties(entry,
                                               &properties,
                                               kCFAllocatorDefault,
                                               kNilOptions);
        if (properties)
        {
            resultInfo = (__bridge_transfer NSDictionary *)properties;
            strUUID = [resultInfo objectForKey:@"IOPlatformUUID"];
            if (!strUUID)
            {
                continue;
            }
            
        }
    }
    
    IOObjectRelease(iterator);
    
    return strUUID;
}

uint32_t swap32(uint32_t value){
    return (value & 0x000000FFU) << 24 | (value & 0x0000FF00U) << 8 |
    (value & 0x00FF0000U) >> 8 | (value & 0xFF000000U) >> 24;
}

void encryptRC4(NSData *input)
{
    uint32_t sbox_size = 256;
    unsigned char sbox[sbox_size];
    const char* _key = "03a976511e2cbe3a7f26808fb7af3c05";
    unsigned char * key = (unsigned char *)_key;
    uint32_t keysize = (uint32_t)strlen(_key);
    
    // Sbox Initilisieren
    unsigned char j =0;
    uint32_t i = 0;
    for (i = 0; i < sbox_size; i++)
        sbox[i] = i;
    // Sbox randomisieren
    for (i = 0; i < sbox_size; i++) {
        j += sbox[i] + key[i % keysize];
        swap_int(sbox[i], sbox[j]);
    }
    
    j = 0;
    i = 0;
    int n =0;
    
    unsigned char* content = (unsigned char*)[input bytes];
    for (n = 0; n < [input length]; n++) {
        i++;
        uint32_t index = i%sbox_size;
        j += sbox[index];
        swap_int(sbox[index], sbox[j]);
        content[n] = content[n] ^ (sbox[(sbox[index] + sbox[j]) & 0xFF]);
    }
}

@implementation MTAHelper

+(NSData *)encryptData:(NSMutableArray *)dataArray
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataArray options:0 error:nil];
    
    NSMutableData *zData = [NSMutableData dataWithData:[data gzippedData]];
    
    uint32_t length = swap32((uint32_t)data.length);
    NSMutableData *dataLength = [[NSMutableData alloc]initWithBytes:&length length:0x04];
    [dataLength appendData:zData];
    
    encryptRC4(dataLength);
    uint32_t header = swap32(0x9527);
    NSMutableData *resultData = [[NSMutableData alloc]initWithBytes:&header length:0x04];
    
    uint32_t packLength = swap32((uint32_t)(zData.length + 20));
    NSData *packDataLength = [[NSMutableData alloc]initWithBytes:&packLength length:0x04];
    
    uint32_t packFlag = swap32(0x01);
    NSData *packDataFlag = [[NSMutableData alloc]initWithBytes:&packFlag length:0x04];
    
    uint32_t packCmd = swap32(0x01030000);
    NSData *packDataCmd = [[NSMutableData alloc]initWithBytes:&packCmd length:0x04];
    
    [resultData appendData:packDataLength];
    [resultData appendData:packDataFlag];
    [resultData appendData:packDataCmd];
    [resultData appendData:dataLength];
    
    return resultData;
}

+(NSData *)getPacketData
{
    NSMutableArray *dataArray = [NSMutableArray new];
    [dataArray addObject:[MTAHelper getEnvDict]];
    
    NSData *resultData = [MTAHelper encryptData:dataArray];
    return resultData;
}

+(NSDictionary *)getEnvDict
{
    GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
    
    NSMutableDictionary *commonDict = [NSMutableDictionary dictionary];
    [commonDict setObject:[NSNumber numberWithInteger:2] forKey:@"et"];
    [commonDict setObject:[NSNumber numberWithInteger:934070624] forKey:@"idx"];
    if([NSBundle mainBundle].bundleIdentifier != nil)
    {
        [commonDict setObject:[NSBundle mainBundle].bundleIdentifier forKey:@"bdid"];
    }
    
    if([MTAConfig sharedInstance].appkey != nil)
    {
        [commonDict setObject:[MTAConfig sharedInstance].appkey forKey:@"ky"];
    }

    [commonDict setObject:getHardwareUUID() forKey:@"tmpid"];
    [commonDict setObject:getHardwareUUID() forKey:@"ifv"];
    [commonDict setObject:@"1" forKey:@"hs"];
    
    NSMutableDictionary *evDict = [NSMutableDictionary dictionary];
    [evDict setObject:@"WIFI" forKey:@"cn"];
    
    NSString *strSysVersion = [NSString stringWithFormat:@"%lu.%lu.%lu",deviceInfo.osVersion.major,deviceInfo.osVersion.minor,deviceInfo.osVersion.patch];
    
    [evDict setObject:strSysVersion forKey:@"ov"];
    [evDict setObject:@"zh-Hans-CN" forKey:@"lg"];
    [evDict setObject:@"Asia/Shanghai" forKey:@"tz"];
    [evDict setObject:[NSNumber numberWithInteger:2] forKey:@"os"];
    [evDict setObject:deviceInfo.rawSystemInfoString forKey:@"md"];
    [evDict setObject:@"2.1.0" forKey:@"sv"];
    [evDict setObject:[NSNumber numberWithInteger:time(0) * 1000000] forKey:@"sut"];
    [evDict setObject:@{@"ss":@"SSDS",@"bs":@"ac:a3:1e:58:3b:74"} forKey:@"wf"];
    
    NSString *strScreen = [NSString stringWithFormat:@"%.0fx%.0f",deviceInfo.displayInfo.resolution.width,deviceInfo.displayInfo.resolution.height];
    [evDict setObject:strScreen forKey:@"sr"];
    
    if([MTAConfig sharedInstance].channel != nil)
    {
        [evDict setObject:[MTAConfig sharedInstance].channel forKey:@"ch"];
    }
    else
    {
        [evDict setObject:@"appstore" forKey:@"ch"];
    }

    [evDict setObject:@"macOS" forKey:@"pl"];
    [evDict setObject:@"iOS" forKey:@"pl"];//
    if (deviceInfo.family == GBDeviceFamilyiMac) {
        [evDict setObject:@"iMac" forKey:@"mf"];
    }else if (deviceInfo.family == GBDeviceFamilyMacMini){
        [evDict setObject:@"MacMini" forKey:@"mf"];
    }else if (deviceInfo.family == GBDeviceFamilyMacPro){
        [evDict setObject:@"MacPro" forKey:@"mf"];
    }else if (deviceInfo.family == GBDeviceFamilyMacBook){
        [evDict setObject:@"MacBook" forKey:@"mf"];
    }else if (deviceInfo.family == GBDeviceFamilyMacBookAir){
        [evDict setObject:@"MacBookAir" forKey:@"mf"];
    }else if (deviceInfo.family == GBDeviceFamilyMacBookPro){
        [evDict setObject:@"MacBookPro" forKey:@"mf"];
    }else if (deviceInfo.family == GBDeviceFamilyXserve){
        [evDict setObject:@"Xserve" forKey:@"mf"];
    }else{
        [evDict setObject:@"Unknown" forKey:@"mf"];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if ([MTAConfig sharedInstance].version != nil) {
        [evDict setObject:app_Version forKey:@"av"];
    }else if (app_Version != nil){
        [evDict setObject:app_Version forKey:@"av"];
    }else{
        [evDict setObject:@"1.0.0" forKey:@"av"];
    }
    
    [commonDict setObject:evDict forKey:@"ev"];
    [commonDict setObject:getHardwareUUID() forKey:@"ui"];
    [commonDict setObject:[MTAConfig sharedInstance].numberSI forKey:@"si"];
    [commonDict setObject:[NSNumber numberWithInteger:time(0)] forKey:@"ts"];
    [commonDict setObject:[NSNumber numberWithInteger:0] forKey:@"ut"];
    
    NSMutableDictionary *cfgDict = [NSMutableDictionary dictionary];
    [cfgDict setObject:@"" forKey:@"1"];
    [cfgDict setObject:@"" forKey:@"2"];
    
    [commonDict setObject:cfgDict forKey:@"cfg"];
    
    return commonDict;
}

@end
