# Burn-Down Chart — Sprint 1

> **Bruce Schulz** | CIS248 Advanced App Development | Summer 2026

---

## Sprint Overview

| Parameter | Value |
|-----------|-------|
| Sprint Duration | 3 weeks (15 working days) |
| Total Story Points | 87 |
| Team Size | 4 (Bruce, Nova, Zach, Jeremy) |
| Velocity Target | ~29 points/week |

---

## Daily Burn-Down Data

| Day | Date | Ideal Remaining | Actual Remaining | Notes |
|:---:|------|:---:|:---:|------|
| 0 | Sprint Start | 87 | 87 | Sprint begins |
| 1 | Day 1 | 81.2 | 85 | Environment setup, Firebase config |
| 2 | Day 2 | 75.4 | 80 | Auth backend work begins |
| 3 | Day 3 | 69.6 | 72 | US-01 (Auth) complete |
| 4 | Day 4 | 63.8 | 67 | Weather API integration starts |
| 5 | Day 5 | 58.0 | 60 | US-05 (Weather) complete, US-02 backend done |
| 6 | Day 6 | 52.2 | 55 | Wardrobe list UI started |
| 7 | Day 7 | 46.4 | 50 | US-11 (Backup) complete |
| 8 | Day 8 | 40.6 | 45 | Outfit logging screen work |
| 9 | Day 9 | 34.8 | 40 | Comfort rating UI built |
| 10 | Day 10 | 29.0 | 35 | Suggestion engine + screen wiring |
| 11 | Day 11 | 23.2 | 30 | History tab structure built |
| 12 | Day 12 | 17.4 | 26 | Notification plugin initialized |
| 13 | Day 13 | 11.6 | 22 | Continued wiring, testing |
| 14 | Day 14 | 5.8 | 18 | Bug fixes, polish |
| 15 | Day 15 (End) | 0 | 14 | Sprint 1 ends |

---

## Burn-Down Chart (ASCII Visualization)

```
Story Points Remaining
 87 |*
 80 |  *  .
 70 |     * .
 60 |        *.
 50 |          * .
 40 |             *.
 35 |               *
 30 |              . *
 26 |            .    *
 22 |          .       *
 18 |        .          *
 14 |      .             * ← Actual (Sprint End)
  0 |____.___________________ ← Ideal (Sprint End)
    |---|---|---|---|---|---|
    D0  D3  D5  D8  D10 D13 D15
    
    Legend:  * = Actual    . = Ideal
```

---

## Velocity Analysis

| Metric | Value |
|--------|-------|
| Planned Points | 87 |
| Completed Points | 73 |
| Remaining Points | 14 |
| Completion Rate | 84% |
| Actual Velocity | ~24.3 pts/week |

---

## Observations

1. **Strong start**: Core infrastructure (auth, weather, backup) completed on schedule in Week 1.
2. **Mid-sprint slowdown**: UI wiring proved more complex than estimated. Connecting existing services to presentation layers required additional state management work.
3. **Carry-over items**: Stories US-12 (Onboarding), US-13 (Auth Guard), US-14 (Profile Switching), and US-15 (Admin) carry forward to Sprint 2.
4. **Risk factor**: Stories in "In Progress" (US-03, US-04, US-06–US-10) represent partial completion — backend/logic done, UI wiring remaining.

---

## How to Create This in Excel/Trello

### Excel Method
1. Create columns: Day, Ideal Remaining, Actual Remaining
2. Ideal line: start at 87, subtract 5.8 per day (87 ÷ 15 days)
3. Actual line: update daily with actual remaining points
4. Insert a Line Chart with both series plotted

### Trello/Jira Method
1. Create a board with columns: To Do, In Progress, Done
2. Add each User Story as a card with story points label
3. Move cards across columns as work progresses
4. Use a Power-Up (e.g., "Burndown for Trello") to auto-generate the chart

---

*Data reflects Sprint 1 progress as of sprint end.*
