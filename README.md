# CoreMIDI Wrapper

This is repository of Objective-C wrapper for Apple C API for MIDI called CoreMIDI.

Wrapper has several features:

* Create client, output and input ports.
* Get list of devices.
* Get information about device.
* Get number of devices/external devices/sources.
* Get specific device by its name (First you need to look up for devices, point #2 above).
* Connect device to the input port.
* Receive input from MIDI device.
* Send MIDI commands.
* Get the status of device.
* And track the changes of MIDI system.

## Requirements

You have to add to your XCode Objective-C OS X project CoreMIDI framework.

## Examples:

Note: all the methods doing what their sounds to do.

### Create client, output and input ports

To create the MIDIWrapper instance just write code like this:

``MIDIWrapper *midi = [[MIDIWrapper alloc] initWithClientName:@"Client" inPort:@"Input Port" outPort:@"Output Port"];``

This code would create an instance of MIDIWrapper and client, input and output ports.

### Get list of devices

Next you can check which devices are available:

``NSLog(@"%@", [midi getDeviceList]);``

This will log the NSDictionary of devices that available, the key is the name of device and the object is the MIDIDeviceRef, a reference to device.

### Get specific device by its name

When you checked which device you wish to get, you can use getDevice: (NSString *)device :

``MIDIDeviceRef myKeyboard = [midi getDevice:@"Keystation Mini 32"];``

This code will return you a reference to the 'Keystation Mini 32' device (which is a small keyboard that I have).

### Get information about device

If you want to know more about the device, you can use getInformationAboutDevice: (MIDIDeviceRef) device :

``NSLog(@"%@", [midi getInformationAboutDevice: myKeyboard]);`` 

This will log you all available information about your MIDI device.

### Get number of devices/external devices/sources

If you curious how many source or devices do you have, you can use getNumberOf: (NSString *)name, just like that:

``NSLog(@"I have %i devices", [midi getNumberOf:@"Devices"];``

This code will output how many devices do you have.

### Connect device to the input port

To get the input from your MIDI device you first need to connect your device with input port:

``[midi connectDevice: myKeyboard];``

This will connect you MIDI device to the input port and you could get input.

### Receive input from MIDI device

To receive input commands from MIDI device you need first add to your interface MIDIReceiver and add method receiveMIDIInput:

	// ... Some code above
	#import "MIDIReceiver.h"

	@interface YourAwesomeClass : NSObject <MIDIReceiver> {
	// ...
	}

	// ...

	- (void)receiveMIDIInput: (NSArray *)packet;``

	Then add the method to implementation:

	``@implementation YourAwesomeClass

	- (void)receiveMIDIInput: (NSArray *)packet {
		NSLog(@"%@", packet);
	}

And finally set the receiver to your self object where you've written the rest of code with MIDIWrapper:

``[midi setReceiver: self];``

This code will add the receiver to the wrapper and the receiveMIDIInput method would be called in with the packet array.
Read more about MIDI to understand about the MIDI input packet.

### Send MIDI commands

Some devices has commands, for example, my Launchpad has whole document about programming the device. To fill one button with color there's the command for it.
To send the command, you have to prepare an array of unsigned int that wrapped into a NSNumber, like that:

``NSArray *command = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:0xB0], [NSNumber numberWithUnsignedInt:0x00], [NSNumber numberWithUnsignedInt:0x7F],nil];

[midi sendData: command withDevice: launchpad];``

This code would send my launchpad a command that would light up all the buttons on its grid.
For more information about the launchpad's commands click [here](http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4700/launchpad-s-prm.pdf "Launchpad Programming Guide").

### And get the status of device

To get the status of device (is it online or offline) use method isDeviceOnline: (MIDIDeviceRef) device, like that:

``NSLog(@"My device is %i", (int)[self isDeviceOnline:myKeyboard]);``

This will log the status, 1 is online, 0 is offline, just like boolean converted to int.

### Track the changes of MIDI system

To track the changes in MIDI system, if you already set the receiver, then you can add another method from MIDIReceiver's protocol receiveMIDINotification: withNotification:, like that:

	// Implementation

	- (void)receiveMIDINotification: (NSString *)message withNotification: (const MIDINotification *)notification {
		NSLog(@"%@", message);
	}

	// More code

This will display message in log (the bottom part of the XCode). You can retrieve more information using notification argument, for more information about MIDINotification look up the [reference](https://developer.apple.com/library/mac/documentation/MusicAudio/Reference/CACoreMIDIRef/MIDIServices/index.html "MIDINotification").
Search for MIDINotification in Structs & Unions.

That's it.

### Aftermath

For further reference read about OS X's [CoreMIDI API](https://developer.apple.com/library/mac/documentation/MusicAudio/Reference/CACoreMIDIRef/MIDIServices/index.html "CoreMIDI Apple Dev Center").

The Wrapper may work on iOS as well as on OS X, but I don't have such opportunity to test. 
If you want to test it on iOS, please feel free to share the result here in the Wiki or Issue tracker :)