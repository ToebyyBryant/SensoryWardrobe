# Wireframes — Sensory Wardrobe

> **Bruce Schulz** | CIS248 Advanced App Development | Summer 2026

---

## Design Principles (UI/UX Considerations)

- **Accessibility first**: Large touch targets (48dp minimum), high contrast text, clear iconography
- **Sensory-friendly**: Calm color palette, minimal visual clutter, predictable navigation
- **Mobile-first**: Designed for one-handed phone operation
- **Consistent navigation**: Bottom navigation bar across all main screens

---

## Wireframe 1: Dashboard (Home Screen)

**Purpose:** Central hub showing weather, top suggestion, and quick actions.

```
┌─────────────────────────────────┐
│  ≡  Sensory Wardrobe    [👤]   │  ← App Bar (hamburger / profile)
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │  🌤️  72°F  Partly Cloudy │   │  ← Weather Card
│  │  Humidity: 45%           │   │
│  │  Feels like: 70°F       │   │
│  └─────────────────────────┘   │
│                                 │
│  ── Today's Suggestion ──────   │
│  ┌─────────────────────────┐   │
│  │  [📷]  Cotton Tee       │   │  ← Top Suggestion Card
│  │         Tops • Soft      │   │
│  │         ★★★★☆ comfort   │   │
│  │                [View All]│   │
│  └─────────────────────────┘   │
│                                 │
│  ── Quick Actions ───────────   │
│  ┌───────────┐ ┌───────────┐   │
│  │  👕        │ │  📝        │   │
│  │ Log Outfit │ │Rate Comfort│   │  ← Action Buttons
│  └───────────┘ └───────────┘   │
│  ┌───────────┐ ┌───────────┐   │
│  │  ➕        │ │  📊        │   │
│  │ Add Item  │ │  History   │   │
│  └───────────┘ └───────────┘   │
│                                 │
├─────────────────────────────────┤
│  🏠    👕    💡    📊    ⚙️    │  ← Bottom Navigation
│ Home Wardrobe Suggest History Settings│
└─────────────────────────────────┘
```

**Key Interactions:**
- Weather card auto-refreshes based on location
- Suggestion card taps through to full suggestions list
- Quick action buttons navigate to respective screens
- Bottom nav provides persistent access to main features

---

## Wireframe 2: Add Clothing Item Screen

**Purpose:** Form for adding a new wardrobe item with sensory attributes.

```
┌─────────────────────────────────┐
│  ←  Add Clothing Item    [Save]│  ← App Bar with back + save
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │                         │   │
│  │    [ 📷 Add Photo ]     │   │  ← Photo picker area
│  │    Tap to take/choose   │   │
│  │                         │   │
│  └─────────────────────────┘   │
│                                 │
│  Item Name *                    │
│  ┌─────────────────────────┐   │
│  │ e.g., Blue Cotton Tee   │   │  ← Text input
│  └─────────────────────────┘   │
│                                 │
│  Category *              ▼     │
│  ┌─────────────────────────┐   │
│  │ Top                     │   │  ← Dropdown
│  └─────────────────────────┘   │
│                                 │
│  Fabric                  ▼     │
│  ┌─────────────────────────┐   │
│  │ Cotton                  │   │  ← Dropdown
│  └─────────────────────────┘   │
│                                 │
│  Warmth Level (1-5)            │
│  ○ ○ ○ ● ○                    │  ← Radio/slider (1=light, 5=warm)
│  Light        Warm             │
│                                 │
│  Sensory Tags                  │
│  ┌─────────────────────────┐   │
│  │ [soft✓] [smooth] [stretchy✓]│  ← Chip multi-select
│  │ [loose-fit] [seamless✓]     │
│  │ [tagless] [lightweight✓]    │
│  │ [breathable] [moisture-     │
│  │  wicking]                   │
│  └─────────────────────────┘   │
│                                 │
│  Notes (optional)              │
│  ┌─────────────────────────┐   │
│  │                         │   │  ← Multi-line text
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │      [ SAVE ITEM ]      │   │  ← Primary action button
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

**Key Interactions:**
- Photo tap opens action sheet: "Take Photo" or "Choose from Gallery"
- Category and Fabric are dropdown selectors from predefined lists
- Sensory tags are multi-select chips (tap to toggle)
- Warmth level uses a visual 1–5 selector
- Save validates name + category are filled, shows error if not
- On save success, navigates back to wardrobe list

---

## Wireframe 3: Log Outfit & Comfort Rating

**Purpose:** Two-step flow — select items, then rate comfort after wearing.

### Step 1: Log Outfit

```
┌─────────────────────────────────┐
│  ←  Log Today's Outfit         │  ← App Bar
├─────────────────────────────────┤
│                                 │
│  🌤️ 72°F Partly Cloudy        │  ← Weather context banner
│                                 │
│  ── Select Items Worn ────────  │
│                                 │
│  ┌─────────────────────────┐   │
│  │ ☑ [📷] Cotton Tee       │   │  ← Checkbox + thumbnail
│  │       Top • Warmth: 2   │   │
│  ├─────────────────────────┤   │
│  │ ☑ [📷] Khaki Shorts     │   │
│  │       Bottom • Warmth: 1│   │
│  ├─────────────────────────┤   │
│  │ ☐ [📷] Denim Jacket     │   │
│  │       Jacket • Warmth: 3│   │
│  ├─────────────────────────┤   │
│  │ ☐ [📷] Running Shoes    │   │
│  │       Shoes • Warmth: 2 │   │
│  └─────────────────────────┘   │
│                                 │
│  Notes (optional)              │
│  ┌─────────────────────────┐   │
│  │ Going to the park       │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │    [ LOG OUTFIT ✓ ]     │   │  ← Submit (2 items selected)
│  └─────────────────────────┘   │
│                                 │
├─────────────────────────────────┤
│  🏠    👕    💡    📊    ⚙️    │
└─────────────────────────────────┘
```

### Step 2: Comfort Rating (after wearing)

```
┌─────────────────────────────────┐
│  ←  Rate Your Comfort          │  ← App Bar
├─────────────────────────────────┤
│                                 │
│  How comfortable was today's   │
│  outfit?                        │
│                                 │
│  ── Overall Comfort * ────────  │
│                                 │
│     ★  ★  ★  ★  ☆             │  ← Star rating (4/5 selected)
│     Very         Very          │
│   Uncomfortable  Comfortable   │
│                                 │
│  ── Sub-Scores (Optional) ───   │
│                                 │
│  Texture feel:                 │
│  ○ ○ ○ ● ○                    │  ← 4/5
│                                 │
│  Pressure / Fit:               │
│  ○ ○ ○ ○ ●                    │  ← 5/5
│                                 │
│  Temperature comfort:          │
│  ○ ○ ● ○ ○                    │  ← 3/5
│                                 │
│  Notes:                        │
│  ┌─────────────────────────┐   │
│  │ Shirt felt great but    │   │
│  │ shorts were too thin    │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │    [ SAVE RATING ✓ ]    │   │  ← Submit
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

**Key Interactions:**
- Step 1: Wardrobe items shown as checklist with thumbnails
- Weather banner provides context for what was worn
- At least 1 item must be checked to enable "Log Outfit"
- Step 2: Overall score required, sub-scores optional
- Star rating is large and easy to tap (accessibility)
- Save shows success snackbar, navigates to Dashboard

---

## Wireframe 4: Outfit Suggestions Screen

**Purpose:** Display weather-matched, comfort-ranked outfit suggestions.

```
┌─────────────────────────────────┐
│  ←  Today's Suggestions        │  ← App Bar
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │ 🌤️ 72°F | Target Warmth: 2 │  ← Weather context
│  │ Showing items for mild      │
│  │ weather                     │
│  └─────────────────────────┘   │
│                                 │
│  ── Recommended Items ────────  │
│                                 │
│  ┌─────────────────────────┐   │
│  │ #1                      │   │
│  │ [📷]  Cotton Tee        │   │  ← Top ranked item
│  │        Top • Warmth: 2  │   │
│  │        ★★★★½ avg comfort│   │
│  │  Tags: soft, breathable │   │
│  │                    [>]  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ #2                      │   │
│  │ [📷]  Linen Shorts      │   │
│  │        Bottom • Warmth: 1│  │
│  │        ★★★★☆ avg comfort│   │
│  │  Tags: lightweight, smooth│  │
│  │                    [>]  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │ #3                      │   │
│  │ [📷]  Canvas Sneakers   │   │
│  │        Shoes • Warmth: 2│   │
│  │        ★★★☆☆ avg comfort│   │
│  │  Tags: stretchy, seamless│  │
│  │                    [>]  │   │
│  └─────────────────────────┘   │
│                                 │
│  ── Why These? ───────────────  │
│  Based on today's weather and  │
│  your comfort history. Items   │
│  you've rated highly in similar│
│  conditions rank higher.       │
│                                 │
├─────────────────────────────────┤
│  🏠    👕    💡    📊    ⚙️    │
└─────────────────────────────────┘
```

**Key Interactions:**
- Weather context banner shows current conditions and target warmth
- Items ranked by suggestion algorithm (weather match + comfort score)
- Tapping [>] opens bottom sheet with full item details
- If wardrobe < 3 items, shows "Add more items to get better suggestions" prompt
- If weather unavailable, shows notice: "Suggestions based on comfort only"
- Pull-to-refresh re-fetches weather and regenerates suggestions

---

## Wireframe 5: History & Comfort Trends

**Purpose:** View past outfit logs and visualize comfort patterns over time.

```
┌─────────────────────────────────┐
│  ←  History & Trends           │  ← App Bar
├─────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐    │
│  │  History  │ │  Trends  │    │  ← Tab bar
│  └──────────┘ └──────────┘    │
├─────────────────────────────────┤
│                                 │
│  [Filter: All ▼] [Date Range ▼]│  ← Filter controls
│                                 │
│  ── June 28, 2026 ───────────  │
│  ┌─────────────────────────┐   │
│  │ Cotton Tee + Khaki Shorts│   │
│  │ 🌤️ 72°F | Comfort: ★★★★☆│  │
│  │ "Felt great at the park" │   │
│  └─────────────────────────┘   │
│                                 │
│  ── June 27, 2026 ───────────  │
│  ┌─────────────────────────┐   │
│  │ Wool Sweater + Jeans    │   │
│  │ 🌧️ 58°F | Comfort: ★★★☆☆│  │
│  │ "Sweater felt scratchy" │   │
│  └─────────────────────────┘   │
│                                 │
│  ── June 26, 2026 ───────────  │
│  ┌─────────────────────────┐   │
│  │ Linen Shirt + Shorts    │   │
│  │ ☀️ 85°F | Comfort: ★★★★★│  │
│  │ "Perfect for hot day"   │   │
│  └─────────────────────────┘   │
│                                 │
│  [Load More...]                │
│                                 │
├─────────────────────────────────┤
│  🏠    👕    💡    📊    ⚙️    │
└─────────────────────────────────┘

─── Trends Tab ─────────────────────

┌─────────────────────────────────┐
│  ←  History & Trends           │
├─────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐    │
│  │  History  │ │ [Trends] │    │  ← Trends tab active
│  └──────────┘ └──────────┘    │
├─────────────────────────────────┤
│                                 │
│  ── Comfort Over Time ────────  │
│                                 │
│  5 |          *    *     *     │
│  4 |    *  *     *   *        │  ← Line chart
│  3 |  *                  *    │
│  2 |                          │
│  1 |                          │
│    |_________________________ │
│     Jun20  Jun23  Jun26 Jun29 │
│                                 │
│  ── By Category ──────────────  │
│                                 │
│  Tops:     ★★★★☆  (avg 4.2)  │
│  Bottoms:  ★★★½☆  (avg 3.5)  │
│  Shoes:    ★★★☆☆  (avg 3.0)  │
│  Jackets:  ★★★★☆  (avg 4.0)  │
│                                 │
│  ── Insights ─────────────────  │
│  • You're most comfortable    │
│    in soft, lightweight tops  │
│  • Wool items score lower on  │
│    texture comfort            │
│                                 │
├─────────────────────────────────┤
│  🏠    👕    💡    📊    ⚙️    │
└─────────────────────────────────┘
```

**Key Interactions:**
- Tab switch between History (list) and Trends (charts)
- Filter by category or date range
- History entries show outfit summary, weather, and comfort at a glance
- Trends tab shows comfort line chart over time
- Category breakdown shows average comfort per clothing type
- Insights generated from comfort data patterns

---

## Navigation Flow Summary

```
                    ┌──────────┐
                    │  Login   │
                    └────┬─────┘
                         │ (auth success)
                    ┌────▼─────┐
         ┌──────── │ Dashboard │ ────────┐
         │         └────┬─────┘         │
         │              │               │
    ┌────▼────┐   ┌────▼─────┐   ┌────▼─────┐
    │ Wardrobe│   │Log Outfit│   │Suggestions│
    └────┬────┘   └────┬─────┘   └──────────┘
         │              │
    ┌────▼────┐   ┌────▼──────┐
    │Add/Edit │   │Rate Comfort│
    │  Item   │   └───────────┘
    └─────────┘
```

---

*Wireframes represent the planned UI layout. Final implementation may vary slightly based on Flutter widget constraints and accessibility testing.*
