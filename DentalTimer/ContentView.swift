//
//  ContentView.swift
//  DentalTimer
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = SettingsStore()
    @State private var showTimer = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack(spacing: 8) {
                    Text("Dental Timer")
                        .font(.largeTitle.bold())
                    Text("Follow the guided brushing routine")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showTimer = true
                } label: {
                    Text("Start")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 240, height: 240)
                        .background(
                            Circle()
                                .fill(Color.accentColor)
                                .shadow(color: Color.accentColor.opacity(0.4), radius: 20, y: 10)
                        )
                }
                .buttonStyle(.plain)
                .disabled(settings.steps.isEmpty)
                .opacity(settings.steps.isEmpty ? 0.4 : 1.0)

                Spacer()

                Text(routineSummary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(settings: settings)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .fullScreenCover(isPresented: $showTimer) {
                TimerView(steps: settings.steps) {
                    showTimer = false
                }
            }
        }
    }

    private var routineSummary: LocalizedStringKey {
        let stageCount = settings.steps.filter { $0.kind == .stage }.count
        let total = settings.steps.reduce(0) { $0 + $1.duration }
        let minutes = Int(total) / 60
        let seconds = Int(total) % 60
        let timing: String = minutes > 0
            ? String(localized: "\(minutes) min \(seconds) sec")
            : String(localized: "\(seconds) sec")
        return "\(stageCount) stages • \(timing) total"
    }
}

#Preview {
    ContentView()
}
