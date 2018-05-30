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
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSCustomTouchBarItem *barItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:touchButtonIdentifier];
    barItem.view = [TouchGestureButton create];
    
    [NSTouchBarItem addSystemTrayItem:barItem];
    DFRElementSetControlStripPresenceForIdentifier(touchButtonIdentifier, YES);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Not really sure how to clean this up but that looked ok.
    DFRElementSetControlStripPresenceForIdentifier(touchButtonIdentifier, NO);
}


@end
