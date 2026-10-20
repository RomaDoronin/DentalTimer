//
//  BrushingStep.swift
//  DentalTimer
//

import Foundation

enum StepKind: String, Codable, Equatable {
    case stage
    case pause
}

struct BrushingStep: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var kind: StepKind
    var name: String
    var duration: TimeInterval

    static var defaultScenario: [BrushingStep] {
        [
            BrushingStep(kind: .pause, name: String(localized: "Get ready"), duration: 5),
            BrushingStep(kind: .stage, name: String(localized: "Upper left jaw"), duration: 30),
            BrushingStep(kind: .pause, name: String(localized: "Pause"), duration: 5),
            BrushingStep(kind: .stage, name: String(localized: "Upper right jaw"), duration: 30),
            BrushingStep(kind: .pause, name: String(localized: "Pause"), duration: 5),
            BrushingStep(kind: .stage, name: String(localized: "Lower right jaw"), duration: 30),
            BrushingStep(kind: .pause, name: String(localized: "Pause"), duration: 5),
            BrushingStep(kind: .stage, name: String(localized: "Lower left jaw"), duration: 30),
            BrushingStep(kind: .pause, name: String(localized: "Pause"), duration: 5),
            BrushingStep(kind: .stage, name: String(localized: "Front teeth"), duration: 40),
            BrushingStep(kind: .pause, name: String(localized: "Pause"), duration: 5),
            BrushingStep(kind: .stage, name: String(localized: "Irrigator"), duration: 60),
        ]
    }
}
