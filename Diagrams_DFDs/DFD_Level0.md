# Sensory Wardrobe — Level 0 DFD (Major Processes)

> **DRAFT** — Bruce Schulz | CIS248 Advanced App Development | Summer 2026

---

## Diagram

```mermaid
graph TD
    %% ── External Entities ──────────────────────────────────────────
    U["👤 User / Caregiver"]
    ADM["🔐 Admin"]
    WX["🌤️ OpenWeatherMap API"]
    CLOUD["☁️ Cloud Storage"]
    NOTIF["🔔 Push Notification Service"]

    %% ── Data Stores ─────────────────────────────────────────────────
    DS1[("DS1: User Profiles")]
    DS2[("DS2: Wardrobe Catalog")]
    DS3[("DS3: Outfit Logs")]
    DS4[("DS4: Comfort Ratings")]
    DS5[("DS5: Weather Snapshots")]

    %% ── Processes ────────────────────────────────────────────────────
    P1(["1.0\nManage User\nAccounts & Profiles"])
    P2(["2.0\nManage Wardrobe\nCatalog"])
    P3(["3.0\nFetch & Store\nWeather Data"])
    P4(["4.0\nLog Outfit\n& Rate Comfort"])
    P5(["5.0\nGenerate Smart\nSuggestions"])
    P6(["6.0\nView History\n& Trends"])
    P7(["7.0\nManage Notifications\n& Reminders"])
    P8(["8.0\nBackup & Restore\nData"])
    P9(["9.0\nAdmin System\nManagement"])

    %% ── User / Caregiver → Processes ────────────────────────────────
    U -- "Registration, login,\nprofile settings" --> P1
    U -- "Clothing items,\nsensory tags, photos" --> P2
    U -- "Selected outfit,\ncomfort rating" --> P4
    U -- "History query,\nfilter criteria" --> P6

    %% ── Processes → User ────────────────────────────────────────────
    P1 -- "Confirmed profile,\naccessibility settings" --> U
    P5 -- "Outfit suggestions\n(weather + comfort matched)" --> U
    P6 -- "Comfort trends,\noutfit history report" --> U
    P7 -- "Reminders / alerts" --> U

    %% ── Process 1: Account Management ──────────────────────────────
    P1 -- "Store/update profile" --> DS1
    DS1 -- "Retrieve profile" --> P1

    %% ── Process 2: Wardrobe Catalog ─────────────────────────────────
    P2 -- "Save clothing item" --> DS2
    DS2 -- "Retrieve catalog" --> P2
    DS2 -- "Clothing items for suggestion" --> P5

    %% ── Process 3: Weather ───────────────────────────────────────────
    U -- "Location" --> P3
    P3 -- "Weather request\n(location)" --> WX
    WX -- "Weather response\n(temp, conditions)" --> P3
    P3 -- "Store weather snapshot" --> DS5
    DS5 -- "Weather context" --> P5
    DS5 -- "Weather context" --> P4

    %% ── Process 4: Outfit Logging & Rating ──────────────────────────
    P4 -- "Save outfit log" --> DS3
    P4 -- "Save comfort rating" --> DS4
    DS3 -- "Outfit log entry" --> P6
    DS4 -- "Comfort rating entry" --> P6
    DS4 -- "Historical comfort data" --> P5

    %% ── Process 5: Smart Suggestions ────────────────────────────────
    DS1 -- "User preferences" --> P5

    %% ── Process 6: History & Trends ─────────────────────────────────
    DS3 -- "Outfit history" --> P6
    DS4 -- "Comfort history" --> P6

    %% ── Process 7: Notifications ─────────────────────────────────────
    P7 -- "Notification payload" --> NOTIF
    NOTIF -- "Push notification\n(delivered to device)" --> U

    %% ── Process 8: Backup & Restore ─────────────────────────────────
    DS1 & DS2 & DS3 & DS4 -- "User data for backup" --> P8
    P8 -- "Encrypted data backup" --> CLOUD
    CLOUD -- "Restored data" --> P8
    P8 -- "Restored data" --> DS1

    %% ── Process 9: Admin ─────────────────────────────────────────────
    ADM -- "System config,\nuser management commands" --> P9
    P9 -- "Updated config,\nuser account changes" --> DS1
    P9 -- "System status,\naggregated usage data" --> ADM
```

---

## Processes

| # | Process | Description |
|---|---|---|
| 1.0 | Manage User Accounts & Profiles | Registration, login, multi-profile support, accessibility preferences |
| 2.0 | Manage Wardrobe Catalog | Add, edit, delete clothing items; attach sensory tags and photos |
| 3.0 | Fetch & Store Weather Data | Call OpenWeatherMap API with user location; cache weather snapshots |
| 4.0 | Log Outfit & Rate Comfort | Record daily outfit selection, attach weather context, capture post-wear comfort score |
| 5.0 | Generate Smart Suggestions | Analyze weather + comfort history + wardrobe catalog to recommend outfits |
| 6.0 | View History & Trends | Display outfit logs, comfort trends, and pattern summaries |
| 7.0 | Manage Notifications & Reminders | Schedule and send outfit/logging reminders via push notification service |
| 8.0 | Backup & Restore Data | Encrypt and sync user data to cloud; restore on new device or app reinstall |
| 9.0 | Admin System Management | Manage user accounts, system configuration, and monitor usage |

---

## Data Stores

| ID | Store | Contents |
|---|---|---|
| DS1 | User Profiles | Account credentials, preferences, accessibility settings, multi-profile links |
| DS2 | Wardrobe Catalog | Clothing items, sensory tags, photos, categories |
| DS3 | Outfit Logs | Date, selected items, linked weather snapshot |
| DS4 | Comfort Ratings | Post-wear comfort scores linked to outfit logs |
| DS5 | Weather Snapshots | Cached weather data (temp, humidity, conditions) tied to a date/location |

---

*This is a DRAFT. Processes, data stores, and flows subject to revision.*
