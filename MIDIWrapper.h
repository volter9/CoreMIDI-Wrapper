//
//  MIDIWrapper.h
//  MidiKeyboard
//
//  Created by Volter on 20.04.14.
//  Copyright (c) 2014 volter9. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MIDIReceiver.h"

// CoreMIDI callbacks
void MIDIStateChange (
    const MIDINotification *notification,
    void                   *context
);

void MIDIOnInput (
    const MIDIPacketList *packets,
    void                 *context,
    void                 *sourceContext
);

@interface MIDIWrapper : NSObject {
    // Client
    MIDIClientRef client;
    
    // Ports
    MIDIPortRef inputPort;
    MIDIPortRef outputPort;
    
    // Devices
    NSMutableDictionary *devices;
    
    // Name of device to use
    NSString *deviceToUse;
    
    // Outside reciever
    id <MIDIReceiver> object;
}

- (id)initWithClientName: (NSString *)clientName inPort: (NSString *)iPort outPort: (NSString *)oPort;
- (void)sendData:  (NSArray *)data withDevice: (MIDIDeviceRef)device;
- (void)setReceiver: (id <MIDIReceiver>)reciever;
- (void)connectDevice: (MIDIDeviceRef)device;

- (MIDIObjectRef)getDevice: (NSString *)deviceName;
- (NSDictionary *)getDeviceList;
- (NSDictionary *)getInformationAboutDevice: (MIDIDeviceRef)device;
- (int)getNumberOf: (NSString *)type;

- (BOOL)isDeviceOnline: (MIDIDeviceRef)device;

// For receiver
- (void)sendNotificationMessageForReciever: (const MIDINotification *)notification;
- (void)sendInputMessagesForReciever:(MIDIPacketList *)packets;

@end
