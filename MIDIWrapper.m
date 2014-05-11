//
//  MIDIWrapper.m
//  MidiKeyboard
//
//  Created by Volter on 20.04.14.
//  Copyright (c) 2014 volter9. All rights reserved.
//

#import "MIDIWrapper.h"

// MIDI Callbacks
void MIDIStateChange (
    const MIDINotification *notification,
    void                   *context
) { // MIDIStateChange
    @autoreleasepool {
        id wrapper = (__bridge id)context;
        
        [wrapper sendNotificationMessageForReciever:notification];
    }
}

void MIDIOnInput (
    const MIDIPacketList *packets,
    void                 *context,
    void                 *sourceContext
) { // MIDIOnInput function
    @autoreleasepool {
        id wrapper = (__bridge id)context;
        
        [wrapper sendInputMessagesForReciever:(MIDIPacketList *)packets];
    }
}

@interface MIDIWrapper(Private)

- (void)initDevices;

@end

@implementation MIDIWrapper

// Initiating stuff

- (void)initDevices {
    if ([devices count] > 0) {
        [devices removeAllObjects];
    }
    
    int deviceNum = [self getNumberOf:@"Devices"];
    for (int i = 0; i < deviceNum; i++) {
        MIDIDeviceRef device = MIDIGetDevice(i);
        
        if (device) {
            CFStringRef name;
            if (MIDIObjectGetStringProperty(device, kMIDIPropertyName, &name) == noErr) {
                [devices setObject:[NSNumber numberWithUnsignedInt:device] forKey:(__bridge NSString *)name];
            }
            CFRelease(name);
        }
    }
}

- (id)initWithClientName:(NSString *)clientName inPort:(NSString *)iPort outPort:(NSString *)oPort {
    if (self = [super init]) {
        MIDIClientCreate((__bridge CFStringRef)clientName, (MIDINotifyProc)MIDIStateChange, (__bridge void *)(self), &client);
        MIDIInputPortCreate(client, (__bridge CFStringRef)iPort, MIDIOnInput, (__bridge void *)(self), &inputPort);
        MIDIOutputPortCreate(client, (__bridge CFStringRef)oPort, &outputPort);
        
        devices = [[NSMutableDictionary alloc] init];
        
        [self initDevices];
    }
    return self;
}

// Senders

- (void)sendData: (NSArray *)data withDevice:(MIDIDeviceRef)device {
    Byte *array = malloc(sizeof(Byte) * [data count]);
    for (int i = 0; i < [data count]; i++) {
        NSNumber *number = [data objectAtIndex:i];
        
        array[i] = [number unsignedIntValue];
    }
    
    MIDIEndpointRef entity = MIDIDeviceGetEntity(device, 0);
    MIDIEndpointRef destination = MIDIEntityGetDestination(entity, 0);
    
    char buffer[1024];
    MIDIPacketList *packets = (MIDIPacketList *)buffer;
    
    MIDIPacket *packet = MIDIPacketListInit(packets);
    packet = MIDIPacketListAdd(packets, 1024, packet, 0, [data count], array);
    
    MIDISend(outputPort, destination, packets);
    
    free(array);
}

// Connection

- (void)connectDevice: (MIDIDeviceRef)device {
    MIDIEndpointRef entity = MIDIDeviceGetEntity(device, 0);
    MIDIEndpointRef source = MIDIEntityGetSource(entity, 0);
    
    MIDIPortConnectSource(inputPort, source, NULL);
}

// Setters

- (void)setReceiver: (id <MIDIReceiver>)reciever {
    if ([reciever isKindOfClass:[NSObject class]]) {
        object = reciever;
    }
}

// Getters

- (NSDictionary *)getDeviceList {
    return devices;
}

- (MIDIObjectRef)getDevice:(NSString *)deviceName {
    NSNumber *number = [devices objectForKey:deviceName];
    
    return (MIDIObjectRef)[number unsignedIntValue];
}

- (NSDictionary *)getInformationAboutDevice:(MIDIDeviceRef)device {
    NSDictionary *dict;
    
    MIDIObjectGetProperties(device, (CFPropertyListRef)&dict, YES);
    
    return dict;
}

- (int)getNumberOf:(NSString *)type {
    int number = 0;
    
    if ([type isEqualToString:@"Sources"]) {
        number = (int)MIDIGetNumberOfSources();
    }
    else if ([type isEqualToString:@"Devices"]) {
        number = (int)MIDIGetNumberOfDevices();
    }
    else if ([type isEqualToString:@"ExtrenalDevices"]) {
        number = (int)MIDIGetNumberOfExternalDevices();
    }
    
    return number;
}

- (BOOL)isDeviceOnline: (MIDIDeviceRef)device {
    NSDictionary *dict = [self getInformationAboutDevice:device];
    
    if ([[dict objectForKey:@"offline"] intValue] == 0) {
        return YES;
    }
    
    return NO;
}

// For receiver
- (void)sendNotificationMessageForReciever: (const MIDINotification *)notification {
    if (object != nil) {
        NSString *message;
        
        switch (notification->messageID) {
            case kMIDIMsgSetupChanged:
                message = [NSString stringWithFormat:@"%i: Setup has changed.", notification->messageID];
                break;
                
            case kMIDIMsgObjectAdded:
                message = [NSString stringWithFormat:@"%i: Object was added.", notification->messageID];
                break;
                
            case kMIDIMsgObjectRemoved:
                message = [NSString stringWithFormat:@"%i: Object was removed.", notification->messageID];
                break;
                
            case kMIDIMsgPropertyChanged:
                message = [NSString stringWithFormat:@"%i: Property was changed.", notification->messageID];
                break;
                
            default:
                message = @"";
                break;
        }
        
        [object receiveMIDINotification:message withNotification:notification];
    }
}

- (void)sendInputMessagesForReciever:(MIDIPacketList *)packets {
    if (packets->numPackets > 0 && object != nil) {
        MIDIPacket packet = packets->packet[0];
        
        NSArray *array = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInt:packet.data[0]],
                                                          [NSNumber numberWithUnsignedInt:packet.data[1]],
                                                          [NSNumber numberWithUnsignedInt:packet.data[2]], nil];
        
        [object receiveMIDIInput:array];
    }
}

@end
