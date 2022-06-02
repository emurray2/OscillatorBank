// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import <AVFoundation/AVFoundation.h>
#import <CoreAudioKit/AUViewController.h>
#import "DSPKernel.hpp"
#import "BufferedAudioBus.hpp"
#import "OscillatorBank_AU_iOSDSPKernel.hpp"
#import "OscillatorBank_AU_iOSDSPKernelAdapter.h"

@implementation OscillatorBank_AU_iOSDSPKernelAdapter {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    OscillatorBank_AU_iOSDSPKernel  _kernel;
    BufferedOutputBus _outputBusBuffer;
}

- (instancetype)init {

    if (self = [super init]) {
        AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100. channels:2];
        // Create a DSP kernel to handle the signal processing.
        _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);
        _kernel.setParameter(paramOne, 0);

        // Create the output bus.
        _outputBusBuffer.init(defaultFormat, 2);
        _outputBus = _outputBusBuffer.bus;
    }
    return self;
}

- (void)setParameter:(AUParameter *)parameter value:(AUValue)value {
    _kernel.setParameter(parameter.address, value);
}

- (AUValue)valueForParameter:(AUParameter *)parameter {
    return _kernel.getParameter(parameter.address);
}

- (AUAudioFrameCount)maximumFramesToRender {
    return _kernel.maximumFramesToRender();
}

- (void)setMaximumFramesToRender:(AUAudioFrameCount)maximumFramesToRender {
    _kernel.setMaximumFramesToRender(maximumFramesToRender);
}

- (BOOL)shouldBypassEffect {
    return _kernel.isBypassed();
}

- (void)setShouldBypassEffect:(BOOL)bypass {
    _kernel.setBypass(bypass);
}

- (void)allocateRenderResources {
    _outputBusBuffer.allocateRenderResources(self.maximumFramesToRender);
    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();
}

- (void)deallocateRenderResources {
    _outputBusBuffer.deallocateRenderResources();
}

// MARK: -  AUAudioUnit (AUAudioUnitImplementation)

// Subclassers must provide a AUInternalRenderBlock (via a getter) to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    // Specify captured objects are mutable.
    __block OscillatorBank_AU_iOSDSPKernel *state = &_kernel;
    __block BufferedOutputBus *outputBusBuffer = &_outputBusBuffer;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags 				*actionFlags,
                              const AudioTimeStamp       				*timestamp,
                              AVAudioFrameCount           				frameCount,
                              NSInteger                   				outputBusNumber,
                              AudioBufferList            				*outputData,
                              const AURenderEvent        				*realtimeEventListHead,
                              AURenderPullInputBlock __unsafe_unretained pullInputBlock) {

        outputBusBuffer->prepareOutputBufferList(outputData, frameCount, true);
        state->setBuffers(outputData);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead, nil);

        return noErr;
    };
}

@end
