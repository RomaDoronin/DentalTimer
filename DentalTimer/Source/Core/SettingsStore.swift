//
//  SettingsStore.swift
//  DentalTimer
//

import Foundation
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    @Published var steps: [BrushingStep] {
        didSet { save() }
    }

    private let storageKey = "DentalTimer.Steps.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BrushingStep].self, from: data) {
            self.steps = decoded
        } else {
            self.steps = BrushingStep.defaultScenario
        }
    }

    func resetToDefault() {
        steps = BrushingStep.defaultScenario
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(steps) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
