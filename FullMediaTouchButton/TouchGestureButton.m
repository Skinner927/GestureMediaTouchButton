//
//  TouchGestureButton.m
//  FullMediaTouchButton
//
//  Created by Dennis Skinner on 5/30/18.
//  Copyright © 2018 Dennis Skinner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchGestureButton.h"

static NSString *const TOUCH_GESTURE_BUTTON_TITLE = @"\U0001F43C";

@interface TouchGestureButton ()

@property NSInteger selection;
@property NSInteger oldSelection;
@property id trackingTouchIdentity;

@end

@implementation TouchGestureButton

+(TouchGestureButton*)create
{
    TouchGestureButton *btn = [TouchGestureButton buttonWithTitle:TOUCH_GESTURE_BUTTON_TITLE target:nil action:nil];
    [btn setTarget:btn];
    [btn setAction:@selector(click:)];
    return btn;
}

- (void)click:(id)sender
{
    [self sendMediaKey:NX_KEYTYPE_PLAY];
    NSLog(@"KLICK");
}

- (void)sendMediaKey:(CGKeyCode)code
{
    // Pulled from https://github.com/BlueM/cliclick/blob/master/Actions/KeyPressAction.m
    NSEvent *e1 = [NSEvent otherEventWithType:NSSystemDefined
                                     //location:NSPointFromCGPoint(CGPointZero)
                                     location:CGPointZero
                                modifierFlags:0xa00
                                    timestamp:0
                                 windowNumber:0
                                      context:0
                                      subtype:8
                                        data1:((code << 16) | (0xa << 8))
                                        data2:-1];
    //CGEventPost(0, [e1 CGEvent]);
    CGEventPost(0, e1.CGEvent);
    
    NSEvent *e2 = [NSEvent otherEventWithType:NSSystemDefined
                                     location:CGPointZero
                                modifierFlags:0xb00
                                    timestamp:0
                                 windowNumber:0
                                      context:0
                                      subtype:8
                                        data1:((code << 16) | (0xb << 8))
                                        data2:-1];
    
    //CGEventPost(0, [e2 CGEvent]);
    CGEventPost(0, e2.CGEvent);
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)touchesBeganWithEvent:(NSEvent *)event
{
    // We are already tracking a touch, so this must be a new touch.
    // What should we do? Cancel or ignore.
    //
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

                NSPoint location = [touch locationInView:self];
                NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"Began At", @""), location.x]);
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
                NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"Moved At", @""), location.x]);
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
                NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"Ended At", @""), location.x]);
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
                // Whatever the reason, but things back the way they were, in this example, reset the selection.
                //
                _trackingTouchIdentity = nil;

                self.selection = self.oldSelection;

                NSPoint location = [touch locationInView:self];
                NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"Canceled At", @""), location.x]);
            }
        }
    }

    [super touchesCancelledWithEvent:event];
}

@end
