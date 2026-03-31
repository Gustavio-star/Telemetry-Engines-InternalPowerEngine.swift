// ContentView.swift
// Telemetry — Views/Dashboard
//
// Sprint 1: Status Dashboard
// Displays live battery telemetry. Updates every 2 seconds.
// No business logic here — only layout and binding.

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = DashboardViewModel()

    // Derive accent color from charger status
    private var wattageAccent: Color {
        switch vm.chargerStatus {
        case .charging:      return .green
        case .underpowered:  return .red
        case .balanced:      return .yellow
        case .notConnected:  return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Telemetry")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text("Power Engine · Sprint 1")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // Live pulse indicator
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                    .shadow(color: .green, radius: 4)
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
            }
            .padding([.horizontal, .top], 20)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 20)

            // ── Charger Status Banner ────────────────────────────────
            HStack(spacing: 8) {
                Image(systemName: chargerIcon)
                    .foregroundStyle(wattageAccent)
                Text(vm.chargerStatus.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(wattageAccent)
                Spacer()
                Text(vm.adapterLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(wattageAccent.opacity(0.08))

            // ── Metric Grid ──────────────────────────────────────────
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                MetricTileView(
                    title: "Instant Wattage",
                    value: vm.wattage,
                    accent: wattageAccent
                )
                MetricTileView(
                    title: "Charge Level",
                    value: vm.chargePercent,
                    accent: .primary
                )
                MetricTileView(
                    title: "Battery Health",
                    value: vm.batteryHealth,
                    accent: healthAccent
                )
                MetricTileView(
                    title: "Cycle Count",
                    value: vm.cycleCount,
                    accent: .primary
                )
                MetricTileView(
                    title: "Voltage",
                    value: vm.voltage,
                    accent: .primary
                )
                MetricTileView(
                    title: "Temperature",
                    value: vm.temperature,
                    accent: tempAccent
                )
            }
            .padding(20)

            // ── Footer ───────────────────────────────────────────────
            Divider()
                .padding(.horizontal, 20)
            HStack {
                Text("IOKit · AppleSmartBattery")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("Updated \(vm.lastUpdated.formatted(date: .omitted, time: .standard))")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .frame(width: 460)
        .background(.windowBackground)
    }

    // MARK: Derived Accents

    private var chargerIcon: String {
        switch vm.chargerStatus {
        case .notConnected:  return "battery.75"
        case .charging:      return "bolt.fill"
        case .balanced:      return "equal.circle"
        case .underpowered:  return "exclamationmark.triangle.fill"
        }
    }

    private var healthAccent: Color {
        guard let val = Double(vm.batteryHealth.replacingOccurrences(of: "%", with: "")) else {
            return .primary
        }
        if val >= 80 { return .green }
        if val >= 60 { return .yellow }
        return .red
    }

    private var tempAccent: Color {
        guard let val = Double(vm.temperature.replacingOccurrences(of: " °C", with: "")) else {
            return .primary
        }
        if val < 40 { return .green }
        if val < 55 { return .yellow }
        return .red
    }
}

#Preview {
    ContentView()
}
