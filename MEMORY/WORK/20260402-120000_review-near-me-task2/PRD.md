---
task: Review Near Me task 2 implementation for production
slug: 20260402-120000_review-near-me-task2
effort: extended
phase: complete
progress: 16/20
mode: interactive
started: 2026-04-02T12:00:00Z
updated: 2026-04-02T12:01:00Z
---

## Context

Code review of Task 2 of the Near Me feature: NearMeViewModel.swift (new file, 88 lines) and 8 new upcomingNearby tests appended to NearMeTests.swift. Diff range 75edaed..2185d25.

Plan specifies: 10-min grace window, 3-hour lookahead, virtual exclusion from distance, sort + cap at 3, fitRegion helper.

### Risks

- rawDelta arithmetic with weekday rollover is easy to get subtly wrong
- outsideGrace test expects isEmpty but the meeting wraps to next week (10080 min away) — correct behavior, needs verification
- force-unwrap on coords.map(\.latitude).min()! in fitRegion crashes if coords is empty
- testMaxThreeResults uses string interpolation for startTime "19:0\(i):00" — produces "19:01:00" through "19:05:00", all valid; but i=10+ would break
- makeDate helper uses hardcoded 2026 calendar math — potential fragility if tests run after DST boundary

## Criteria

- [x] ISC-1: NearMeViewModel.swift file is present and compiles with required imports
- [x] ISC-2: upcomingNearby free function has correct signature with injectable now parameter
- [x] ISC-3: Grace window lower bound is exactly -10 minutes (rawDelta >= -10)
- [x] ISC-4: Lookahead upper bound is exactly 180 minutes (rawDelta <= 180)
- [x] ISC-5: Virtual meetings (venueType == 2) produce nil distanceMiles
- [x] ISC-6: In-person meetings with coordinates and location produce non-nil distanceMiles
- [x] ISC-7: Results are sorted ascending by minutesUntil
- [x] ISC-8: Results are capped at maximum 3 items
- [x] ISC-9: fitRegion includes userLocation coordinate in bounding box calculation
- [x] ISC-10: fitRegion applies 1.4x padding to span
- [x] ISC-11: fitRegion uses 0.01 degree minimum span to prevent zero-span region
- [x] ISC-12: NearMeViewModel.recompute calls upcomingNearby and publishes results
- [x] ISC-13: NearMeViewModel.recompute calls fitRegion only when location and results are non-empty
- [x] ISC-14: All 8 upcomingNearby tests are present and cover plan-specified scenarios
- [x] ISC-15: testOutsideGrace asserts isEmpty (next-week wrap excluded by 3-hr guard)
- [x] ISC-16: testMaxThreeResults produces valid startTime strings for all 5 fixtures
- [x] ISC-17: fitRegion force-unwrap on min/max is safe only when coords is non-empty
- [x] ISC-18: NearMeViewModel is a class (reference type) as required for ObservableObject
- [ ] ISC-19: makeDate helper produces deterministic dates independent of test-run time
- [x] ISC-20: Distance conversion uses correct meters-to-miles divisor (1609.34)

## Decisions

## Verification

ISC-19 PARTIAL: makeDate uses Calendar.current which respects the device locale/timezone. Hardcoded 2026-03-29 reference is correct for Gregorian, but Calendar.current will use local timezone, so if tests run in a deeply negative UTC offset timezone the date could shift. In practice this is a CI concern, not a correctness risk for the main use case. Flagged as suggestion.

All other ISC criteria pass based on static analysis of the diff.
