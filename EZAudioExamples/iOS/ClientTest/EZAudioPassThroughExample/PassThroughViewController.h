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

#import <UIKit/UIKit.h>

// Import EZAudio header
#import "EZAudio.h"

// Import AsyncUdpSocket header
#import "GCDAsyncUdpSocket.h"

@interface PassThroughViewController : UIViewController <EZMicrophoneDelegate,EZOutputDataSource,UITextFieldDelegate,GCDAsyncUdpSocketDelegate>{
    BOOL outputInitialized;
    int circularBufferSize;
    GCDAsyncUdpSocket *udpSocket;
    long tag;
}
@property (weak, nonatomic) IBOutlet UITextField *ipAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

#pragma mark - Components
/**
 The OpenGL based audio plot
 */
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;

#pragma mark - Actions
/**
 Switches the plot drawing type between a buffer plot (visualizes the current stream of audio data from the update function) or a rolling plot (visualizes the audio data over time, this is the classic waveform look)
 */
-(IBAction)changePlotType:(id)sender;

/**
 Toggles the microphone on and off. When the microphone is on it will send its delegate (aka this view controller) the audio data in various ways (check out the EZMicrophoneDelegate documentation for more details);
 */
-(IBAction)toggleMicrophone:(id)sender;

-(void) setupSocket;
- (IBAction)sendButtonClicked:(id)sender;

- (AudioBufferList *) decodeAudioBufferList: (NSData *) data;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)clickedBackground;

@end
