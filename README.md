# Travel - A Flutter Project

## Project Overview

This project is a travel companion app built with Flutter, designed to help users explore nearby attractions, manage trips, and more. The app includes features like viewing favorite trips, booking flights, and adding fellow travelers. Additional functionality such as dark mode and profile editing is also available.

## Login Credentials for Testing

- **Email**: `nit@gmail.com`
- **Password**: `123456`

## Features

### Navigation Bar
The app provides five main sections, accessible through the navigation bar:

- **Home**: Explore nearby attractions and dining options based on the user's current location.
- **Trips**: Add trips, mark trips as favorites, and manage plans for each trip.
- **Explore**: Not done yet
- **Flights**: Book flights (currently not functional due to API subscription limitations).
- **Favorites**: View and manage trips that are marked as favorites.

### Slide Navigation Bar
Available through the side menu, it includes:
- **Settings**: Toggle between dark mode and light mode.
- **Edit Profile**: Update user profile information.
- **Logout**: Log out of the application.

### Home Page
- **Nearby Attractions**: Users can find attractions near their current location by enabling location services. The app uses the district to fetch relevant places.
- **Discover Dining**: Helps users find nearby dining options.

### Trips Page
- Add, view, and manage trips.
- Mark trips as **favorites**.
- Add and view plans within each trip, specifying tasks and times.
- **Weather Forecast**: Shows the weather forecast by clicking in each plan for the venue chosen in the plan (better results for venues at the state level).
- **Add Travelers**: Add fellow travelers to a trip by searching the app's users (example users: `"tc"` and `"priyam"`). This data is synced with Firebase.

### Favorites Section
- View and manage trips marked as favorites.

### Edit Profile
- Users can update their profile information.

### Settings
- Enable or disable **dark mode**.

### Flight Booking
- Users can attempt to book flights (this feature is currently not functional due to the API subscription requirement).

## Completed Tasks
- **Fully Completed**: Tasks 1, 2, 3, 5, 6, 7, 13, 14, 20, 21.
- **Partially Completed**: Tasks 8, 22.
- **Code Written but Not Working**: Task 19.

---

## Getting Started with Flutter

If you're new to Flutter development, here are a few resources to help you get started:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For more in-depth information, check out the [Flutter documentation](https://docs.flutter.dev/), which provides tutorials, samples, and a full API reference.
