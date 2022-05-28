// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#ifndef OscillatorBank_AU_macOSDSPKernel_hpp
#define OscillatorBank_AU_macOSDSPKernel_hpp

#import "DSPKernel.hpp"

enum {
    paramOne = 0,
};

/*
 OscillatorBank_AU_macOSDSPKernel
 Performs simple copying of the input signal to the output.
 As a non-ObjC class, this is safe to use from render thread.
 */
class OscillatorBank_AU_macOSDSPKernel : public DSPKernel {
public:
    
    // MARK: Member Functions

    OscillatorBank_AU_macOSDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        chanCount = channelCount;
        sampleRate = float(inSampleRate);
        waveform.resize(4096);
        setupWaveform();
    }

    void reset() {
    }

    bool isBypassed() {
        return bypassed;
    }

    void setBypass(bool shouldBypass) {
        bypassed = shouldBypass;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case paramOne:

                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case paramOne:
                // Return the goal. It is not thread safe to return the ramping value.
                return 0.f;

            default: return 0.f;
        }
    }

    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void setupWaveform() {
        for (int i = 0; i < waveform.size(); ++i) {
            waveform[i] = sin(twoPi * i / waveform.size());
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        if (bypassed) {
            // Pass the samples through
            for (int channel = 0; channel < chanCount; ++channel) {
                if (inBufferListPtr->mBuffers[channel].mData ==  outBufferListPtr->mBuffers[channel].mData) {
                    continue;
                }
                
                for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                    const int frameOffset = int(frameIndex + bufferOffset);
                    const float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                    float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                    *out = *in;
                }
            }
            return;
        }
        
        // Perform per sample dsp on the incoming float *in before assigning it to *out
        for (int channel = 0; channel < chanCount; ++channel) {
        
            // Get pointer to immutable input buffer and mutable output buffer
            const float* in = (float*)inBufferListPtr->mBuffers[channel].mData;
            float* out = (float*)outBufferListPtr->mBuffers[channel].mData;
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                const int frameOffset = int(frameIndex + bufferOffset);
                
                // Do your sample by sample dsp here...
                out[frameOffset] = in[frameOffset];
            }
        }
    }

    // MARK: Member Variables

private:
    int chanCount = 0;
    float sampleRate = 44100.0;
    const float twoPi = 2.0 * M_PI;
    std::vector<float> waveform;
    bool bypassed = false;
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
};

#endif /* OscillatorBank_AU_macOSDSPKernel_hpp */
