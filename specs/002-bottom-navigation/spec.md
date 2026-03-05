# Feature Specification: Bottom Navigation

## Metadata

- **Feature ID:** FEAT-002
- **Created:** 2025-03-04
- **Last Updated:** 2025-03-04
- **Status:** Draft

## Overview

### Purpose

Introduce a bottom tab bar navigation so the main app experience is organized into five areas: Today (dashboard), Plan (workout planning), Workout (start workouts), Activities (workout history), and Profile. This replaces the current pattern where the dashboard is the single post-login root and profile is reached via a toolbar link.

### Scope

**In Scope (this feature):**
- Bottom tab bar with five tabs: Today, Plan, Workout, Activities, Profile
- Today tab shows the existing dashboard (current DashboardView)
- Profile tab shows the existing ProfileView (moved from toolbar navigation)
- Plan tab: new shell/container with placeholder or minimal “plan workouts” experience
- Workout tab: placeholder for future “start workouts” experience
- Activities tab: placeholder for future “house workouts” / history experience
- Removing profile access from dashboard toolbar (profile only via Profile tab)
- Tab state and selection persistence during session
- Consistent navigation behavior (e.g., each tab can have its own NavigationStack)

**Out of Scope (explicitly deferred):**
- Full Plan experience (workout planning flows, data models, persistence)
- Full Workout experience (starting/recording workouts)
- Full Activities experience (workout history, list/detail)

### Assumptions

- Existing `DashboardView`, `ProfileView`, `ProfileViewModel`, and `AuthenticationViewModel` remain the source of truth for Today and Profile content; only their placement in the hierarchy changes.
- Bottom navigation is the primary navigation for authenticated users after onboarding; deep links or notifications may later target specific tabs.
- Design follows iOS Human Interface Guidelines for tab bars (e.g., 3–5 tabs, system icons or SF Symbols, optional badges in future).

---

## Definitions and Conventions

| Term | Definition |
|------|------------|
| **Tab bar** | System `TabView` or equivalent bottom tab bar with one selected tab. |
| **Today** | Tab whose root is the current dashboard (steps, calories, charts, AI insights). |
| **Plan** | Tab for planning workouts; initially a shell/placeholder. |
| **Workout** | Tab for starting/doing workouts; initially a placeholder. |
| **Activities** | Tab for viewing past workouts / activity list; initially a placeholder. |
| **Profile** | Tab for account, settings, edit profile, sign out; existing ProfileView. |
| **Shell** | Minimal container view for a tab with a title and optional empty state or CTA. |

---

## User Stories

### US1: Navigate the app by tab

**As a** logged-in user  
**I want to** switch between Today, Plan, Workout, Activities, and Profile using a bottom tab bar  
**So that** I can quickly reach each area without going through the dashboard first.

**Acceptance criteria:**
- A bottom tab bar is visible on the main screen after login (when onboarding is complete).
- Tabs are labeled: Today, Plan, Workout, Activities, Profile (or agreed labels).
- Tapping a tab switches the main content to that tab’s root view.
- The selected tab is clearly indicated (e.g., selected state).
- Tab bar is visible on all five tab roots (no full-screen flows that hide it unless explicitly designed).

---

### US2: Today shows my dashboard

**As a** logged-in user  
**I want to** open the Today tab and see my existing dashboard  
**So that** my daily activity and insights are in a dedicated place.

**Acceptance criteria:**
- Today tab shows the same content as the current dashboard (steps, calories, active minutes, weekly chart, AI insights, pull-to-refresh).
- Dashboard header and content remain; the profile icon in the dashboard toolbar is removed (profile is only in the Profile tab).
- No regression in dashboard behavior or data loading.

---

### US3: Profile is in its own tab

**As a** logged-in user  
**I want to** open the Profile tab to see and edit my profile and sign out  
**So that** I don’t have to open the dashboard first to reach profile.

**Acceptance criteria:**
- Profile tab shows the existing ProfileView (header, personal info, app settings, about, sign out).
- Edit Profile and sign-out flows work as they do today.
- Profile is reachable only via the Profile tab (no profile entry point in dashboard toolbar).

---

### US4: Plan tab is available for future planning

**As a** logged-in user  
**I want to** open a Plan tab  
**So that** I have a clear place where workout planning will live.

**Acceptance criteria:**
- Plan tab exists and is tappable.
- Plan tab shows a dedicated screen (shell) that indicates “Plan” / “Workout planning” and can show a short message or empty state (e.g., “Plan your workouts — coming soon” or minimal CTA).
- No full planning flows required in this feature.

---

### US5: Workout tab is available for future workouts

**As a** logged-in user  
**I want to** open a Workout tab  
**So that** I have a clear place where I can start workouts later.

**Acceptance criteria:**
- Workout tab exists and is tappable.
- Workout tab shows a shell/placeholder (e.g., “Start a workout — coming soon” or minimal CTA).
- No workout execution flows required in this feature.

---

### US6: Activities tab is available for future history

**As a** logged-in user  
**I want to** open an Activities tab  
**So that** I have a clear place where my workout history will live.

**Acceptance criteria:**
- Activities tab exists and is tappable.
- Activities tab shows a shell/placeholder (e.g., “Your activities — coming soon” or empty state).
- No activity list or detail flows required in this feature.

---

## Functional Requirements

### FR-NAV-1: Tab bar container

- The app shows a bottom tab bar with exactly five tabs: Today, Plan, Workout, Activities, Profile.
- Each tab has a label and an icon (SF Symbols recommended).
- Only one tab is selected at a time; selection updates the main content area.
- Tab bar is part of the root authenticated layout (after onboarding); it is not shown during auth or onboarding.

### FR-NAV-2: Today tab content

- Today tab’s root view is the existing dashboard (DashboardView or equivalent).
- Dashboard receives the same dependencies it has today (e.g., AuthenticationViewModel) so behavior is unchanged.
- The dashboard’s navigation bar must not show a profile (person) toolbar button; profile is only in the Profile tab.

### FR-NAV-3: Profile tab content

- Profile tab’s root view is the existing ProfileView (or ProfilePlaceholderView that wraps it with auth context if needed).
- Sign out from Profile returns the user to the authentication screen and the tab bar is no longer shown.
- Edit Profile and all existing profile actions remain available from the Profile tab.

### FR-NAV-4: Plan, Workout, and Activities tabs (shells)

- Plan tab shows a dedicated Plan shell view (title + optional short description or empty state).
- Workout tab shows a dedicated Workout shell view (title + optional short description or empty state).
- Activities tab shows a dedicated Activities shell view (title + optional short description or empty state).
- Shells are minimal and do not require new data models or backend; they are placeholders for future work.

### FR-NAV-5: Navigation and back stack

- Each tab can use its own NavigationStack (or equivalent) so that in-tab navigation (e.g., Edit Profile, Notifications) does not affect other tabs.
- When the user switches tabs, the previously selected tab’s navigation state is preserved (e.g., if user drills into Plan and then switches to Profile, returning to Plan shows the same screen).

### FR-NAV-6: Entry point from ContentView

- After authentication and onboarding completion, ContentView presents the tab bar container (with Today, Plan, Workout, Activities, Profile), not the dashboard alone.
- Auth and onboarding flows are unchanged; only the post-onboarding root changes from a single dashboard to the tab container.

---

## Non-Functional Requirements

### NFR-NAV-1: Consistency with existing app

- Reuse existing views (DashboardView, ProfileView) and view models; no unnecessary refactors.
- Styling (colors, fonts, dark mode) of the tab bar should align with the rest of the app (e.g., Color.primaryBackground, .accentColor).

### NFR-NAV-2: Accessibility

- Tab bar items have accessibility labels so VoiceOver users can identify each tab.
- Tab selection is announced to screen reader users.

### NFR-NAV-3: Performance

- Switching tabs is immediate; tab content may load on first appearance (e.g., dashboard data) but tab switch itself has no perceptible delay.

---

## Out of Scope / Future

- Badges on tabs (e.g., notification count).
- Custom tab bar styling beyond standard iOS look.
- Full Plan, Workout, or Activities feature sets (separate specs).
- Deep linking to a specific tab (can be added later).

---

## Success Criteria

1. User can open the app (post-onboarding) and see the bottom tab bar with five tabs.
2. User can tap each tab and see the correct content (Today = dashboard, Profile = profile, Plan/Workout/Activities = shells).
3. Dashboard no longer has a profile toolbar button; profile is only in the Profile tab.
4. Sign out from Profile returns to auth screen and tab bar is hidden.
5. No regressions in dashboard or profile behavior.
6. Tab bar is accessible (labels) and respects app theme (light/dark).

---

## Dependencies

- Existing: ContentView, DashboardView, ProfileView, ProfileViewModel, AuthenticationViewModel, onboarding flow.
- New: Tab container view, three shell views (Plan, Workout, Activities), and wiring in ContentView to show the tab container after onboarding.

---

## Open Points / Clarifications

1. **Exact tab labels:** Confirm “Today”, “Plan”, “Workout”, “Activities”, “Profile” (or e.g. “Plans”, “Activity”).
2. **Icons:** Choose SF Symbols for each tab (e.g. `house`, `calendar`, `figure.run`, `list.bullet`, `person.fill`).
3. **Default tab:** Typically Today when opening the app; confirm.
4. **Plan/Workout/Activities copy:** Agree on short placeholder text for each shell (e.g. “Plan your workouts”, “Start a workout”, “Your activities”).
