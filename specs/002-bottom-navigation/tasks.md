# Task Breakdown: Bottom Navigation

## Overview

**Feature:** Bottom tab bar with Today, Plan, Workout, Activities, Profile  
**Specification:** [spec.md](./spec.md)  
**Scope:** Tab bar shell, move dashboard and profile into tabs, add placeholder tabs for Plan/Workout/Activities

## Task Organization

Tasks are grouped by phase. Dependencies: Phase 1 (container) before Phase 2 (content wiring); Phase 2 before Phase 3 (cleanup).

---

## Phase 1: Tab bar container and shell views

**Goal:** Introduce the tab bar as the post-onboarding root and add shell views for Plan, Workout, and Activities.

**Independent test:** App builds; after login/onboarding, user sees a bottom tab bar with five tabs; tapping each tab shows a distinct screen (even if placeholder).

### Container and structure

- [ ] **T001** Create a main tab container view (e.g. `MainTabView` or `RootTabView`) that hosts a SwiftUI `TabView` with five tabs.
- [ ] **T002** Define tab enum or constants for the five tabs: Today, Plan, Workout, Activities, Profile (for selection state and consistency).
- [ ] **T003** Add Today tab: set its root to the existing dashboard (e.g. `DashboardPlaceholderView` / `DashboardView`); pass required dependencies (e.g. `AuthenticationViewModel`).
- [ ] **T004** Add Profile tab: set its root to the existing profile (e.g. `ProfilePlaceholderView` / `ProfileView`); pass auth context if needed for sign-out.
- [ ] **T005** Create `PlanTabView` (shell): simple view with navigation title “Plan” and placeholder content (e.g. “Plan your workouts” + optional “Coming soon” or empty state).
- [ ] **T006** Create `WorkoutTabView` (shell): simple view with navigation title “Workout” and placeholder content (e.g. “Start a workout” + optional “Coming soon” or empty state).
- [ ] **T007** Create `ActivitiesTabView` (shell): simple view with navigation title “Activities” and placeholder content (e.g. “Your activities” + optional “Coming soon” or empty state).
- [ ] **T008** In the tab container, add Plan tab with `PlanTabView`, Workout tab with `WorkoutTabView`, Activities tab with `ActivitiesTabView`.
- [ ] **T009** Assign SF Symbol (or asset) and label to each tab: Today, Plan, Workout, Activities, Profile (icons TBD per spec open points).
- [ ] **T010** Set default selected tab to Today when the tab container appears.

**Acceptance:** Five tabs visible; Today shows dashboard, Profile shows profile; Plan, Workout, Activities show their shell views.

---

## Phase 2: ContentView and navigation wiring

**Goal:** Use the tab container as the post-onboarding root and preserve auth/onboarding flow.

**Independent test:** After sign-in and onboarding, user lands on tab bar with Today selected; sign out from Profile returns to auth.

### Wiring

- [ ] **T011** In `ContentView`, replace the branch that currently shows `DashboardPlaceholderView` (post-onboarding) with the new tab container view, passing `authViewModel` (or equivalent) so Today and Profile have auth context.
- [ ] **T012** Ensure the tab container is only shown when `authViewModel.isAuthenticated`, profile is loaded, and `user.onboardingCompleted` (same conditions as current dashboard).
- [ ] **T013** Ensure each tab that needs it has its own `NavigationStack` (or equivalent) so in-tab navigation (e.g. Edit Profile, Notifications) does not clear when switching tabs; Today and Profile already use navigation—verify Plan/Workout/Activities shells are wrapped where appropriate.
- [ ] **T014** Verify sign-out from Profile tab returns to `AuthenticationView` and tab bar is no longer visible.

**Acceptance:** Post-onboarding root is the tab bar; auth and onboarding flows unchanged; sign out works from Profile tab.

---

## Phase 3: Dashboard cleanup and profile access

**Goal:** Remove profile from dashboard toolbar; profile is only reachable via Profile tab.

**Independent test:** Dashboard has no profile icon in the toolbar; Profile tab is the only way to reach profile.

### Dashboard and profile

- [ ] **T015** Remove the profile (person.circle) `ToolbarItem` and `NavigationLink` to `ProfilePlaceholderView` from `DashboardView`’s toolbar.
- [ ] **T016** Optionally simplify `DashboardView` header if it had redundant profile entry; keep greeting and user info in header as-is unless product requests a change.
- [ ] **T017** Confirm `ProfilePlaceholderView` (or `ProfileView`) works when used as the root of the Profile tab (no missing dependencies, e.g. auth for sign-out).

**Acceptance:** Dashboard shows no profile button; profile is only in Profile tab; no regressions in dashboard or profile behavior.

---

## Phase 4: Polish and accessibility

**Goal:** Theming, accessibility, and any small UX tweaks.

**Independent test:** Tab bar matches app theme; VoiceOver can identify and select each tab.

### Polish

- [ ] **T018** Apply app semantic colors to the tab bar (e.g. `Color.primaryBackground`, selected/unselected states) so it respects light/dark mode.
- [ ] **T019** Add accessibility labels to each tab bar item (e.g. “Today”, “Plan”, “Workout”, “Activities”, “Profile”) for VoiceOver.
- [ ] **T020** Smoke test: launch app, sign in, complete or skip onboarding, switch through all five tabs, open Edit Profile from Profile, sign out; confirm no crashes and correct screens at each step.

**Acceptance:** Tab bar is themed and accessible; full flow works end-to-end.

---

## Summary

| Phase | Focus                         | Task count |
|-------|--------------------------------|------------|
| 1     | Tab container + shell views   | T001–T010  |
| 2     | ContentView + wiring          | T011–T014  |
| 3     | Dashboard toolbar + profile   | T015–T017  |
| 4     | Polish + accessibility        | T018–T020  |

**Total tasks:** 20

---

## Dependencies between phases

- **Phase 1** must be done first (tab container and shells exist).
- **Phase 2** depends on Phase 1 (ContentView shows the container).
- **Phase 3** can be done in parallel with Phase 2 or after (removing profile from dashboard).
- **Phase 4** should be last (polish and a11y).

---

## Optional / follow-up (not in scope for this feature)

- Deep link to a specific tab.
- Badge counts on tabs.
- Persisting last selected tab across app launches.
- Full implementations for Plan, Workout, or Activities (separate features).
