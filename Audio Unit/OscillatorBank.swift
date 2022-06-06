//
//  OscillatorBank.swift
//  Oscillator Bank AU
//
//  Created by Aura Audio on 6/6/22.
//

import AVFoundation
import AudioKitEX
import CAudioKitEX
import AudioKit

/// Oscillator Bank.
public class OscillatorBank: Node {

    let input: Node
    
    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode = instantiate(effect: "osbk")

    // MARK: - Parameters

    /// Param one
    open var gain: AUValue = 1 {
        willSet {
            paramOne = newValue
        }
    }

    /// Specification details for paramOne
    public static let paramOneDef = NodeParameterDef(
        identifier: "paramOne",
        name: "Parameter One",
        address: akGetParameterAddress("OscillatorBankParameterOne"),
        defaultValue: 1,
        range: 0...100,
        unit: .generic)

    /// Arbitrary test parameter
    @Parameter(paramOneDef) public var paramOne: AUValue

    // MARK: - Initialization

    /// Initialize this oscillator bank node
    ///
    /// - Parameters:
    ///   - paramOne: An arbitrary test parameter
    ///
    public init(_ input: Node, paramOneInitValue: AUValue = 1) {
        self.input = input
        
        setupParameters()
        
        paramOne = paramOneInitValue
    }

    deinit {
        // Log("* { OscillatorBank }")
    }

    // MARK: - Automation

    /// Parameter automation helper
    /// - Parameters:
    ///   - events: List of events
    ///   - startTime: start time
    public func automateGain(events: [AutomationEvent], startTime: AVAudioTime? = nil) {
        $paramOne.automate(events: events, startTime: startTime)
    }

    /// Stop automation
    public func stopAutomation() {
        $paramOne.stopAutomation()
    }
}
