# travel

A new Flutter project.

## Getting Started

##Project Overview
This Flutter project is a travel companion app with various features to help users explore nearby attractions, manage trips, and more. The app includes functionalities like viewing favorite trips, booking flights, and adding fellow travelers. It also has dark mode and other user-friendly features.

Completed Tasks
1, 2, 3, 5, 6, 7, 13, 14, 20, 21: Fully completed.
8, 22: Partially completed.
19: Code written but not yet functional.
Login Credentials for Testing:
Email: nit@gmail.com
Password: 123456
Features
1. Navigation Bar
   The app has five main sections accessible through the navigation bar:

Home: Displays options to find nearby attractions and dining options based on the user's location.
Trips: Allows users to add trips, mark trips as favorites, and manage trip plans.
Explore: Explore additional travel-related information (this section can be expanded further).
Flights: Provides options to book flights (currently not functional due to API subscription limitations).
Favorites (Fav): Shows trips that the user has marked as favorites.
2. Slide Navigation Bar
   Accessible by sliding the screen or using a menu icon. It contains:

Settings: Users can enable dark mode.
Edit Profile: Users can edit their profile information.
Logout: Log out of the app.
3. Home Page Features
   Nearby Attractions: Users can find attractions near their current location by enabling location services. The app uses the user's district to fetch relevant places.
   Discover Dining: Similar to nearby attractions, this option helps users find dining options based on location.
4. Trips Page
   Users can add trips, mark trips as favorites, and view their details.
   Each trip allows users to add plans, specifying what to do and when.
   Weather Forecast: Clicking on a plan shows the weather forecast for the selected venue (better results are shown when the venue is a state).
   Add Travelers: Users can add fellow travelers to a trip by searching among the app's registered users (example users: "tc" and "priyam"). This is updated in Firebase.
5. Favorites Section
   Users can view and manage their favorite trips.
6. Edit Profile
   Users can update their profile information.
7. Settings
   The app supports dark mode, which can be toggled on or off in the settings.
8. Flight Booking
   Although the feature is implemented, the flight booking API does not return results due to subscription requirements. The project is ready to integrate with an API when one is available.
   Work in Progress
   Task 22: Flight booking partially functional (API integration pending).
   Task 8: Further functionality under development.
   Code Written But Not Working
   Task 19: The feature is implemented, but is not currently working as expected.