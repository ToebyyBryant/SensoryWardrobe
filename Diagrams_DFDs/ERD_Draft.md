# Sensory Wardrobe — Entity-Relationship Diagram (DRAFT)

> **Bruce Schulz** | CIS248 Advanced App Development | Summer 2026

---

## Narrative

This ERD represents the logical data model for the Sensory Wardrobe application. It maps directly to the five SQLite data stores (DS1–DS5) identified in the Level 0 DFD and includes the relationships between entities that drive the suggestion engine, outfit logging, and multi-profile management features.

The central feedback loop — where users log outfits, rate comfort, and receive improved suggestions — is reflected in the relationships between `WardrobeItem`, `OutfitLog`, `ComfortRating`, and `WeatherSnapshot`.

---

## ER Diagram

```mermaid
erDiagram
    %% ═══════════════════════════════════════════════════════════════
    %% ENTITIES & ATTRIBUTES
    %% ═══════════════════════════════════════════════════════════════

    USER_PROFILE {
        int id PK
        string display_name
        string email UK
        string password_hash
        boolean is_dependent
        int caregiver_id FK "NULL if independent"
        json sensory_preferences "texture sensitivity, warmth pref"
        string role "user | caregiver | admin"
        boolean is_disabled
        datetime created_at
        datetime updated_at
    }

    WARDROBE_ITEM {
        int id PK
        int user_id FK
        string name
        string category "Top, Bottom, Shoes, etc."
        string fabric
        json sensory_tags "soft, stretchy, seamless, etc."
        int warmth_level "1 (very light) to 5 (very warm)"
        string photo_path "local file path or URL"
        boolean is_active
        datetime created_at
        datetime updated_at
    }

    OUTFIT_LOG {
        int id PK
        int user_id FK
        date logged_date
        json item_ids "array of wardrobe_item IDs"
        int weather_snapshot_id FK "NULL if weather unavailable"
        string notes "optional user notes"
        datetime created_at
    }

    COMFORT_RATING {
        int id PK
        int outfit_log_id FK
        int user_id FK
        int overall_score "1-5, required"
        int texture_score "1-5, optional"
        int pressure_score "1-5, optional"
        int temperature_score "1-5, optional"
        datetime created_at
    }

    WEATHER_SNAPSHOT {
        int id PK
        float location_lat
        float location_lon
        float temperature_c
        float feels_like_c
        int humidity "percentage"
        string condition "Clear, Rain, Snow, etc."
        float wind_speed
        datetime fetched_at
    }

    %% ═══════════════════════════════════════════════════════════════
    %% RELATIONSHIPS
    %% ═══════════════════════════════════════════════════════════════

    %% A caregiver manages zero or more dependent profiles
    USER_PROFILE ||--o{ USER_PROFILE : "manages (caregiver → dependent)"

    %% A user owns zero or more wardrobe items
    USER_PROFILE ||--o{ WARDROBE_ITEM : "owns"

    %% A user creates zero or more outfit logs
    USER_PROFILE ||--o{ OUTFIT_LOG : "logs"

    %% Each outfit log has exactly one comfort rating
    OUTFIT_LOG ||--|| COMFORT_RATING : "rated by"

    %% Each outfit log may reference a weather snapshot
    WEATHER_SNAPSHOT ||--o{ OUTFIT_LOG : "weather context for"

    %% A user creates zero or more comfort ratings
    USER_PROFILE ||--o{ COMFORT_RATING : "rates"

    %% Wardrobe items are referenced (via item_ids JSON) in outfit logs
    WARDROBE_ITEM }o--o{ OUTFIT_LOG : "included in"
```

---

## Entity Descriptions

| Entity | DFD Store | Purpose |
|--------|-----------|---------|
| USER_PROFILE | DS1 | Stores user accounts including caregivers, dependents, and admins. The self-referencing `caregiver_id` enables the multi-profile feature. |
| WARDROBE_ITEM | DS2 | Clothing catalog entries with sensory attributes. Each item belongs to one user and is tagged with sensory properties and a warmth level used by the suggestion engine. |
| OUTFIT_LOG | DS3 | Records a daily outfit selection. Links to the user, weather context at time of wear, and the specific wardrobe items chosen (stored as JSON array of IDs). |
| COMFORT_RATING | DS4 | Post-wear comfort feedback tied to an outfit log. The overall score is required; sub-scores (texture, pressure, temperature) are optional. These scores feed the suggestion engine's ranking algorithm. |
| WEATHER_SNAPSHOT | DS5 | Cached weather data from OpenWeatherMap API. Linked to outfit logs to provide environmental context and used by the suggestion engine for warmth-level matching. |

---

## Relationship Summary

| Relationship | Cardinality | Description |
|:---|:---:|:---|
| USER_PROFILE → USER_PROFILE | 1:M (self) | A caregiver manages zero or more dependent profiles |
| USER_PROFILE → WARDROBE_ITEM | 1:M | A user owns zero or more clothing items |
| USER_PROFILE → OUTFIT_LOG | 1:M | A user creates zero or more daily outfit logs |
| USER_PROFILE → COMFORT_RATING | 1:M | A user provides zero or more comfort ratings |
| OUTFIT_LOG → COMFORT_RATING | 1:1 | Each outfit log has exactly one associated comfort rating |
| WEATHER_SNAPSHOT → OUTFIT_LOG | 1:M | One weather snapshot can be referenced by multiple outfit logs (same day/location) |
| WARDROBE_ITEM ↔ OUTFIT_LOG | M:N | An outfit log contains multiple items; an item can appear in multiple logs (via `item_ids` JSON) |

---

## Design Notes & Assumptions

1. **Many-to-Many (Items ↔ Logs):** The current implementation stores `item_ids` as a JSON array inside `outfit_logs`. A normalized design would use a junction table (`outfit_log_items`), but the JSON approach was chosen for simplicity with SQLite and Flutter's data layer. This is noted as a potential normalization improvement.

2. **Self-Referencing Relationship:** The caregiver/dependent relationship is modeled as a self-referencing foreign key (`caregiver_id` → `user_profiles.id`). A dependent's `is_dependent = true` and their `caregiver_id` points to the managing caregiver's record.

3. **Comfort Rating Cardinality:** Each outfit log has exactly one comfort rating (1:1). The rating is created after the outfit is worn, typically in the evening when the notification reminder fires.

4. **Weather Snapshot Reuse:** Multiple outfit logs on the same day/location may reference the same cached weather snapshot, making this a 1:M relationship.

5. **Soft Delete Pattern:** `is_active` on wardrobe items and `is_disabled` on user profiles implement soft-delete behavior — records are never physically removed, preserving historical integrity for the suggestion engine.

6. **Role-Based Access:** The `role` field in USER_PROFILE (`user | caregiver | admin`) controls access to admin features (P9) and multi-profile management.

---

## Potential Normalization Improvements (for discussion)

- **Junction table for outfit items:** Replace `item_ids` JSON with an `OUTFIT_LOG_ITEMS` associative entity (outfit_log_id, wardrobe_item_id) for proper referential integrity.
- **Sensory tags normalization:** Replace `sensory_tags` JSON with a separate `SENSORY_TAG` entity and a many-to-many join table, enabling tag-based queries and analytics.
- **Notification preferences:** Could be extracted into a separate `NOTIFICATION_SETTINGS` entity rather than being embedded in user preferences.

---

*DRAFT — Submitted for instructor review. Will finalize based on feedback.*
