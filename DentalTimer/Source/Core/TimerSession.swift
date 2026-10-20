//
//  TimerSession.swift
//  DentalTimer
//

import AudioToolbox
import Foundation
import Combine

@MainActor
final class TimerSession: ObservableObject {
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var remaining: TimeInterval = 0
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var currentStepStartDate: Date = Date()

    let steps: [BrushingStep]
    private var runnerTask: Task<Void, Never>?
    private var pauseStartDate: Date?

    private var saveLeft: Int = 0

    init(steps: [BrushingStep]) {
        self.steps = steps
        self.remaining = steps.first?.duration ?? 0
    }

    deinit {
        runnerTask?.cancel()
    }

    var currentStep: BrushingStep? {
        guard steps.indices.contains(currentIndex) else { return nil }
        return steps[currentIndex]
    }

    var nextStage: BrushingStep? {
        guard currentIndex < steps.count else { return nil }
        for index in (currentIndex + 1)..<steps.count where steps[index].kind == .stage {
            return steps[index]
        }
        return nil
    }

    var stageTotalCount: Int {
        steps.filter { $0.kind == .stage }.count
    }

    var currentStageNumber: Int {
        guard currentIndex < steps.count else { return stageTotalCount }
        return steps.prefix(currentIndex + 1).filter { $0.kind == .stage }.count
    }

    func start() {
        guard runnerTask == nil else { return }
        currentIndex = 0
        isFinished = false
        isPaused = false
        pauseStartDate = nil
        remaining = steps.first?.duration ?? 0
        runnerTask = Task { [weak self] in
            await self?.run()
        }
    }

    func stop() {
        runnerTask?.cancel()
        runnerTask = nil
        isPaused = false
        pauseStartDate = nil
    }

    func pause() {
        guard runnerTask != nil, !isPaused, !isFinished else { return }
        isPaused = true
        pauseStartDate = Date()
    }

    func resume() {
        guard isPaused, let pauseStart = pauseStartDate else { return }
        let pauseDuration = Date().timeIntervalSince(pauseStart)
        currentStepStartDate = currentStepStartDate.addingTimeInterval(pauseDuration)
        pauseStartDate = nil
        isPaused = false
    }

    func togglePause() {
        if isPaused { resume() } else { pause() }
    }

    private func run() async {
        while currentIndex < steps.count {
            if Task.isCancelled { return }
            let step = steps[currentIndex]
            let duration = step.duration
            currentStepStartDate = Date()
            remaining = duration

            while !Task.isCancelled {
                if isPaused {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    continue
                }
                let elapsed = Date().timeIntervalSince(currentStepStartDate)
                let left = duration - elapsed

                prepareForPlayingSystemSound(left: left)
                
                if left <= 0 {
                    remaining = 0
                    break
                }
                remaining = left

                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            if Task.isCancelled { return }
            currentIndex += 1
        }
        isFinished = true
        runnerTask = nil
    }

    private func prepareForPlayingSystemSound(left: TimeInterval) {
        let ceilLeft = Int(ceil(max(0, left)))

        if saveLeft != ceilLeft {
            saveLeft = ceilLeft

            switch saveLeft {
            case 3:
                playSystemSound(resource: .low)
            case 2:
                playSystemSound(resource: .low)
            case 1:
                playSystemSound(resource: .low)
            case 0:
                playSystemSound(resource: .high)
            default:
                break
            }
        }
    }

    enum SystemSound: String {
        case high = "music_high"
        case low = "music_low"
    }

    private func playSystemSound(resource: SystemSound) {
        guard let url = Bundle.main.url(forResource: resource.rawValue, withExtension: "wav") else { return }
        
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
}
