// BatterySnapshot.swift
// Telemetry — Models Layer
//
// Pure Swift value types. No IOKit imports here.
// These are the structs the ViewModel and Views consume.

import Foundation

// MARK: - BatterySnapshot

public struct BatterySnapshot {
    let currentCapacityMAh: Int
    let maxCapacityMAh:     Int
    let designCapacityMAh:  Int
    let cycleCount:         Int
    let temperature:        Double   // °C
    let instantAmperageMa:  Int      // mA, negative = discharging
    let voltageV:           Double   // Volts
    let adapterWatts:       Int?     // nil = no charger
    let adapterDescription: String?

    // MARK: Computed

    /// Positive = charging watts flowing in.
    /// Negative = watts the system is consuming from battery.
    public var instantWattage: Double {
        (Double(instantAmperageMa) * voltageV) / 1000.0
    }

    /// 0–100%. Degrades as battery ages.
    public var batteryHealth: Double {
        guard designCapacityMAh > 0 else { return 0 }
        return (Double(maxCapacityMAh) / Double(designCapacityMAh)) * 100.0
    }

    /// Simple charge percentage for the current cycle.
    public var chargePercent: Double {
        guard maxCapacityMAh > 0 else { return 0 }
        return (Double(currentCapacityMAh) / Double(maxCapacityMAh)) * 100.0
    }

    public var isCharging:  Bool { instantAmperageMa > 0 }
    public var isOnBattery: Bool { adapterWatts == nil }
}

// MARK: - ChargerStatus

public enum ChargerStatus: Equatable {
    case notConnected
    case charging(surplusWatts: Double)
    case balanced
    case underpowered(deficitWatts: Double)

    /// Human-readable label for the UI.
    public var label: String {
        switch self {
        case .notConnected:                    return "On Battery"
        case .charging(let s):                 return "Charging (+\(String(format: "%.1f", s))W surplus)"
        case .balanced:                        return "Maintaining"
        case .underpowered(let d):             return "⚠️ Underpowered (−\(String(format: "%.1f", d))W)"
        }
    }

    /// SwiftUI color name to use in the view layer.
    public var colorName: String {
        switch self {
        case .notConnected:   return "blue"
        case .charging:       return "green"
        case .balanced:       return "yellow"
        case .underpowered:   return "red"
        }
    }
}
