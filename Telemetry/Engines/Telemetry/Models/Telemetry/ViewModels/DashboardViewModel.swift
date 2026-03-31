// DashboardViewModel.swift
// Telemetry — ViewModels Layer
//
// Bridges InternalPowerEngine → SwiftUI views.
// Owns the polling timer. Views never touch IOKit directly.

import Foundation
import Combine
import SwiftUI

@MainActor
public final class DashboardViewModel: ObservableObject {

    // MARK: Published State (Views bind to these)

    @Published public var wattage:        String = "--"
    @Published public var chargePercent:  String = "--"
    @Published public var batteryHealth:  String = "--"
    @Published public var cycleCount:     String = "--"
    @Published public var temperature:    String = "--"
    @Published public var voltage:        String = "--"
    @Published public var chargerStatus:  ChargerStatus = .notConnected
    @Published public var adapterLabel:   String = "No Adapter"
    @Published public var lastUpdated:    Date = .now

    // MARK: Private

    private let engine = InternalPowerEngine()
    private var timerCancellable: AnyCancellable?

    // MARK: Lifecycle

    public init() {
        refresh()                    // Immediate first read
        startPolling(every: 2.0)     // Then every 2 seconds
    }

    // MARK: Polling

    private func startPolling(every seconds: Double) {
        timerCancellable = Timer.publish(every: seconds, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.refresh() }
    }

    // MARK: Data Refresh

    private func refresh() {
        guard let snapshot = engine.captureSnapshot() else {
            // No battery found (Mac Pro / Mac mini without battery)
            wattage       = "N/A"
            chargePercent = "N/A"
            return
        }

        let status = engine.evaluateChargerStatus(snapshot: snapshot)

        // Format for display
        wattage       = String(format: "%.2f W", abs(snapshot.instantWattage))
        chargePercent = String(format: "%.1f%%", snapshot.chargePercent)
        batteryHealth = String(format: "%.1f%%", snapshot.batteryHealth)
        cycleCount    = "\(snapshot.cycleCount)"
        temperature   = String(format: "%.1f °C", snapshot.temperature)
        voltage       = String(format: "%.3f V", snapshot.voltageV)
        chargerStatus = status
        adapterLabel  = snapshot.adapterDescription ?? "Battery Only"
        lastUpdated   = .now
    }

    deinit {
        timerCancellable?.cancel()
    }
}
