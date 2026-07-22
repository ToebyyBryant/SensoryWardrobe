# Sprint 2 Backlog — Sensory Wardrobe

> **Team:** Bruce Schulz, Zach Kahler,
> Nova Denton-Parry, Jeremy Kirkpatrick  
> **Course:** CIS248 Advanced App Development  
> Summer 2026 — **Deliverable 3**

---

## Product Backlog to Sprint 2 Selection

Sprint 2 carries forward incomplete items from Sprint 1 and
introduces new stories to advance the application toward a
complete end-to-end user experience. This sprint focuses on
finishing UI wiring for core features (wardrobe, outfit log,
ratings, suggestions), completing notification scheduling, and
beginning work on authentication guards and onboarding.

This is a work-in-progress project. The statuses below reflect
actual progress as of the Sprint 2 end date.

---

## Sprint 2 User Stories

| ID | User Story | Pts | Owner | Status |
|----|-----------|:---:|-------|--------|
| US-03 | Add clothing items with sensory tags and photos | 3 | Nova | Done |
| US-04 | View/filter wardrobe by category, fabric, or tag | 2 | Nova | Done |
| US-06 | Log daily outfit by selecting wardrobe items | 3 | Jeremy | Done |
| US-07 | Rate post-wear comfort (1-5 + sub-scores) | 2 | Jeremy | Done |
| US-08 | Smart suggestions ranked by weather + comfort | 3 | Bruce | In Progress |
| US-09 | Outfit history view and comfort trend charts | 3 | Zach | In Progress |
| US-10 | Push notification reminders (morning/evening) | 3 | Zach | In Progress |
| US-12 | Guided onboarding flow for new users | 5 | Bruce | Not Started |
| US-13 | Authentication guards on private routes | 3 | Bruce | In Progress |
| US-14 | Multi-profile switching for caregivers | 5 | Nova | Not Started |
| US-15 | Admin user management and system config | 8 | — | Not Started |
| US-16 | Clothing photo thumbnails with async loading | 3 | Jeremy | In Progress |
| US-17 | Edit or deactivate existing wardrobe items | 3 | Nova | Done |

---

## Sprint 2 Summary

| Metric | Value |
|--------|-------|
| Total Stories | 13 |
| Total Story Points | 46 |
| Sprint Duration | 3 weeks |
| Carry-over | US-03 thru US-10, US-12 thru US-15 |
| New Stories | US-16, US-17 |
| Completed | US-03, US-04, US-06, US-07, US-17 |
| In Progress | US-08, US-09, US-10, US-13, US-16 |
| Not Started | US-12, US-14, US-15 |

---

## Acceptance Criteria

### US-08: Smart Outfit Suggestions

- Suggestions screen displays ranked items based on
  weather-warmth match and comfort history
- Graceful fallback when weather unavailable
- Prompt shown if wardrobe has fewer than 3 items
- Current state: Engine logic complete, screen wiring
  in progress

### US-09: History and Trends

- View past outfit logs filtered by date and category
- Comfort trend chart displays scores over time
- Current state: Tab structure exists, data wiring to
  chart library in progress

### US-10: Push Notifications

- Morning reminder to log outfit
- Evening reminder to rate comfort
- Configurable times via settings
- Timezone-aware scheduling
- Current state: Plugin initialized, scheduling in progress

### US-12: Guided Onboarding Flow

- First-time users see onboarding after registration
- Set sensory preferences (texture, warmth)
- Prompted to add first wardrobe item
- Can be skipped with neutral defaults
- Current state: Not started, planned for Sprint 3

### US-13: Authentication Guards

- All routes except login/register require auth
- Unauthenticated access redirects to login
- GoRouter redirect integrated with auth provider
- Current state: Router structure in place, redirect
  logic partially wired

### US-16: Clothing Photo Thumbnails

- Thumbnails on wardrobe list, outfit log, suggestions
- Async loading with placeholder during load
- Fallback category icon when no photo exists
- Current state: Image picker integrated, display
  widget in progress

### US-17: Edit/Deactivate Wardrobe Items

- Tap item to open edit screen with pre-filled fields
- Update name, category, tags, warmth level, photo
- Deactivate item (soft delete, is_active = false)
- Current state: Complete

---

## Sprint 2 Goals

1. Complete wardrobe catalog UI — Done
2. Wire outfit logging and comfort rating — Done
3. Connect suggestion engine to screen — In Progress
4. Integrate history and trend charts — In Progress
5. Complete notification scheduling — In Progress
6. Implement authentication guard routing — In Progress
7. Begin onboarding and profile switching — Deferred

---

## Items Deferred to Sprint 3

- US-12: Onboarding flow
- US-14: Multi-profile switching UI
- US-15: Admin system management
- Remaining work on US-08, US-09, US-10, US-13, US-16

---

*Sprint 2 runs from Deliverable 2 through Deliverable 3.
Work is ongoing.*
