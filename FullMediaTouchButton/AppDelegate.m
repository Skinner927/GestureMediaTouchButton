//
//  AppDelegate.m
//  FullMediaTouchButton
//
//  Created by Dennis Skinner on 5/30/18.
//  Copyright © 2018 Dennis Skinner. All rights reserved.
//

#import "AppDelegate.h"
#import "TouchGestureButton.h"
#import "TouchBar.h"

static const NSTouchBarItemIdentifier touchButtonIdentifier = @"com.dennisskinner.FullMediaTouchButton";

@interface AppDelegate () <NSTouchBarDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (strong) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSCustomTouchBarItem *barItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:touchButtonIdentifier];
    barItem.view = [TouchGestureButton create];
    
    [NSTouchBarItem addSystemTrayItem:barItem];
    DFRElementSetControlStripPresenceForIdentifier(touchButtonIdentifier, YES);
    
    // Status bar item
    // Good tut: https://kmikael.com/2013/07/01/simple-menu-bar-apps-for-os-x/
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [self.statusItem.button setImage:[NSImage imageNamed:NSImageNameTouchBarPlayPauseTemplate]];
    
    // Status bar item menu
    NSMenu *menu = [[NSMenu alloc] init];
    [self.statusItem setMenu:menu];
    
//    NSMenuItem *title = [[NSMenuItem alloc] initWithTitle:@"Media Touch Button" action:nil keyEquivalent:@""];
//    [title setEnabled:NO];
//    [menu addItem:title];
//
//    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    
    [menu addItemWithTitle:@"Quit Media Touch Button" action:@selector(quit:) keyEquivalent:@""];
}

-(void)quit:(int)idk
{
    [[NSApplication sharedApplication] terminate:self.statusItem];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    //DFRElementSetControlStripPresenceForIdentifier(touchButtonIdentifier, NO);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return NO;
}


@end
