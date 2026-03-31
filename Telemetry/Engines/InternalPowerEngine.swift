// InternalPowerEngine.swift
// Telemetry — Engines Layer
//
// Responsibility: Raw IOKit/IOPMLib hardware data harvesting.
// No formatting, no UI logic — pure data extraction only.
//
// ⚠️  Requires app-sandbox = false in entitlements.
//     Will silently return nil in a sandboxed process.

import Foundation
import IOKit
import IOKit.ps
import IOKit.pwr_mgt

// MARK: - InternalPowerEngine

public final class InternalPowerEngine {

    // MARK: IORegistry Raw Dictionary

    /// Reads the AppleSmartBattery IOService node directly.
    /// Equivalent to: ioreg -n AppleSmartBattery -r
    public func rawBatteryDictionary() -> [String: Any]? {
        let service = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("AppleSmartBattery")
        )
        guard service != IO_OBJECT_NULL else { return nil }
        defer { IOObjectRelease(service) }

        var props: Unmanaged<CFMutableDictionary>?
        let kr = IORegistryEntryCreateCFProperties(
            service, &props, kCFAllocatorDefault, 0
        )
        guard kr == KERN_SUCCESS else { return nil }
        return props?.takeRetainedValue() as? [String: Any]
    }

    // MARK: Adapter Dictionary

    /// Returns the connected charger metadata via IOPMLib.
    /// Returns nil when running on battery (no charger connected).
    public func rawAdapterDictionary() -> [String: Any]? {
        guard let unmanaged = IOPMCopyExternalPowerAdapterDetails() else {
            return nil
        }
        return unmanaged.takeRetainedValue() as? [String: Any]
    }

    // MARK: Synthesized Snapshot

    /// Primary call site. Merges battery + adapter into a BatterySnapshot.
    public func captureSnapshot() -> BatterySnapshot? {
        guard let b = rawBatteryDictionary() else { return nil }
        let a = rawAdapterDictionary()

        let rawVoltage = b["Voltage"] as? Int ?? 0
        let amperage: Int = {
            if let v = b["InstantAmperage"] as? Int { return v }
            if let v = b["Amperage"]        as? Int { return v }
            return 0
        }()

        return BatterySnapshot(
            currentCapacityMAh: b["CurrentCapacity"] as? Int ?? 0,
            maxCapacityMAh:     b["MaxCapacity"]     as? Int ?? 0,
            designCapacityMAh:  b["DesignCapacity"]  as? Int ?? 0,
            cycleCount:         b["CycleCount"]      as? Int ?? 0,
            temperature:        Double(b["Temperature"] as? Int ?? 0) / 100.0,
            instantAmperageMa:  amperage,
            voltageV:           Double(rawVoltage) / 1000.0,
            adapterWatts:       a?["Watts"]       as? Int,
            adapterDescription: a?["Description"] as? String
        )
    }

    // MARK: Charger Status

    public func evaluateChargerStatus(snapshot: BatterySnapshot) -> ChargerStatus {
        guard let adapterWatts = snapshot.adapterWatts, adapterWatts > 0 else {
            return .notConnected
        }
        let draw = snapshot.instantWattage
        if draw > 0 {
            let surplus = Double(adapterWatts) - draw
            return surplus > 0 ? .charging(surplusWatts: surplus) : .balanced
        }
        let deficit = abs(draw) - Double(adapterWatts)
        return deficit > 0 ? .underpowered(deficitWatts: deficit) : .balanced
    }
}
