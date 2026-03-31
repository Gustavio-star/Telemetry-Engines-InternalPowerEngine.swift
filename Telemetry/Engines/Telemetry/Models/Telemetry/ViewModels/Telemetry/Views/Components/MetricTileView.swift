// MetricTileView.swift
// Telemetry — Views/Components
//
// A single labeled metric card. Used across all dashboard sections.
// Intentionally has zero business logic — display only.

import SwiftUI

struct MetricTileView: View {
    let title: String
    let value: String
    var accent: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MetricTileView(title: "Wattage", value: "18.42 W", accent: .green)
        .frame(width: 200)
        .padding()
}
