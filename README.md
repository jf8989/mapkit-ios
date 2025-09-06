# MapKit + Combine Tracker

A tiny SwiftUI app that tracks the user’s location, drops pins, and reverse-geocodes places — all with **Combine** (no async/await). It uses a **TabView** with a Map tab and a Places list tab, stores data **in memory only**, and never blocks the main thread.

---

## Features

- **Live tracking** with `CLLocationManager` (Combine-wrapped)
- **First-fix pin** + **distance** updated in lockstep
- **Cadence rule:** reverse-geocode every **5s**, but only after moving **≥20 m**
- **Overlay card** on pin tap (dismiss via outside tap or OK), with smooth enter/exit animation
- **Places list** of visited locations (sorted newest first)
- **Errors surfaced** to the user (geocoder failures; optional location-manager error alerts)
- **Accuracy stored** (`horizontalAccuracy` in meters); optionally shown in the overlay
- **Combine-only** async; **no async/await**
- **In-memory data**; no persistence

---

## Requirements

- **Xcode:** 15+  
- **iOS target:** 16.0+ (iOS 17 path used when available)  
- **Frameworks:** SwiftUI, Combine, MapKit, CoreLocation

**Info.plist** must include:
- `NSLocationWhenInUseUsageDescription` — a user-friendly reason for location access.

---

## Run it (Simulator or Device)

1. **Build & Run** from Xcode. On first launch, allow location access.
2. **Simulate movement (Simulator):** `Features > Location > City Bicycle Ride` or `Freeway Drive`.  
   (Simulator accuracy can be generic or nil — that’s normal.)
3. **Real device:** walk around; expect a pin within ≤5s after moving ≥20 m.

---
## How it works

### Architecture at a glance (MVVM + Services)
- **ViewModel:** `MapTabViewModel` orchestrates permission flow, location stream, geocoding cadence, and UI state.
- **Services (protocol-backed):**
  - `LocationServiceType` → `LocationService` (delegate → Combine)
  - `GeocodingServiceType` → `GeocodingService` (CLGeocoder wrapped in `Future`)
  - `PermissionManagerType` routes authorization state/requests
- **Environment:** `AppEnvironment` wires live services; injected into views/VMs.

### Streams & rules

- **First fix:** On the first authorized location, immediately reverse-geocode and **commit pin + distance** together.
- **Movement gate:** Every new `CLLocation` computes distance from the last checkpoint; if **≥20 m**, we mark a checkpoint and emit a movement signal.
- **Cadence:** A `Timer` (5s) samples the most recent movement location since the last geocode and runs reverse-geocoding off the main thread.
- **Commit:** On success, we append a `VisitedPlace`, update total distance, and update the “last geocoded checkpoint” — all together.
- **Errors:** Geocoder errors are caught in-pipeline and surfaced as an alert without killing the streams. (Optional) Location-manager errors are exposed via a separate `errors` publisher and alerted, ignoring transient `.locationUnknown`.

### UI

- **Map tab:** User location + pins; tapping a pin shows a polished overlay card.
- **Places tab:** Simple list of `VisitedPlace` items (newest first).
- **Overlay:** Ultra-thin material card with light motion (fade/scale/offset) and scrim fade; dismiss by tapping outside or OK.

---

---

## Key design choices

- **No async/await:** All async is done with **Combine**; service APIs expose publishers.
- **In-memory only:** Per requirements; app restarts with an empty list.
- **Backpressure & UX:** The **20 m gate** avoids noisy geocodes; **5s cadence** smooths requests and battery use.
- **Single source of truth:** Pin-drop and distance update happen from the **same commit point** for a consistent UI.

---

## Error handling (Combine)

- Pipelines use `.catch` to recover with **non-failing** publishers, so a single failure doesn’t terminate the stream.
- Optional: `LocationServiceType.errors` publishes manager errors as **values**, not failures, so subscriptions stay alive.

---

## Accuracy

- We store `VisitedPlace.horizontalAccuracy` (meters). A negative from `CLLocation` is treated as **nil**.
- The overlay shows `±N m` only when a value exists. Simulator routes may not provide meaningful accuracy; real devices will.

---

## Privacy

- Location data is used **on-device only** for live UI and a local in-memory list; nothing is persisted or sent anywhere.

---

## Manual test checklist

- **Permission allowed:** First fix drops a pin and updates distance.
- **Move ≥20 m:** Within ≤5s, another pin appears; distance updates in the same frame.
- **Permission denied:** Alert explains how to enable in Settings; no tracking starts.
- **Geocoder failure:** Trigger network off on device → shows error alert; app continues tracking.
- **Overlay:** Tap pin → smooth appear; tap outside/OK → smooth dismiss.

---

## Extending (later, if desired)

- Persist `VisitedPlace` (Core Data or SQLite)  
- Filtering by accuracy threshold (e.g., hide >100 m)  
- Background updates / significant-change location service  
- Share/export visited places

---

## License

MIT
