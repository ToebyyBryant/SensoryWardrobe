# Implementation Plan: Full App Completion

## Overview

Complete the Sensory Wardrobe Flutter application by implementing all remaining screens, wiring providers to repositories, adding auth guards, onboarding, multi-profile switching, notification scheduling, admin features, and image display. Tasks follow the provider dependency graph: auth state → database migration → wardrobe providers → log outfit/suggestions → notifications → admin.

## Tasks

- [ ] 1. Database migration and auth foundation
  - [ ] 1.1 Implement database schema v2 migration
    - Update `DatabaseHelper._initDatabase` to set version to 2
    - Implement `_onUpgrade` to add `role TEXT NOT NULL DEFAULT 'user'` and `is_disabled INTEGER NOT NULL DEFAULT 0` columns to `user_profiles`
    - Handle fresh installs by including new columns in `_onCreate`
    - _Requirements: 14.2, 14.5_

  - [ ] 1.2 Implement auth state providers and currentUserIdProvider
    - Create `lib/features/auth/presentation/providers/auth_providers.dart`
    - Implement `authStateProvider` as `StreamProvider<User?>` wrapping `FirebaseAuth.authStateChanges`
    - Implement `currentUserIdProvider` deriving the UID string
    - Implement `activeProfileIdProvider` as a `StateProvider<String>` defaulting to currentUserId
    - _Requirements: 8.1, 8.4, 10.2_

  - [ ] 1.3 Implement authentication guard in GoRouter
    - Update `app_router.dart` to add `redirect` callback checking `authStateProvider`
    - Exempt `/login`, `/register`, `/onboarding` from redirect
    - Store intended destination in query parameter for post-login redirect
    - Add `/onboarding` and `/admin` routes to the route table
    - Add `/wardrobe/edit/:id` route for edit mode
    - Update `/log-outfit/rate` to accept `:id` path parameter
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 14.5_

  - [ ]* 1.4 Write property tests for auth guard redirect logic
    - **Property 11: Auth guard redirect for protected routes**
    - **Property 12: Post-login redirect preserves original destination**
    - **Validates: Requirements 8.1, 8.2**

- [ ] 2. Wardrobe list and filter implementation
  - [ ] 2.1 Create wardrobe providers
    - Create `lib/features/wardrobe/presentation/providers/wardrobe_providers.dart`
    - Implement `wardrobeRepositoryProvider`, `wardrobeListProvider` (StateNotifier with loadItems, archiveItem)
    - Implement `wardrobeFilterProvider` and `filteredWardrobeProvider`
    - _Requirements: 1.1, 1.5, 1.6_

  - [ ] 2.2 Implement wardrobe list screen UI
    - Replace placeholder in `wardrobe_screen.dart` with `Consumer` watching `filteredWardrobeProvider`
    - Display each item with name, category, fabric, and `ClothingThumbnail` widget
    - Add empty-state message with prompt to add first item
    - Add swipe-to-archive (soft delete) with confirmation dialog
    - Add filter chip bar for category, fabric, and sensory tag filtering
    - Implement tap-to-navigate to edit screen (`/wardrobe/edit/:id`)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

  - [ ]* 2.3 Write property tests for wardrobe filtering
    - **Property 1: Active items filter invariant**
    - **Property 2: Wardrobe filter correctness**
    - **Validates: Requirements 1.1, 1.5, 1.6**

- [ ] 3. Add/edit clothing item with photo integration
  - [ ] 3.1 Create clothing item form provider
    - Create `lib/features/wardrobe/presentation/providers/clothing_item_form_provider.dart`
    - Implement `ClothingItemFormState` with all fields, `isValid` getter, and `copyWith`
    - Implement `ClothingItemFormNotifier` with setters, `pickImage`, `submit`, and `loadExisting` (for edit mode)
    - Add form validation rejecting empty/whitespace name or category
    - _Requirements: 2.1, 2.4, 2.5, 2.6_

  - [ ] 3.2 Update add/edit clothing item screen
    - Update `add_clothing_item_screen.dart` to consume form provider
    - Add image_picker integration (camera + gallery choice)
    - Display selected photo preview
    - Add sensory tag multi-select chips (texture descriptors, pressure tolerance, warmth level slider)
    - Show inline validation errors for required fields
    - Support edit mode: load existing item data when `:id` param present
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [ ]* 3.3 Write property tests for clothing item persistence and validation
    - **Property 3: Clothing item persistence round-trip**
    - **Property 4: Clothing item form validation rejects invalid input**
    - **Validates: Requirements 2.1, 2.4, 2.5**

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Log outfit screen implementation
  - [ ] 5.1 Create outfit log providers
    - Create `lib/features/outfit_log/presentation/providers/outfit_log_providers.dart`
    - Implement `OutfitLogFormState` and `OutfitLogFormNotifier` with toggleItem, setNotes, submit
    - Ensure submit fetches weather snapshot if none cached, associates it with log
    - Implement `outfitLogRepositoryProvider`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [ ] 5.2 Implement log outfit screen UI
    - Replace placeholder in `log_outfit_screen.dart` with multi-select item list from `wardrobeListProvider`
    - Show each item with thumbnail, name, category as selectable tiles
    - Add optional notes text field
    - Add confirm button that calls `OutfitLogFormNotifier.submit`
    - On success, navigate to `/log-outfit/rate/:logId`
    - _Requirements: 3.1, 3.2, 3.5, 3.6_

  - [ ]* 5.3 Write property test for outfit log creation
    - **Property 5: Outfit log preserves item selection and weather link**
    - **Validates: Requirements 3.2, 3.3**

- [ ] 6. Comfort rating save wiring
  - [ ] 6.1 Create comfort rating provider
    - Create `lib/features/outfit_log/presentation/providers/comfort_rating_provider.dart`
    - Implement `ComfortRatingNotifier` with `saveRating` method
    - Validate overall score is in [1,5] before saving
    - Return success/failure for UI feedback
    - _Requirements: 4.1, 4.4_

  - [ ] 6.2 Wire comfort rating screen to provider
    - Update `comfort_rating_screen.dart` to accept `outfitLogId` from route parameter
    - Wire `_saveRating()` to call `ComfortRatingNotifier.saveRating`
    - Show success SnackBar and navigate to Dashboard on success
    - Show error SnackBar and retain form data on failure
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [ ]* 6.3 Write property tests for comfort rating
    - **Property 6: Comfort rating persistence round-trip**
    - **Property 7: Comfort score validation range**
    - **Validates: Requirements 4.1, 4.4**

- [ ] 7. Suggestions screen and dashboard integration
  - [ ] 7.1 Create suggestions providers
    - Create `lib/features/suggestions/presentation/providers/suggestions_providers.dart`
    - Implement `suggestionEngineProvider`, `suggestionsProvider` (StateNotifier)
    - Handle weather unavailable case (use default weather or comfort-only sorting)
    - _Requirements: 5.1, 5.2, 5.5_

  - [ ] 7.2 Implement suggestions screen UI
    - Replace placeholder in `suggestions_screen.dart` with list from `suggestionsProvider`
    - Display items sorted by descending comfort score
    - Add tap handler showing bottom sheet with sensory details and average score
    - Show "add more items" prompt if wardrobe has fewer than 3 items
    - Show "weather unavailable" banner when weather data is missing
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [ ] 7.3 Wire dashboard suggestion card
    - Update `_SuggestionCard` in `dashboard_screen.dart` to watch `suggestionsProvider`
    - Display top-ranked item with `ClothingThumbnail`, name, and category
    - Navigate to `/suggestions` on tap
    - Show prompt to add items when no suggestions available
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ]* 7.4 Write property test for suggestion sorting
    - **Property 8: Suggestions sorted by descending comfort score**
    - **Validates: Requirements 5.2**

- [ ] 8. History and trends display
  - [ ] 8.1 Create history providers
    - Create `lib/features/history/presentation/providers/history_providers.dart`
    - Implement `OutfitLogWithDetails` model, `outfitLogListProvider`, `historyFilterProvider`, `filteredHistoryProvider`
    - Query joins outfit_logs with wardrobe_items, weather_snapshots, and comfort_ratings
    - Ensure results sorted by date descending
    - _Requirements: 7.1, 7.2, 7.4_

  - [ ] 8.2 Implement history screen outfit log tab
    - Replace "coming soon" placeholder in `history_screen.dart` with list view
    - Display each entry: date, item names, weather conditions, comfort score
    - Add filter controls (date range picker, category dropdown)
    - _Requirements: 7.1, 7.2, 7.4_

  - [ ] 8.3 Implement comfort trends tab
    - Add a line chart widget (CustomPaint-based or lightweight chart package)
    - X-axis: date, Y-axis: comfort score (1–5)
    - Overlay additional lines for texture, pressure, temperature sub-scores when data exists
    - _Requirements: 7.3, 7.5_

  - [ ]* 8.4 Write property tests for history
    - **Property 9: History entries sorted in reverse chronological order**
    - **Property 10: History filter correctness**
    - **Validates: Requirements 7.1, 7.4**

- [ ] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Onboarding flow
  - [ ] 10.1 Create onboarding provider
    - Create `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
    - Implement `OnboardingState` (currentStep, sensoryPreferences, firstItem, isComplete)
    - Implement `OnboardingNotifier` with `complete` and `skip` methods
    - Save sensory preferences to user profile, save first item to wardrobe
    - _Requirements: 9.2, 9.3, 9.4, 9.5_

  - [ ] 10.2 Implement onboarding screen UI
    - Create `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
    - Build a 3-step PageView: Welcome/Preferences → Add First Item → Completion
    - Step 1: texture sensitivity, pressure tolerance, temperature preference selectors
    - Step 2: simplified clothing item form (name, category, optional photo)
    - Step 3: summary + "Get Started" button
    - Add skip button that saves defaults and navigates to Dashboard
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

  - [ ]* 10.3 Write property test for profile persistence
    - **Property 13: Profile update persistence round-trip**
    - **Validates: Requirements 9.4, 12.2**

- [ ] 11. Multi-profile switching
  - [ ] 11.1 Implement profile switcher provider and widget
    - Create `lib/features/profile/presentation/providers/profile_providers.dart`
    - Implement `dependentProfilesProvider` and `switchToProfile` function
    - Create `lib/features/profile/presentation/widgets/profile_switcher.dart`
    - Show dropdown/sheet of dependent profiles for caregiver users
    - Update AppBar to show dependent name when non-primary profile is active
    - _Requirements: 10.1, 10.2, 10.3, 10.4_

  - [ ]* 11.2 Write property test for profile context isolation
    - **Property 14: Multi-profile context isolation**
    - **Validates: Requirements 10.2**

- [ ] 12. Profile and settings screens
  - [ ] 12.1 Implement profile screen
    - Update `profile_screen.dart` with display name, email, sensory preferences summary
    - Add edit mode with save button calling auth repository update
    - Show dependent profiles list for caregivers with switcher integration
    - Add logout button calling `AuthRepository.logout`
    - _Requirements: 12.1, 12.2, 12.3, 12.4_

  - [ ] 12.2 Create settings providers
    - Create `lib/features/settings/presentation/providers/settings_providers.dart`
    - Implement `SettingsState` and `SettingsNotifier`
    - Wire to `NotificationService`, `BackupService`, `SharedPreferences`, `FlutterSecureStorage`
    - _Requirements: 13.1, 13.2, 13.6_

  - [ ] 12.3 Implement settings screen UI
    - Update `settings_screen.dart` with notification time pickers, enable/disable toggles
    - Add backup section: manual backup button, restore button, last backup timestamp
    - Add API key field with secure storage persistence
    - Show error messages with retry on backup/restore failure
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_

- [ ] 13. Notification scheduling implementation
  - [ ] 13.1 Complete notification service with timezone-aware scheduling
    - Add `timezone` package dependency to pubspec.yaml
    - Initialize timezone data in app startup
    - Implement `scheduleMorningReminder` using `zonedSchedule` with `tz.TZDateTime`
    - Implement `scheduleEveningRatingReminder` with same pattern
    - Implement `_nextInstanceOfTime` helper
    - Register `onDidReceiveNotificationResponse` callback for navigation via payload
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [ ]* 13.2 Write property test for timezone scheduling
    - **Property 15: Timezone-aware notification scheduling**
    - **Validates: Requirements 11.5**

- [ ] 14. Admin system management
  - [ ] 14.1 Create admin repository
    - Create `lib/features/admin/data/repositories/admin_repository.dart`
    - Implement `getAllUsers`, `setUserDisabled`, `getSystemConfig`, `updateSystemConfig`
    - Store system config in SharedPreferences
    - _Requirements: 14.1, 14.2, 14.3, 14.4_

  - [ ] 14.2 Create admin providers and screen
    - Create `lib/features/admin/presentation/providers/admin_providers.dart`
    - Create `lib/features/admin/presentation/screens/admin_screen.dart`
    - Display user list with status indicators (active/disabled)
    - Add enable/disable toggle buttons per user
    - Display system config section (default notification times, weather cache duration)
    - Add admin role redirect guard in route configuration
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

  - [ ]* 14.3 Write property tests for admin features
    - **Property 16: Admin user list completeness**
    - **Property 17: Admin role restriction**
    - **Validates: Requirements 14.1, 14.2, 14.5**

- [ ] 15. Image display shared widget
  - [ ] 15.1 Create ClothingThumbnail shared widget
    - Create `lib/shared/widgets/clothing_thumbnail.dart`
    - Implement async file existence check with `FutureBuilder`
    - Display `Image.file` with fade-in animation when photo exists
    - Display placeholder icon when photo is null or file missing
    - Log missing files via `debugPrint`
    - _Requirements: 15.1, 15.2, 15.3_

  - [ ] 15.2 Integrate ClothingThumbnail across all screens
    - Use in wardrobe list items, suggestions list, outfit log selection, history entries
    - Use full-size image in detail/edit views
    - _Requirements: 15.1, 15.3_

  - [ ]* 15.3 Write property test for photo display fallback
    - **Property 18: Photo display with missing file fallback**
    - **Validates: Requirements 15.1, 15.2**

- [ ] 16. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The project uses Dart/Flutter with Riverpod state management and GoRouter navigation
- Database migration (task 1.1) must run before any providers that query user_profiles with role/disabled columns
- The `activeProfileIdProvider` is the keystone for multi-profile isolation — all data providers depend on it

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "15.1"] },
    { "id": 1, "tasks": ["1.3", "2.1", "15.2"] },
    { "id": 2, "tasks": ["1.4", "2.2", "2.3", "3.1"] },
    { "id": 3, "tasks": ["3.2", "3.3", "5.1"] },
    { "id": 4, "tasks": ["5.2", "5.3", "6.1", "7.1"] },
    { "id": 5, "tasks": ["6.2", "6.3", "7.2", "7.3"] },
    { "id": 6, "tasks": ["7.4", "8.1"] },
    { "id": 7, "tasks": ["8.2", "8.3", "8.4"] },
    { "id": 8, "tasks": ["10.1", "11.1", "12.1"] },
    { "id": 9, "tasks": ["10.2", "10.3", "11.2", "12.2"] },
    { "id": 10, "tasks": ["12.3", "13.1"] },
    { "id": 11, "tasks": ["13.2", "14.1"] },
    { "id": 12, "tasks": ["14.2", "14.3", "15.3"] }
  ]
}
```
