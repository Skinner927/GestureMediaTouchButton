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

- (void)click:(id)sender
{
    NSLog(@"CLICK");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    TouchGestureButton *gestureButton = [TouchGestureButton create];
    //TouchGestureButton *gestureButton = [[TouchGestureButton alloc] init];
    //NSButton *gestureButton = [NSButton buttonWithTitle:@"\U0001F43C" target: self action: @selector(click:)];
    
    NSCustomTouchBarItem *barItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:touchButtonIdentifier];
    barItem.view = gestureButton;
    
    [NSTouchBarItem addSystemTrayItem:barItem];
    DFRElementSetControlStripPresenceForIdentifier(touchButtonIdentifier, YES);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    DFRElementSetControlStripPresenceForIdentifier(touchButtonIdentifier, NO);
}


@end
