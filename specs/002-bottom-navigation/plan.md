# Plan: Bottom Navigation

## Summary

Add a five-tab bottom navigation (Today, Plan, Workout, Activities, Profile). Today = existing dashboard; Profile = existing profile (moved from dashboard toolbar); Plan, Workout, and Activities = placeholder shells for future features.

## Approach

1. **New root after onboarding:** Replace the single-dashboard root in `ContentView` with a tab container view that hosts five tabs.
2. **Reuse existing screens:** Today tab → current `DashboardView`; Profile tab → current `ProfileView`. No changes to their internal logic beyond removing the profile button from the dashboard toolbar.
3. **Shells for future tabs:** Add minimal `PlanTabView`, `WorkoutTabView`, and `ActivitiesTabView` with title + placeholder copy. No backend or full flows in this feature.
4. **Per-tab navigation:** Each tab keeps its own navigation stack so drill-down (e.g. Edit Profile) does not affect other tabs.

## Key files to touch

- **New:** Tab container view (e.g. `MainTabView`), `PlanTabView`, `WorkoutTabView`, `ActivitiesTabView`.
- **Modify:** `ContentView` (post-onboarding branch → show tab container), `DashboardView` (remove profile toolbar item).

## Docs

- **Requirements and user stories:** [spec.md](./spec.md)
- **Implementation tasks:** [tasks.md](./tasks.md)

## Open decisions (see spec)

- Exact tab labels and SF Symbols for each tab.
- Default selected tab (assumed: Today).
- Placeholder copy for Plan, Workout, Activities shells.
