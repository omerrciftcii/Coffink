
# Coffink App Blueprint

## Overview

Coffink is a mobile application for coffee enthusiasts. It allows users to discover new coffees, save their favorites, and manage their user profile.

## Implemented Features

*   **Firebase Setup**: The project is connected to a Firebase project with both Android and web apps configured.
*   **Dependencies**: The following packages have been added to the project:
    *   `firebase_core`: To initialize Firebase.
    *   `firebase_auth`: For user authentication.
    *   `cloud_firestore`: For data storage.
    *   `provider`: for state management.
    *   `google_fonts`: For custom fonts.
*   **Authentication**: 
    *   A full authentication flow has been implemented with separate login and registration screens.
    *   Users can create an account and log in with their email and password.
*   **UI/UX**:
    *   A visually appealing login and registration screen with a background image.
    *   A home screen with a bottom navigation bar for navigating between the coffee list, favorites, and profile screens.
    *   A coffee list that displays real coffee data from Firestore.
    *   A favorites screen that displays the user's favorite coffees.
*   **Data Model**: A `Coffee` data model has been created to represent coffee items.
*   **Services**:
    *   An `AuthService` to handle user authentication.
    *   A `CoffeeService` to fetch coffee data from Firestore.
    *   A `FavoritesService` to manage user favorites.

## Next Steps

1.  **Profile Screen**:
    *   Implement the user profile screen, allowing users to view and edit their profile information.
    *   Allow users to upload a profile picture.
2.  **Coffee Details**:
    *   Create a coffee details screen that shows more information about a selected coffee.
    *   Add user reviews and ratings for each coffee.
3.  **Error Handling**:
    *   Implement more robust error handling throughout the app to provide better feedback to the user in case of network or other errors.
