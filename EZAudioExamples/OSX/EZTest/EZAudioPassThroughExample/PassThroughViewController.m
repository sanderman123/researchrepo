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
//  TPCircularBuffer _circularBuffer;
}
@end

@implementation PassThroughViewController
@synthesize audioPlot;
@synthesize microphone;
@synthesize server;
@synthesize portTextField;
@synthesize microphoneToggler;
@synthesize startServerButton;
@synthesize startStreamButton;

#pragma mark - Initialization
-(id)init {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
    [self initializeView];
  }
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
    [self initializeView];
  }
  return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
  if(self){
    [self initializeView];
  }
  return self;
}

-(void)initializeView {
    serverStarted = false;
    streaming = false;
    
  /**
   Initialize the circular buffer
   */
//  [EZAudio circularBuffer:&_circularBuffer withSize:2048];
}

#pragma mark - Customize the Audio Plot
-(void)awakeFromNib {
  
  /*
   Customizing the audio plot's look
   */
  // Background color
  self.audioPlot.backgroundColor = [NSColor colorWithCalibratedRed: 0.569 green: 0.82 blue: 0.478 alpha: 1];
  // Waveform color
  self.audioPlot.color           = [NSColor colorWithCalibratedRed: 1.000 green: 1.000 blue: 1.000 alpha: 1];
  // Plot type
  self.audioPlot.plotType        = EZPlotTypeBuffer;
  
  /*
   Start the microphone
   */
  [EZMicrophone sharedMicrophone].microphoneDelegate = self;
  //[[EZMicrophone sharedMicrophone] startFetchingAudio];
    
    [self toggleMicrophone: microphoneToggler];

  
  /**
   Start the output
//   */
//  [[EZOutput sharedOutput] setAudioStreamBasicDescription:[EZMicrophone sharedMicrophone].audioStreamBasicDescription];
//  [EZOutput sharedOutput].outputDataSource = self;
//  [[EZOutput sharedOutput] startPlayback];
//    
//    //Set the recorder
//    recorder = [EZRecorder recorderWithDestinationURL:
//                [NSURL fileURLWithPath:kAudioFilePath]
//                                         sourceFormat:self.microphone.audioStreamBasicDescription
//                                  destinationFileType:EZRecorderFileTypeWAV];
  
}

#pragma mark - Actions
-(void)changePlotType:(id)sender {
  NSInteger selectedSegment = [sender selectedSegment];
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
  switch([sender state]){
    case NSOffState:
      [[EZMicrophone sharedMicrophone] stopFetchingAudio];
      break;
    case NSOnState:
      [[EZMicrophone sharedMicrophone] startFetchingAudio];
      break;
    default:
      break;
  }
}

- (IBAction)startServerButtonClicked:(id)sender {
    server = [[Server alloc] init];
    
    //21369 or 0
    [server createServerOnPort:[portTextField intValue]];
    serverStarted = true;
}

- (IBAction)startStreamButtonClicked:(id)sender {
    if (serverStarted) {
        
        if (!streaming) {
            //Start stream
            startStreamButton.stringValue = [NSString stringWithFormat:@"Stop stream"];
            streaming = true;
            
            
            //First test sending data
            /*NSString *testString = @"test";
             NSData *testData = [testString dataUsingEncoding:NSUTF8StringEncoding];
             [server send:testData];*/
        } else {
            startStreamButton.stringValue = [NSString stringWithFormat:@"Start stream"];
            streaming = false;
        }
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
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
  });
}

// Append the AudioBufferList from the microphone callback to a global circular buffer
-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    //Test encoding and decoding:
    NSData *data = [self encodeAudioBufferList:bufferList];
    
    if (streaming) {
        
//        AudioStreamBasicDescription asbd = [EZMicrophone sharedMicrophone].audioStreamBasicDescription;
        
        [server send:data];
    }
    
    
    
    
//    AudioBufferList abl = *[self decodeAudioBufferList:data];
    
    
    
  /**
   Append the audio data to a circular buffer
   */
//  [EZAudio appendDataToCircularBuffer:&_circularBuffer
//                  fromAudioBufferList:bufferList];
//
    
//    [EZAudio appendDataToCircularBuffer:&_circularBuffer
//                       fromAudioBufferList:&abl];
    
    
    
    
    
    
    _label1.stringValue = [NSString stringWithFormat:@"Buffer size: %i", bufferSize];
    
    
}

//#pragma mark - EZOutputDataSource
//-(TPCircularBuffer *)outputShouldUseCircularBuffer:(EZOutput *)output {
//  return [EZMicrophone sharedMicrophone].microphoneOn ? &_circularBuffer : nil;
//}

#pragma mark - Cleanup
-(void)dealloc {
//  [EZAudio freeCircularBuffer:&_circularBuffer];
}

- (NSData *)encodeAudioBufferList:(AudioBufferList *)abl {
    NSMutableData *data = [NSMutableData data];
    
    for (int y = 0; y < abl->mNumberBuffers; y++){
        AudioBuffer ab = abl->mBuffers[y];
        Float32 *frame = (Float32*)ab.mData;
        [data appendBytes:frame length:ab.mDataByteSize];
    }
    
    return data;
}

- (AudioBufferList *)decodeAudioBufferList:(NSData *)data {
    
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

@end
