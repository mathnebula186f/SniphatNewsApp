# SnipHat App

SnipHat is a mobile application that allows users to read news articles from various sources. It provides features like user authentication, reading and filtering news articles, marking articles as read, and searching for articles.

## Features

- **User Authentication and Login:** Users can log in to the app using their username and password.
- **Fetching News:** The app fetches news articles from the News API and displays them in a list.
- **Filtering/Searching Articles:** Users can filter articles by searching for keywords in the article titles.
- **Marking Articles:** Users can mark articles as read, and the app will remember their reading status.
- **Deleting Articles:** Users can delete articles from their reading list.
- **Logout:** Users can log out of the app and return to the login screen.

## Technologies Used

- **Flutter:** The app is built using the Flutter framework for cross-platform mobile development.
- **HTTP Package:** Used to make HTTP requests to the News API to fetch news articles.
- **Shared Preferences:** Used to store user authentication data and article reading status locally on the device.
- **Flutter DotEnv:** Used to load environment variables from a .env file, such as the News API key.

## Installation

1. Clone the repository: `git clone https://github.com/your_username/sniphat-app.git`
2. Navigate to the project directory: `cd sniphat-app`
3. Install dependencies: `flutter pub get`
4. Create a .env file in the project root and add your News API key:
5. Run on an android device using USB or Wireless Debugging OR an android emulator using `flutter run` 
