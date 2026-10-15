# TEKKERSUP

Soccer training tracker. The player props up a phone, the app tracks their body with pose detection, measures technique for each drill, and gives coaching pointers.

## Run

```bash
npm install
npm run dev     # open the printed URL on a laptop or phone (camera needs HTTPS or localhost)
npm run build   # type-check and production build
```

## How it works

- `src/lib/pose.ts` loads MediaPipe PoseLandmarker in the browser (runs fully on-device).
- `src/lib/analyzer.ts` turns landmarks into metrics (kicking knee angle, plant knee angle, torso lean, arm spread), detects strike cycles (cock, then extend), scores each rep, and builds the session report with pointers.
- `src/lib/drills.ts` holds the drill definitions and target ranges. Add a drill here and it shows up in Focus, Library and Reports.
- `src/lib/storage.ts` saves sessions and settings in localStorage for now.

## Notes

- Metrics are 2D estimates from a single phone camera. The side-on camera angle matters.
- Target ranges are first-pass coaching numbers and should be validated with a coach before they go to players.
- The iOS app should reuse the same drill and analyzer logic (port `src/lib` to Swift, or wrap it in a web view with Capacitor).
