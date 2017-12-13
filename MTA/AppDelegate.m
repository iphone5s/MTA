//
//  AppDelegate.m
//  MTA
//
//  Created by ezreal on 2017/12/13.
//  Copyright © 2017年 ezreal. All rights reserved.
//

#import "AppDelegate.h"
#import "MTA.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [MTAConfig sharedInstance].channel = @"Navicat";
    [MTA startWithAppkey:@"IY77EINW72CF"];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
