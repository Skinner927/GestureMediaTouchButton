//
//  TouchGestureButton.m
//  FullMediaTouchButton
//
//  Created by Dennis Skinner on 5/30/18.
//  Copyright © 2018 Dennis Skinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchGestureButton.h"
#import "DebugLog.h"

static NSString* const TOUCH_GESTURE_BUTTON_PLAY = @"\U000023EF";
static NSString* const TOUCH_GESTURE_BUTTON_PREVIOUS = @"\U000023EE";
static NSString* const TOUCH_GESTURE_BUTTON_NEXT = @"\U000023ED";

@interface TouchGestureButton ()

@property NSInteger selection;
@property NSInteger oldSelection;
@property id trackingTouchIdentity;
// Is true when we've gone far enough to potentially
// trigger a next/previous nav. Purpose is if we land
// back inside the button after going far enough out
// to trigger another action, abort any action as
// this is our only way to cancel a previous/next nav.
@property BOOL hasSlidOutsideBox;

@end

@implementation TouchGestureButton

+(TouchGestureButton*)create
{
    TouchGestureButton *btn = [TouchGestureButton buttonWithTitle:TOUCH_GESTURE_BUTTON_PLAY target:nil action:nil];
    // Touch gestures handle the click
    //[btn setTarget:btn];
    //[btn setAction:@selector(click:)];
    btn.hasSlidOutsideBox = NO;
    return btn;
}

/*!
 Sends a global media key.
 Specifically any XN_* from /System/Library/Frameworks/IOKit.framework/Versions/A/Headers/hidsystem/ev_keymap.h
 
 Derived from https://github.com/BlueM/cliclick/blob/master/Actions/KeyPressAction.m
 Accessed May 30, 2018; commit b5edc343248401dc2583ead0e5452dbf7299faaa
 
 * Copyright (c) 2007-2018, Carsten Blüm <carsten@bluem.net>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 * - Neither the name of Carsten Blüm nor the names of his contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
- (void)sendMediaKey:(CGKeyCode)code
{
    NSEvent *down = [NSEvent otherEventWithType:NSEventTypeSystemDefined
                                     location:NSPointFromCGPoint(CGPointZero)
                                modifierFlags:0xa00
                                    timestamp:0
                                 windowNumber:0
                                      context:0
                                      subtype:8
                                        data1:((code << 16) | (0xa << 8))
                                        data2:-1];
    CGEventPost(0, down.CGEvent);
    
    NSEvent *up = [NSEvent otherEventWithType:NSEventTypeSystemDefined
                                     location:NSPointFromCGPoint(CGPointZero)
                                modifierFlags:0xb00
                                    timestamp:0
                                 windowNumber:0
                                      context:0
                                      subtype:8
                                        data1:((code << 16) | (0xb << 8))
                                        data2:-1];
    CGEventPost(0, up.CGEvent);
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (NSString*)showIcon:(CGFloat)x
{
    CGFloat myWidth = self.frame.size.width;
    CGFloat fudge = myWidth / 2.0;
    
    Debug(@"X is at %0.2f", x);
    
    if (x > myWidth + fudge) {
        self.hasSlidOutsideBox = YES;
        return TOUCH_GESTURE_BUTTON_NEXT;
    } else if (x < -fudge) {
        self.hasSlidOutsideBox = YES;
        return TOUCH_GESTURE_BUTTON_PREVIOUS;
    }
    return TOUCH_GESTURE_BUTTON_PLAY;
}

// Touch handling from: https://developer.apple.com/library/content/samplecode/NSTouchBarCatalog/Introduction/Intro.html
// Objective-C/NSTouchBar Catalog/TestViewControllers/CustomViewController/CustomView.m
- (void)touchesBeganWithEvent:(NSEvent *)event
{
    // We are already tracking a touch, so this must be a new touch.
    // What should we do? Cancel or ignore.
    if (self.trackingTouchIdentity == nil)
    {
        NSSet<NSTouch *> *touches = [event touchesMatchingPhase:NSTouchPhaseBegan inView:self];
        // Note: Touches may contain 0, 1 or more touches.
        // What to do if there are more than one touch?
        // In this example, randomly pick a touch to track and ignore the other one.

        NSTouch *touch = touches.anyObject;
        if (touch != nil)
        {
            if (touch.type == NSTouchTypeDirect)
            {
                _trackingTouchIdentity = touch.identity;

                // Remember the selection value at start of tracking in case we need to cancel.
                _oldSelection = self.selection;
            }
        }
    }

    [super touchesBeganWithEvent:event];
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    if (self.trackingTouchIdentity)
    {
        for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseMoved inView:self])
        {
            if (touch.type == NSTouchTypeDirect && [_trackingTouchIdentity isEqual:touch.identity])
            {
                NSPoint location = [touch locationInView:self];
                Debug(@"Moved at %0.2f", location.x);
                
                NSString* icon = [self showIcon:location.x];
                if (icon != self.title)
                    [self setTitle:icon];
                break;
            }
        }
    }

    [super touchesMovedWithEvent:event];
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
    if (self.trackingTouchIdentity)
    {
        for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseEnded inView:self])
        {
            if (touch.type == NSTouchTypeDirect && [_trackingTouchIdentity isEqual:touch.identity])
            {
                // Finshed tracking successfully.
                _trackingTouchIdentity = nil;

                NSPoint location = [touch locationInView:self];
                Debug(@"Ended at %0.2f", location.x);
                
                NSString* icon = [self showIcon:location.x];
                
                // What do?
                if (icon == TOUCH_GESTURE_BUTTON_PREVIOUS){
                    Debug(@"BACK");
                    [self sendMediaKey:NX_KEYTYPE_PREVIOUS];
                } else if (icon == TOUCH_GESTURE_BUTTON_NEXT) {
                    Debug(@"NEXT");
                    [self sendMediaKey:NX_KEYTYPE_NEXT];
                } else if (!self.hasSlidOutsideBox) {
                    Debug(@"PLAY");
                    [self sendMediaKey:NX_KEYTYPE_PLAY];
                }
                
                // Reset state
                self.hasSlidOutsideBox = NO;
                [self setTitle:TOUCH_GESTURE_BUTTON_PLAY];
                break;
            }
        }
    }

    [super touchesEndedWithEvent:event];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
    if (self.trackingTouchIdentity)
    {
        for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseMoved inView:self])
        {
            if (touch.type == NSTouchTypeDirect && [self.trackingTouchIdentity isEqual:touch.identity])
            {
                // CANCEL
                // This can happen for a number of reasons.
                // # A gesture recognizer started recognizing a touch.
                // # The underlying touch context changed (User Cmd-Tabbed while interacting with this view).
                // # The hardware itself decided to cancel the touch.
                // Whatever the reason, put things back the way they were, in this example, reset the selection.
                //
                _trackingTouchIdentity = nil;

                self.selection = self.oldSelection;

#ifdef DEBUG
                NSPoint location = [touch locationInView:self];
                NSLog(@"Canceled at %0.2f", location.x);
#endif
                [self setTitle:TOUCH_GESTURE_BUTTON_PLAY];
            }
        }
    }

    [super touchesCancelledWithEvent:event];
}

@end
