//
//  AppDelegate.m
//  KxCoreBuleBoothOSX
//
//  Created by FD on 2018/11/1.
//  Copyright © 2018 FD. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
//@property (nonatomic, strong) NSStatusItem *item;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
//    NSStatusItem *item = [statusBar statusItemWithLength:NSSquareStatusItemLength];
//    [item.button setTarget:self];
//    [item.button setAction:@selector(itemAction:)];
//
//    item.button.image = [NSImage imageNamed:@"lanya2.png"];
//
//    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@""];
//
//    [subMenu addItemWithTitle:@"Start Service"action:@selector(start) keyEquivalent:@""];
//    [subMenu addItemWithTitle:@"Stop"action:@selector(stop) keyEquivalent:@""];
//    [subMenu addItemWithTitle:@"Exit"action:@selector(exit) keyEquivalent:@""];
//    item.menu = subMenu;
//    self.item = item;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (void)itemAction:(id)sender {
    [[NSRunningApplication currentApplication] activateWithOptions:(NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps)];
}

- (void)start {
    
}

- (void)stop {
    
}

- (void)exit {
    
}

@end
