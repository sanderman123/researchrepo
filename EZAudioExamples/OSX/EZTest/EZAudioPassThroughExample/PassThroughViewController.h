//
//  PassThroughViewController.h
//  EZAudioPassThroughExample
//
//  Created by Syed Haris Ali on 12/20/13.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Cocoa/Cocoa.h>

/**
 Import EZAudio
 */
#import "EZAudio.h"
#import "Server.h"

// By default this will record a file to /Users/YOUR_USERNAME/Desktop/test.wav
#define kAudioFilePath [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),@"/Desktop/test1.wav"]

@interface PassThroughViewController : NSViewController <EZMicrophoneDelegate,EZOutputDataSource>{
    BOOL serverStarted;
    BOOL streaming;
}
@property (weak) IBOutlet NSTextField *label1;
@property (weak) IBOutlet NSButton *startServerButton;
@property (weak) IBOutlet NSButton *startStreamButton;
@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSButton *microphoneToggler;

@property (nonatomic,strong) Server* server;

#pragma mark - Components
/**
 The OpenGL based audio plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;

/**
 The Microphone
 */
@property (nonatomic,strong) EZMicrophone *microphone;


#pragma mark - Actions
/**
 Switches the plot drawing type between a buffer plot (visualizes the current stream of audio data from the update function) or a rolling plot (visualizes the audio data over time, this is the classic waveform look)
 */
-(IBAction)changePlotType:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleMicrophone:(id)sender;

- (IBAction)startServerButtonClicked:(id)sender;
- (IBAction)startStreamButtonClicked:(id)sender;

//Encode and decode functions
- (NSData *) encodeAudioBufferList: (AudioBufferList *) abl;

- (AudioBufferList *) decodeAudioBufferList: (NSData *) data;



@end
