//
//  PassThroughViewController.m
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

#import "PassThroughViewController.h"

@interface PassThroughViewController (){
  TPCircularBuffer _circularBuffer;
}
#pragma mark - UI Extras
@property (nonatomic,weak) IBOutlet UILabel *microphoneTextLabel;
@end

@implementation PassThroughViewController

#pragma mark - Customize the Audio Plot
- (void)viewDidLoad
{
  [super viewDidLoad];
    
    [self setupSocket];
    outputInitialized = false;
    
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [UIColor colorWithRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  
  /**
   Initialize the circular buffer
   */
    circularBufferSize = 2048; //Initially it was 2048
  [EZAudio circularBuffer:&_circularBuffer
                 withSize:circularBufferSize];
  
  /*
   Start the microphone
   */
//  [EZMicrophone sharedMicrophone].microphoneDelegate = self;
//  [[EZMicrophone sharedMicrophone] startFetchingAudio];
//  self.microphoneTextLabel.text = @"Microphone On";
  
  /**
   Start the output
   */

//  [EZOutput sharedOutput].outputDataSource = self;
   AudioStreamBasicDescription asbd = [EZOutput sharedOutput].audioStreamBasicDescription;
    asbd.mFormatFlags = 41;
    [[EZOutput sharedOutput] initWithDataSource:self withAudioStreamBasicDescription:asbd];
//    AudioStreamBasicDescription asbd = [EZMicrophone sharedMicrophone].audioStreamBasicDescription;
  [[EZOutput sharedOutput] startPlayback];
}

#pragma mark - Actions
-(void)changePlotType:(id)sender {
  NSInteger selectedSegment = [sender selectedSegmentIndex];
  switch(selectedSegment){
    case 0:
      [self drawBufferPlot];
      break;
    case 1:
      [self drawRollingPlot];
      break;
    default:
      break;
  }
}

-(void)toggleMicrophone:(id)sender {
  if( ![(UISwitch*)sender isOn] ){
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
    self.microphoneTextLabel.text = @"Microphone Off";
  }
  else {
    [[EZMicrophone sharedMicrophone] startFetchingAudio];
    self.microphoneTextLabel.text = @"Microphone On";
  }
}

#pragma mark - Action Extensions
/*
 Give the visualization of the current buffer (this is almost exactly the openFrameworks audio input eample)
 */
-(void)drawBufferPlot {
  // Change the plot type to the buffer plot
  self.audioPlot.plotType = EZPlotTypeBuffer;
  // Don't mirror over the x-axis
  self.audioPlot.shouldMirror = NO;
  // Don't fill
  self.audioPlot.shouldFill = NO;
}

/*
 Give the classic mirrored, rolling waveform look
 */
-(void)drawRollingPlot {
  self.audioPlot.plotType = EZPlotTypeRolling;
  self.audioPlot.shouldFill = YES;
  self.audioPlot.shouldMirror = YES;
}

#pragma mark - EZMicrophoneDelegate
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
//  });
}

// Append the AudioBufferList from the microphone callback to a global circular buffer
-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
//    AudioBuffer buffer = bufferList->mBuffers[0];
//    float *test = (float*)bufferList->mBuffers[0].mData;
////    float **test = (float**) buffer.mData;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.audioPlot updateBuffer:test withBufferSize:bufferSize];
//    });
//    
  /**
   Append the audio data to a circular buffer
   */
    
    //This will now be done on receiving a udp package
//  [EZAudio appendDataToCircularBuffer:&_circularBuffer
//                  fromAudioBufferList:bufferList];
}

#pragma mark - EZOutputDataSource
-(TPCircularBuffer *)outputShouldUseCircularBuffer:(EZOutput *)output {
  //return [EZMicrophone sharedMicrophone].microphoneOn ? &_circularBuffer : nil;
    return &_circularBuffer;
}

#pragma mark - Cleanup
-(void)dealloc {
  TPCircularBufferClear(&_circularBuffer);
}

- (void)setupSocket {
    tag = 0;
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    NSLog(@"Socket Ready");
    
}

- (IBAction)sendButtonClicked:(id)sender {
    NSString *host = _ipAddressTextField.text;
    if ([host length] == 0)
    {
        NSLog(@"Error, address required");
        return;
    }
    
    int port = [_portTextField.text intValue];
    if (port <= 0 || port > 65535)
    {
        NSLog(@"Error, valid port required");
        return;
    }
    
    NSString *msg = _messageTextField.text;
    if ([msg length] == 0)
    {
        NSLog(@"Error message required");
        return;
    }
    
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:tag];
    
    NSLog(@"SENT (%i): %@", (int)tag, msg);
    
    tag++;
}



-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    //For now see the data as text
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        NSLog(@"RECV: %@", msg);
    }
    else
    {
        //We received audio data, so lets play it!
        AudioBufferList *bufferList = [self decodeAudioBufferList:data];
        [EZAudio appendDataToCircularBuffer:&_circularBuffer
                            fromAudioBufferList:bufferList];

        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
    }
}

-(AudioBufferList *)decodeAudioBufferList:(NSData *)data{
    if (data.length > 0) {
        int nc = 2;
        AudioBufferList *abl = (AudioBufferList*) malloc(sizeof(AudioBufferList));
        abl->mNumberBuffers = nc;
        
        NSUInteger len = [data length];
        
        //Take the range of the first buffer
        NSUInteger olen = 0;
        // NSUInteger lenx = len / nc;
        NSUInteger step = len / nc;
        int i = 0;
        
        while (olen < len) {
            
            //NSData *d = [NSData alloc];
            NSData *pd = [data subdataWithRange:NSMakeRange(olen, step)];
            NSUInteger l = [pd length];
            
            Byte *byteData = (Byte*) malloc(l);
            memcpy(byteData, [pd bytes], l);
            
            if(byteData){
                
                //I think the zero should be 'i', but for some reason that doesn't work...
                abl->mBuffers[0].mDataByteSize = (UInt32)l;
                abl->mBuffers[0].mNumberChannels = 2;
                abl->mBuffers[0].mData = byteData;
            }
            
            //Update the range to the next buffer
            olen += step;
            //lenx = lenx + step;
            i++;
        }
        return abl;
    }
    return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)clickedBackground{
    [self.view endEditing:YES];
}

@end
