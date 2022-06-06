//
//  Oscillator_Bank_AUAudioUnit.h
//  Oscillator Bank AU
//
//  Created by Aura Audio on 6/6/22.
//

#import <AudioToolbox/AudioToolbox.h>
#import "Oscillator_Bank_AUDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface Oscillator_Bank_AUAudioUnit : AUAudioUnit

@property (nonatomic, readonly) Oscillator_Bank_AUDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
