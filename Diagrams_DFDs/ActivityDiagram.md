# Activity Diagram — Sensory Wardrobe

> **Bruce Schulz** | CIS248 Advanced App Development | Summer 2026

---

## Activity Diagram: Daily Outfit Logging & Comfort Rating Flow

### Narrative

This activity diagram illustrates the primary user workflow for the Sensory Wardrobe app: the daily process of logging an outfit and rating post-wear comfort. This flow is central to the app's value proposition — it captures the data that powers smart suggestions over time.

The user begins by opening the app (triggered by a morning push notification or voluntarily). The system checks authentication, then presents the outfit logging screen with the user's wardrobe items and current weather context. The user selects items worn, saves the log, and later returns (prompted by an evening notification) to rate their comfort. The rating feeds back into the suggestion engine for future recommendations.

### Diagram

```mermaid
flowchart TD
    %% Start
    START(( ● Start ))

    %% Authentication Check
    START --> AUTH{User authenticated?}
    AUTH -- No --> LOGIN[Display Login Screen]
    LOGIN --> CREDS[User enters credentials]
    CREDS --> VALIDATE{Credentials valid?}
    VALIDATE -- No --> ERROR[Show error message]
    ERROR --> CREDS
    VALIDATE -- Yes --> AUTH_OK[Set auth state]
    AUTH_OK --> DASH
    AUTH -- Yes --> DASH

    %% Dashboard
    DASH[Display Dashboard]
    DASH --> CHOOSE{User action?}

    %% Log Outfit Path
    CHOOSE -- "Log Outfit\n(morning)" --> FETCH_WX[Fetch current weather]
    FETCH_WX --> WX_OK{Weather available?}
    WX_OK -- Yes --> SHOW_WX[Display weather context banner]
    WX_OK -- No --> NO_WX[Show 'weather unavailable' notice]
    SHOW_WX --> LOAD_ITEMS[Load user's wardrobe items]
    NO_WX --> LOAD_ITEMS

    LOAD_ITEMS --> HAS_ITEMS{Wardrobe has items?}
    HAS_ITEMS -- No --> PROMPT_ADD[Prompt: 'Add items first']
    PROMPT_ADD --> END_EARLY(( ● End ))
    HAS_ITEMS -- Yes --> DISPLAY_LIST[Display item checklist]

    DISPLAY_LIST --> SELECT[User selects items worn]
    SELECT --> ENOUGH{At least 1 item selected?}
    ENOUGH -- No --> SELECT
    ENOUGH -- Yes --> ADD_NOTES[User adds optional notes]
    ADD_NOTES --> SAVE_LOG[Save outfit log to database]
    SAVE_LOG --> ATTACH_WX[Attach weather snapshot ID]
    ATTACH_WX --> LOG_SUCCESS[Show success confirmation]
    LOG_SUCCESS --> NOTIFY_EVE[Schedule evening rating reminder]
    NOTIFY_EVE --> BACK_DASH[Return to Dashboard]

    %% Rate Comfort Path (Later in day)
    CHOOSE -- "Rate Comfort\n(evening)" --> LOAD_LOG[Load today's outfit log]
    LOAD_LOG --> HAS_LOG{Outfit logged today?}
    HAS_LOG -- No --> NO_LOG[Show 'Log an outfit first' message]
    NO_LOG --> DASH
    HAS_LOG -- Yes --> SHOW_OUTFIT[Display outfit summary]

    SHOW_OUTFIT --> RATE_OVERALL[User rates overall comfort 1-5]
    RATE_OVERALL --> SUB_SCORES{Rate sub-scores?}
    SUB_SCORES -- Yes --> RATE_TEXTURE[Rate texture comfort]
    RATE_TEXTURE --> RATE_PRESSURE[Rate pressure/fit comfort]
    RATE_PRESSURE --> RATE_TEMP[Rate temperature comfort]
    RATE_TEMP --> SAVE_RATING
    SUB_SCORES -- No --> SAVE_RATING

    SAVE_RATING[Save comfort rating to database]
    SAVE_RATING --> UPDATE_ENGINE[Update suggestion engine data]
    UPDATE_ENGINE --> RATING_SUCCESS[Show success + encouragement]
    RATING_SUCCESS --> BACK_DASH

    BACK_DASH --> END(( ● End ))
```

---

## Swimlane Breakdown

| Lane | Actor | Responsibilities |
|------|-------|-----------------|
| User | Sensory-Sensitive User / Caregiver | Selects items, provides comfort scores, reads suggestions |
| App (Presentation) | Flutter UI Layer | Displays screens, validates input, shows feedback |
| App (Business Logic) | Providers & Services | Fetches weather, saves logs, calculates suggestions |
| External | OpenWeatherMap API / Push Service | Provides weather data, delivers notification reminders |

---

## Key Decision Points

| Decision | Yes Path | No Path |
|----------|----------|---------|
| User authenticated? | Proceed to Dashboard | Redirect to Login |
| Weather available? | Show weather banner with conditions | Show notice, proceed without weather |
| Wardrobe has items? | Show item checklist | Prompt user to add items first |
| At least 1 item selected? | Enable save button | Keep save disabled |
| Outfit logged today? | Show rating screen | Prompt to log outfit first |
| Rate sub-scores? | Show texture/pressure/temp sliders | Skip to save |

---

## Activity Diagram 2: Suggestion Generation Process

### Narrative

This diagram shows the internal process the app follows when generating outfit suggestions. It runs automatically when the user opens the Suggestions screen or views the Dashboard suggestion card. The algorithm considers current weather conditions, maps them to appropriate warmth levels, filters the wardrobe catalog, and ranks items by historical comfort scores. This is a system-focused diagram showing the decision logic rather than user interaction.

### Diagram

```mermaid
flowchart TD
    START(( ● Start ))
    START --> GET_WX[Get current weather data]

    GET_WX --> WX_CACHED{Recent cache exists?}
    WX_CACHED -- Yes --> USE_CACHE[Use cached weather snapshot]
    WX_CACHED -- No --> FETCH_API[Call OpenWeatherMap API]
    FETCH_API --> API_OK{API response OK?}
    API_OK -- Yes --> SAVE_SNAP[Save weather snapshot to DS5]
    SAVE_SNAP --> USE_CACHE
    API_OK -- No --> FALLBACK[Use comfort-only mode]

    USE_CACHE --> MAP_WARMTH[Map temperature to target warmth level]

    %% Temperature Mapping
    MAP_WARMTH --> WARMTH_LOGIC["
        0°C → Warmth 5
        10°C → Warmth 4
        18°C → Warmth 3
        25°C → Warmth 2
        30°C+ → Warmth 1
    "]

    WARMTH_LOGIC --> FILTER[Filter wardrobe: target warmth ± 1]
    FILTER --> HAS_MATCHES{Matching items found?}
    HAS_MATCHES -- No --> EXPAND[Expand to all active items]
    HAS_MATCHES -- Yes --> SCORE[Score items by avg comfort rating]
    EXPAND --> SCORE

    SCORE --> LOAD_HISTORY[Load comfort ratings from DS4]
    LOAD_HISTORY --> CALC["
        For each item:
        - avg_comfort = mean(historical ratings)
        - if no history: default = 3.0
    "]
    CALC --> RANK[Sort by descending comfort score]
    RANK --> RETURN[Return ranked suggestion list]
    RETURN --> END(( ● End ))

    FALLBACK --> LOAD_ALL[Load all active wardrobe items]
    LOAD_ALL --> SCORE
```

---

## Process Summary

| Step | Input | Output | Data Store |
|------|-------|--------|-----------|
| Fetch Weather | User location | Weather snapshot | DS5 |
| Map Warmth | Temperature (°C) | Target warmth level (1–5) | — |
| Filter Wardrobe | Target warmth, user ID | Matching clothing items | DS2 |
| Score Items | Item IDs | Comfort scores per item | DS4 |
| Rank & Return | Scored items | Ordered suggestion list | — |

---

*Activity diagrams created using Mermaid syntax. Render in any Mermaid-compatible viewer (GitHub, LucidChart import, VS Code Mermaid extension, or mermaid.live).*
