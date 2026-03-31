// TelemetryApp.swift
// Telemetry — App Entry Point

import SwiftUI

@main
struct TelemetryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)  // Window fits the grid, no manual resize
        .defaultSize(width: 460, height: 520)
    }
}
```

---

## After all 6 files are committed

Your GitHub repo should look like this:
```
Telemetry/
├── App/
│   └── TelemetryApp.swift
├── Engines/
│   └── InternalPowerEngine.swift
├── Models/
│   └── BatterySnapshot.swift
├── ViewModels/
│   └── DashboardViewModel.swift
└── Views/
    ├── Components/
    │   └── MetricTileView.swift
    └── Dashboard/
        └── ContentView.swift
