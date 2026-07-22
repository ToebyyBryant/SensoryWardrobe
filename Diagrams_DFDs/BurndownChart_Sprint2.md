# Burn-Down Chart — Sprint 2

> **Team:** Bruce Schulz, Zach Kahler,
> Nova Denton-Parry, Jeremy Kirkpatrick  
> **Course:** CIS248 Advanced App Development  
> Summer 2026 — **Deliverable 3**

---

## Sprint Overview

| Parameter | Value |
|-----------|-------|
| Duration | 3 weeks (15 days) |
| Total Points | 46 |
| Team Size | 4 |
| Target Velocity | ~15.3 pts/week |

---

## Daily Burn-Down Data

| Day | Ideal | Actual | Notes |
|:---:|:---:|:---:|------|
| 0 | 46 | 46 | Sprint 2 begins |
| 1 | 42.9 | 45 | Wardrobe add wiring (US-03) |
| 2 | 39.9 | 43 | US-03 complete (Nova) |
| 3 | 36.8 | 41 | US-04 filter UI done (Nova) |
| 4 | 33.7 | 38 | US-06 save path wired (Jeremy) |
| 5 | 30.7 | 35 | US-06, US-07 done (Jeremy) |
| 6 | 27.6 | 32 | US-17 edit/deactivate (Nova) |
| 7 | 24.5 | 29 | US-08 suggestions begins (Bruce) |
| 8 | 21.5 | 26 | US-09 history wiring (Zach) |
| 9 | 18.4 | 23 | US-10 notifications (Zach) |
| 10 | 15.3 | 21 | US-13 auth guard (Bruce) |
| 11 | 12.3 | 19 | US-16 image widget (Jeremy) |
| 12 | 9.2 | 17 | Continued wiring |
| 13 | 6.1 | 15 | Bug fixes, state mgmt |
| 14 | 3.1 | 14 | Integration testing |
| 15 | 0 | 13 | Sprint ends — ongoing |

---

## Burn-Down Chart

```
Points Remaining
 46 |*
 43 | .*
 41 |  .*
 38 |   .*
 35 |    .*
 32 |     * .
 29 |      *  .
 26 |       *   .
 23 |        *    .
 21 |         *     .
 19 |          *      .
 17 |           *       .
 15 |            *        .
 14 |             *
 13 |              * Actual
  0 |________________. Ideal
    |---|---|---|---|---|
    D0  D3  D6  D9 D12 D15

  * = Actual    . = Ideal
```

---

## Velocity Analysis

| Metric | Value |
|--------|-------|
| Planned | 46 pts |
| Completed | 33 pts |
| Remaining | 13 pts |
| Completion | 72% |
| Velocity | ~11 pts/week |
| Sprint 1 Velocity | ~24.3 pts/week |
| Combined Avg | ~17.7 pts/week |

---

## Completed vs. Remaining

| Status | Stories | Pts |
|--------|---------|:---:|
| Done | US-03, US-04, US-06, US-07, US-17 | 13 |
| In Progress | US-08, US-09, US-10, US-13, US-16 | 15 |
| Not Started | US-12, US-14, US-15 | 18 |

---

## Observations

1. **Strong early progress:** Carry-over stories
   completed quickly in Week 1 since backend logic
   was already done — only UI wiring remained.

2. **Mid-sprint plateau:** Complex UI integration
   (suggestions, history charts, notifications) proved
   harder than estimated. Riverpod provider coordination
   slowed progress.

3. **Divergence from ideal:** Actual line diverged
   around Day 7 as the team moved from simple wiring
   to interconnected feature work.

4. **Carry-over to Sprint 3:** US-08, US-09, US-10,
   US-13, US-16 need finishing. US-12, US-14, US-15
   not started.

5. **Root cause:** Underestimated complexity of
   connecting state providers across features and
   time needed for integration testing.

---

*Sprint 2 progress as of sprint end. Work continues.*
