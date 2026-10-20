//
//  TimerView.swift
//  DentalTimer
//

import SwiftUI

struct TimerView: View {
    @StateObject private var session: TimerSession
    let onFinish: () -> Void

    init(steps: [BrushingStep], onFinish: @escaping () -> Void) {
        _session = StateObject(wrappedValue: TimerSession(steps: steps))
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            if session.isFinished {
                CompletionView(onDismiss: onFinish)
            } else {
                runningBody
            }
        }
        .onAppear { session.start() }
        .onDisappear { session.stop() }
    }

    private var backgroundColor: Color {
        guard let step = session.currentStep else { return Color(.systemBackground) }
        return step.kind == .stage ? Color.accentColor.opacity(0.12) : Color.orange.opacity(0.10)
    }

    @ViewBuilder
    private var runningBody: some View {
        if let step = session.currentStep {
            VStack(spacing: 24) {
                header(for: step)

                Spacer()

                circularProgress(for: step)
                    .padding(.horizontal, 48)

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        session.togglePause()
                    } label: {
                        Group {
                            if session.isPaused {
                                Label("Resume", systemImage: "play.fill")
                            } else {
                                Label("Pause", systemImage: "pause.fill")
                            }
                        }
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(session.isPaused ? .green : .accentColor)

                    Button(role: .destructive) {
                        session.stop()
                        onFinish()
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
            .padding(.top, 40)
        }
    }

    private func circularProgress(for step: BrushingStep) -> some View {
        let tint = step.kind == .stage ? Color.accentColor : Color.orange
        return ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 18)

            TimelineView(.animation) { context in
                Circle()
                    .trim(from: 0, to: progress(for: step, at: context.date))
                    .stroke(
                        tint,
                        style: StrokeStyle(lineWidth: 18, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }

            Text(formatRemaining(session.remaining))
                .font(.system(size: 80, weight: .thin, design: .rounded).monospacedDigit())
                .contentTransition(.numericText())
                .opacity(session.isPaused ? 0.4 : 1.0)

            if session.isPaused {
                Text("PAUSED")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.secondary)
                    .tracking(2)
                    .padding(.top, 110)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func header(for step: BrushingStep) -> some View {
        VStack(spacing: 10) {
            if step.kind == .stage {
                Text("Stage \(session.currentStageNumber) of \(session.stageTotalCount)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(step.name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text(step.name.uppercased())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                if let nextStage = session.nextStage {
                    Text("Next: \(nextStage.name)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("Finishing up")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
            }
        }
    }

    private func progress(for step: BrushingStep, at date: Date) -> Double {
        guard step.duration > 0 else { return 0 }
        let elapsed: TimeInterval = session.isPaused
            ? step.duration - session.remaining
            : date.timeIntervalSince(session.currentStepStartDate)
        let value = elapsed / step.duration
        return min(max(value, 0), 1)
    }

    private func formatRemaining(_ seconds: TimeInterval) -> String {
        let total = Int(ceil(max(0, seconds)))
        let minutes = total / 60
        let secs = total % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, secs)
        } else {
            return "\(secs)"
        }
    }
}

private struct CompletionView: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 120))
                .foregroundStyle(.green)

            Text("Congratulations!")
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Text("You completed your brushing routine.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button(action: onDismiss) {
                Text("Done")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}
