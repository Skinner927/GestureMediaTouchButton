//
//  TouchGestureButton.h
//  FullMediaTouchButton
//
//  Created by Dennis Skinner on 5/30/18.
//  Copyright © 2018 Dennis Skinner. All rights reserved.
//

#ifndef TouchGestureButton_h
#define TouchGestureButton_h

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>

@interface TouchGestureButton : NSButton

+(TouchGestureButton*)create;

@end

#endif /* TouchGestureButton_h */
