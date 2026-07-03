# Sprint 1 Backlog — Sensory Wardrobe

> **Bruce Schulz** | CIS248 Advanced App Development | Summer 2026

---

## Product Backlog → Sprint 1 Selection

The following user stories were selected from the full product backlog for Sprint 1. This sprint focuses on establishing the core user experience: authentication, wardrobe management, outfit logging with comfort ratings, and weather-informed suggestions.

---

## Sprint 1 User Stories

| Story ID | User Story | Priority | Story Points | Status |
|----------|-----------|----------|:---:|--------|
| US-01 | As a sensory-sensitive user, I want to create an account and log in so that my wardrobe and comfort data are tied to my personal profile. | High | 5 | Complete |
| US-02 | As a caregiver, I want to create dependent profiles linked to my account so that I can manage wardrobe and outfits for the person I support. | High | 5 | Complete (Backend) |
| US-03 | As a user, I want to add clothing items to my wardrobe with sensory tags (texture, pressure, warmth level) and photos so that the app knows what I own and how each item feels. | High | 8 | In Progress |
| US-04 | As a user, I want to view my wardrobe catalog and filter by category, fabric, or sensory tag so that I can quickly find relevant clothing items. | High | 5 | In Progress |
| US-05 | As a user, I want the app to fetch real-time weather data for my location so that outfit suggestions are appropriate for today's conditions. | High | 5 | Complete |
| US-06 | As a user, I want to log my daily outfit by selecting items from my wardrobe so that the app can track what I wear. | High | 8 | In Progress |
| US-07 | As a user, I want to rate my post-wear comfort (overall 1–5, plus optional texture/pressure/temperature sub-scores) so that the app learns which items are most comfortable for me. | High | 5 | In Progress |
| US-08 | As a user, I want to receive smart outfit suggestions ranked by weather match and my historical comfort scores so that I can dress comfortably every day. | High | 8 | In Progress |
| US-09 | As a user, I want to view my outfit history and comfort trend charts over time so that I can identify patterns and improve my clothing choices. | Medium | 5 | In Progress |
| US-10 | As a user, I want to receive push notification reminders in the morning (log outfit) and evening (rate comfort) so that I stay consistent with tracking. | Medium | 5 | In Progress |
| US-11 | As a user, I want my data encrypted and backed up to the cloud so that I don't lose my history if I change devices. | Medium | 5 | Complete |
| US-12 | As a new user, I want a guided onboarding flow that collects my sensory preferences and helps me add my first clothing item so that the app is useful from day one. | Medium | 5 | Not Started |
| US-13 | As a user, I want the app to protect my data with authentication guards so that unauthenticated users cannot access private screens. | High | 3 | Not Started |
| US-14 | As a caregiver, I want to switch between dependent profiles within the app so that I can manage multiple people's wardrobes without logging out. | Medium | 5 | Not Started |
| US-15 | As an admin, I want to manage user accounts (enable/disable) and system configuration so that I can maintain the platform. | Low | 8 | Not Started |

---

## Sprint 1 Summary

| Metric | Value |
|--------|-------|
| **Total Stories** | 15 |
| **Total Story Points** | 87 |
| **Sprint Duration** | 3 weeks |
| **Completed** | US-01, US-02 (backend), US-05, US-11 |
| **In Progress** | US-03, US-04, US-06, US-07, US-08, US-09, US-10 |
| **Not Started** | US-12, US-13, US-14, US-15 |

---

## Acceptance Criteria (Key Stories)

### US-03: Add Clothing Items with Sensory Tags
- User can enter item name, select category, fabric, and warmth level (1–5)
- User can select multiple sensory tags from predefined list
- User can take or select a photo from gallery
- Form validates that name and category are provided
- Item is saved to local SQLite database

### US-06: Log Daily Outfit
- User can select one or more wardrobe items to form an outfit
- Current weather snapshot is automatically attached to the log
- User can add optional notes
- At least one item must be selected to save

### US-07: Rate Post-Wear Comfort
- User sees a 1–5 star/slider for overall comfort (required)
- Optional sub-scores for texture, pressure, and temperature comfort
- Rating is linked to the specific outfit log entry
- Success feedback shown after saving

### US-08: Smart Outfit Suggestions
- Suggestions ranked by weather-warmth match and historical comfort
- Graceful fallback when weather is unavailable (comfort-only sorting)
- Prompt shown if wardrobe has fewer than 3 items
- User can tap to see item details

---

## Sprint 1 Goals
1. Complete the wardrobe catalog UI (list + add/edit screens with photo support)
2. Wire outfit logging and comfort rating save paths end-to-end
3. Connect suggestion engine output to the Suggestions screen and Dashboard card
4. Integrate history list and comfort trend chart display
5. Initialize notification scheduling with configurable reminder times

---

*Sprint 1 runs from Week 1 through the Deliverable 2 due date.*
