//
//  MIDIReciever.h
//  MidiKeyboard
//
//  Created by Volter on 20.04.14.
//  Copyright (c) 2014 volter9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@protocol MIDIReceiver <NSObject>

@optional
- (void)receiveMIDIInput: (NSArray *)packet;
- (void)receiveMIDINotification: (NSString *)message withNotification: (const MIDINotification *)notification;

@end
