# Requirements Document

## Introduction

This document defines the requirements for completing the Sensory Wardrobe Flutter application — a sensory-aware wardrobe assistant for individuals with sensory processing differences (autism, SPD). The application helps users track clothing comfort and receive weather-appropriate outfit suggestions based on sensory comfort history. The scope covers all remaining unimplemented screens, wiring incomplete features to their repositories, adding auth guards, onboarding, multi-profile switching, notification scheduling, admin features, and image picker integration.

## Glossary

- **App**: The Sensory Wardrobe Flutter mobile application
- **User**: A person interacting with the App, including primary users and caregivers
- **Dependent**: A user account managed by a Caregiver via multi-profile support
- **Caregiver**: A User who manages one or more Dependent profiles
- **Wardrobe_Catalog**: The local data store (DS2) containing all clothing items with sensory tags
- **Clothing_Item**: A single garment entry in the Wardrobe_Catalog with name, category, fabric, sensory tags, warmth level, and optional photo
- **Outfit_Log**: A record (DS3) of clothing items worn on a given date, linked to a Weather_Snapshot
- **Comfort_Rating**: A post-wear assessment (DS4) containing an overall score (1–5) plus texture, pressure, and temperature sub-scores
- **Weather_Snapshot**: A cached record (DS5) of weather conditions at a location and time
- **Suggestion_Engine**: The component (P5) that recommends outfits based on weather and historical comfort scores
- **Notification_Service**: The component (P7) that schedules and delivers local push notifications
- **Backup_Service**: The component (P8) that encrypts and syncs user data to Firebase cloud storage
- **Auth_Guard**: A route-level check that redirects unauthenticated users to the login screen
- **Onboarding_Flow**: A first-run guided setup collecting sensory preferences and an initial wardrobe item
- **Admin_Panel**: The set of screens (P9) for system configuration and user account management
- **Dashboard**: The home screen displaying weather, suggestions, and quick actions
- **Router**: The GoRouter-based navigation system managing all application routes

## Requirements

### Requirement 1: Wardrobe List Screen

**User Story:** As a User, I want to view all my clothing items in a browsable list, so that I can manage my wardrobe catalog.

#### Acceptance Criteria

1. WHEN the User navigates to the wardrobe route, THE App SHALL display a list of all active Clothing_Items for the current User retrieved from the Wardrobe_Catalog.
2. WHEN no Clothing_Items exist for the current User, THE App SHALL display an empty-state message with a prompt to add the first item.
3. THE App SHALL display each Clothing_Item with its name, category, fabric type, and photo thumbnail if available.
4. WHEN the User taps a Clothing_Item in the list, THE App SHALL navigate to an edit screen pre-populated with the selected item's data.
5. WHEN the User initiates a delete action on a Clothing_Item, THE App SHALL perform a soft-delete by marking the item inactive in the Wardrobe_Catalog.
6. THE App SHALL provide a filter mechanism allowing the User to filter Clothing_Items by category, fabric, or sensory tag.

### Requirement 2: Add/Edit Clothing Item with Photo Integration

**User Story:** As a User, I want to add clothing items with photos and sensory tags, so that I can build a detailed wardrobe catalog.

#### Acceptance Criteria

1. WHEN the User submits the add-clothing-item form with valid data, THE App SHALL save the Clothing_Item to the Wardrobe_Catalog via the wardrobe repository.
2. WHEN the User taps the photo picker button, THE App SHALL invoke the image_picker plugin to allow selection from the device camera or gallery.
3. WHEN the User selects a photo, THE App SHALL store the local file path in the Clothing_Item record.
4. IF the User submits the form with missing required fields (name or category), THEN THE App SHALL display inline validation errors and prevent submission.
5. WHEN the User edits an existing Clothing_Item and saves, THE App SHALL update the corresponding record in the Wardrobe_Catalog.
6. THE App SHALL provide sensory tag selection (texture descriptors, pressure tolerance, warmth level) as part of the clothing item form.

### Requirement 3: Log Outfit Screen

**User Story:** As a User, I want to log my daily outfit by selecting items from my wardrobe, so that I can track what I wear and correlate it with comfort.

#### Acceptance Criteria

1. WHEN the User navigates to the log-outfit route, THE App SHALL display the list of active Clothing_Items available for selection.
2. WHEN the User selects one or more Clothing_Items and confirms, THE App SHALL create an Outfit_Log entry linked to the current date and selected items.
3. WHEN the Outfit_Log is saved, THE App SHALL associate the most recent Weather_Snapshot with the Outfit_Log entry.
4. IF no Weather_Snapshot exists for the current session, THEN THE App SHALL fetch current weather data before saving the Outfit_Log.
5. WHEN the Outfit_Log is saved successfully, THE App SHALL navigate the User to the Comfort_Rating screen for that log entry.
6. THE App SHALL allow the User to add optional text notes to the Outfit_Log entry.

### Requirement 4: Comfort Rating Save Wiring

**User Story:** As a User, I want my comfort ratings to be persisted, so that the app can learn from my sensory feedback over time.

#### Acceptance Criteria

1. WHEN the User submits a comfort rating, THE App SHALL save the Comfort_Rating (overall, texture, pressure, temperature scores and notes) to the local database linked to the corresponding Outfit_Log.
2. WHEN the save operation completes successfully, THE App SHALL display a confirmation message and navigate the User back to the Dashboard.
3. IF the save operation fails, THEN THE App SHALL display an error message and retain the form data for retry.
4. THE App SHALL validate that the overall score is an integer between 1 and 5 inclusive before saving.

### Requirement 5: Suggestions Screen

**User Story:** As a User, I want to see outfit recommendations based on today's weather and my comfort history, so that I can choose clothing that feels good.

#### Acceptance Criteria

1. WHEN the User navigates to the suggestions route, THE App SHALL invoke the Suggestion_Engine with the current Weather_Snapshot and User profile to generate recommendations.
2. THE App SHALL display suggested Clothing_Items sorted by descending historical comfort score.
3. WHEN the User taps a suggested item, THE App SHALL display the item's sensory details including fabric, warmth level, and average comfort score.
4. IF the Wardrobe_Catalog contains fewer than 3 items, THEN THE App SHALL display a message encouraging the User to add more items for better suggestions.
5. WHEN weather data is unavailable, THE App SHALL display suggestions based solely on historical comfort scores with a notice that weather context is missing.

### Requirement 6: Dashboard Suggestion Integration

**User Story:** As a User, I want to see today's top outfit suggestion on the dashboard, so that I get a quick recommendation without navigating away.

#### Acceptance Criteria

1. WHEN the Dashboard loads, THE App SHALL invoke the Suggestion_Engine and display the top-ranked Clothing_Item suggestion in the suggestion card.
2. WHEN the User taps the suggestion card, THE App SHALL navigate to the full Suggestions screen.
3. IF no suggestions are available, THEN THE App SHALL display a prompt to add wardrobe items or log outfits for better recommendations.

### Requirement 7: History and Trends Display

**User Story:** As a User, I want to view my outfit history and comfort trends over time, so that I can identify patterns in what works for me.

#### Acceptance Criteria

1. WHEN the User navigates to the history route, THE App SHALL display the Outfit Log tab listing all Outfit_Logs for the current User in reverse chronological order.
2. THE App SHALL display each Outfit_Log entry with its date, item names, weather conditions, and associated Comfort_Rating score.
3. WHEN the User selects the Comfort Trends tab, THE App SHALL display a chart visualizing comfort scores over time.
4. THE App SHALL provide filter controls allowing the User to filter history by date range or clothing category.
5. WHEN a Comfort_Rating has sub-scores, THE App SHALL display texture, pressure, and temperature trends in addition to the overall score.

### Requirement 8: Authentication Guard

**User Story:** As a User, I want protected routes to require authentication, so that my data remains private.

#### Acceptance Criteria

1. WHEN an unauthenticated User attempts to access a protected route, THE Router SHALL redirect the User to the login screen.
2. WHEN the User completes login successfully, THE Router SHALL redirect the User to the originally requested route.
3. THE Router SHALL exempt the login, register, and onboarding routes from the Auth_Guard.
4. WHEN the User logs out, THE Router SHALL clear the navigation stack and redirect to the login screen.

### Requirement 9: Onboarding Flow

**User Story:** As a new User, I want a guided first-run experience, so that I can set up my sensory preferences and add my first wardrobe item quickly.

#### Acceptance Criteria

1. WHEN a new User completes registration, THE App SHALL navigate to the Onboarding_Flow.
2. THE Onboarding_Flow SHALL present a sensory preferences selection step allowing the User to indicate texture sensitivities, pressure tolerance, and temperature preferences.
3. THE Onboarding_Flow SHALL present a step guiding the User to add their first Clothing_Item to the Wardrobe_Catalog.
4. WHEN the User completes the Onboarding_Flow, THE App SHALL save the sensory preferences to the User profile and navigate to the Dashboard.
5. IF the User skips the onboarding, THEN THE App SHALL save default sensory preferences and navigate to the Dashboard.

### Requirement 10: Multi-Profile Switching UI

**User Story:** As a Caregiver, I want to switch between managed profiles, so that I can log outfits and track comfort for my dependents.

#### Acceptance Criteria

1. WHEN a Caregiver User has linked Dependent profiles, THE App SHALL display a profile switcher accessible from the profile screen.
2. WHEN the Caregiver selects a Dependent profile, THE App SHALL load all Wardrobe_Catalog, Outfit_Log, and Comfort_Rating data for the selected Dependent.
3. WHILE a Dependent profile is active, THE App SHALL display the Dependent's name in the app bar to indicate the active context.
4. THE App SHALL allow a Caregiver to add or remove Dependent profiles from the profile management screen.

### Requirement 11: Notification Scheduling

**User Story:** As a User, I want configurable reminders, so that I remember to log my outfit in the morning and rate comfort in the evening.

#### Acceptance Criteria

1. WHEN the User enables morning reminders in settings, THE Notification_Service SHALL schedule a daily local notification at the User-configured time prompting outfit logging.
2. WHEN the User enables evening reminders in settings, THE Notification_Service SHALL schedule a daily local notification at the User-configured time prompting comfort rating.
3. WHEN the User taps a notification, THE App SHALL navigate to the corresponding screen (log-outfit or comfort-rating).
4. WHEN the User disables reminders in settings, THE Notification_Service SHALL cancel all scheduled notifications.
5. THE Notification_Service SHALL use timezone-aware scheduling to deliver notifications at the correct local time.

### Requirement 12: Profile Screen

**User Story:** As a User, I want to view and edit my profile information, so that I can manage my account and sensory preferences.

#### Acceptance Criteria

1. WHEN the User navigates to the profile route, THE App SHALL display the User's display name, email, and sensory preferences.
2. WHEN the User edits their profile and saves, THE App SHALL update the User profile in the local database and sync to Firebase Auth if applicable.
3. THE App SHALL display the list of linked Dependent profiles for Caregiver users.
4. WHEN the User taps the logout button, THE App SHALL sign out via Firebase Auth and redirect to the login screen.

### Requirement 13: Settings Screen

**User Story:** As a User, I want a centralized settings screen, so that I can configure notification times, backup preferences, and accessibility options.

#### Acceptance Criteria

1. THE App SHALL provide settings controls for morning reminder time, evening reminder time, and notification enable/disable toggles.
2. THE App SHALL provide a backup section with buttons to trigger manual backup and restore operations via the Backup_Service.
3. WHEN the User triggers a backup, THE Backup_Service SHALL encrypt and upload all user data to Firebase cloud storage.
4. WHEN the User triggers a restore, THE Backup_Service SHALL download, decrypt, and restore data from the most recent cloud backup.
5. IF a backup or restore operation fails, THEN THE App SHALL display an error message with a retry option.
6. THE App SHALL provide an OpenWeatherMap API key configuration field stored in secure storage.

### Requirement 14: Admin System Management

**User Story:** As an Admin, I want to manage system configuration and user accounts, so that I can maintain the application.

#### Acceptance Criteria

1. WHEN an Admin navigates to the admin route, THE Admin_Panel SHALL display a list of all registered user accounts with status indicators.
2. THE Admin_Panel SHALL allow the Admin to disable or re-enable user accounts.
3. THE Admin_Panel SHALL display system configuration options including default notification times and weather cache duration.
4. WHEN the Admin updates a system configuration, THE Admin_Panel SHALL persist the change and apply it to new sessions.
5. THE Router SHALL restrict access to the admin route to users with the admin role.

### Requirement 15: Image Display in Wardrobe

**User Story:** As a User, I want to see photos of my clothing items throughout the app, so that I can visually identify garments.

#### Acceptance Criteria

1. WHEN a Clothing_Item has a stored photo path, THE App SHALL display the photo as a thumbnail in list views and as a full image in detail views.
2. IF the photo file at the stored path does not exist, THEN THE App SHALL display a placeholder icon and log the missing file.
3. THE App SHALL load photos asynchronously to avoid blocking the user interface.
