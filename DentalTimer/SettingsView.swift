//
//  SettingsView.swift
//  DentalTimer
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @State private var editMode: EditMode = .active

    var body: some View {
        List {
            Section {
                ForEach($settings.steps) { $step in
                    StepRow(step: $step)
                }
                .onMove { source, destination in
                    settings.steps.move(fromOffsets: source, toOffset: destination)
                }
                .onDelete { indexSet in
                    settings.steps.remove(atOffsets: indexSet)
                }
            } header: {
                Text("Routine")
            } footer: {
                Text("Drag to reorder. Swipe to delete. Tap the stepper to change the duration.")
            }

            Section {
                Button {
                    settings.steps.append(
                        BrushingStep(kind: .stage, name: String(localized: "New stage"), duration: 20)
                    )
                } label: {
                    Label("Add stage", systemImage: "plus.circle.fill")
                }
                Button {
                    settings.steps.append(
                        BrushingStep(kind: .pause, name: String(localized: "Pause"), duration: 5)
                    )
                } label: {
                    Label("Add pause", systemImage: "pause.circle.fill")
                }
            }

            Section {
                Button(role: .destructive) {
                    settings.resetToDefault()
                } label: {
                    Label("Reset to default", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .environment(\.editMode, $editMode)
    }
}

private struct StepRow: View {
    @Binding var step: BrushingStep

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: step.kind == .stage ? "sparkles" : "pause.circle.fill")
                .foregroundStyle(step.kind == .stage ? Color.accentColor : Color.orange)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                if step.kind == .stage {
                    TextField("Stage name", text: $step.name)
                        .textFieldStyle(.plain)
                } else {
                    Text(step.name)
                        .foregroundStyle(.primary)
                }
                Group {
                    if step.kind == .stage {
                        Text("Stage")
                    } else {
                        Text("Pause")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Stepper(
                value: $step.duration,
                in: 1...600,
                step: 1
            ) {
                Text("\(Int(step.duration))s")
                    .monospacedDigit()
                    .font(.body.weight(.semibold))
                    .frame(minWidth: 44, alignment: .trailing)
            }
            .fixedSize()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        SettingsView(settings: SettingsStore())
    }
}
