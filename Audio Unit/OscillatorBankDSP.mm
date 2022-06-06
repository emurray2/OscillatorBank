//
//  OscillatorBankDSP.mm
//  Oscillator Bank AU
//
//  Created by Aura Audio on 6/6/22.
//

#include "DSPBase.h"
#include "ParameterRamper.h"

enum OscillatorBankParameter : AUParameterAddress {
    OscillatorBankParameterOne = 0,
};

struct OscillatorBankDSP : DSPBase {
private:
    ParameterRamper paramOneRamp{1.0};

public:
    OscillatorBankDSP() : DSPBase(1, true) {
        parameters[OscillatorBankParameterOne] = &paramOneRamp;
    }

    // Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, AUValue value, bool immediate) override {
        switch (address) {
            default:
                DSPBase::setParameter(address, value, immediate);
        }
    }

    // Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            default:
                return DSPBase::getParameter(address);
        }
    }

    void startRamp(const AUParameterEvent &event) override {
        auto address = event.parameterAddress;
        switch (address) {
            default:
                DSPBase::startRamp(event);
        }
    }

    void process(FrameRange range) override {
        for (auto i : range) {

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float& leftOut = outputSample(0, i);
            float& rightOut = outputSample(1, i);

            float paramOne = paramOneRamp.getAndStep();

            leftOut = leftIn;
            rightOut = rightIn;
        }
    }
};
AK_REGISTER_DSP(OscillatorBankDSP, "osbk")
AK_REGISTER_PARAMETER(OscillatorBankParameterOne)
